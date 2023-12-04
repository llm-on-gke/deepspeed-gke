# GKE AI/ML infra: Use Deepspeed for distributed training and inference in GKE

## About Deepspeed 
DeepSpeed enables world’s most powerful language models like MT-530B and BLOOM. It is an easy-to-use deep learning optimization software suite that powers unprecedented scale and speed for both training and inference. With DeepSpeed you can:

Train/Inference dense or sparse models with billions or trillions of parameters
Achieve excellent system throughput and efficiently scale to thousands of GPUs
Train/Inference on resource-constrained GPU systems
Achieve unprecedented low latency and high throughput for inference
Achieve extreme compression for an unparalleled inference latency and model size reduction with low costs

Below is a list of models supported:

Megatron-Turing NLG (530B)
Jurassic-1 (178B)
BLOOM (176B)
GLM (130B)
YaLM (100B)
GPT-NeoX (20B)
AlexaTM (20B)
Turing NLG (17B
METRO-LM (5.4B)

Also, DeepSpeed has been integrated with several different popular open-source DL frameworks such as: Transformer, Accelerate, Lighting, Mosaic ML

## Create GKE Cluster and Nodepool

## GKE Cluster and Nodepools
See the create-cluster.sh
### Quick Estimates of GPU type and number of GPU needed for model infereence:
Estimate the size of a model in gigabytes by multiplying the number of parameters (in billions) by 2. This approach is based on a simple formula: with each parameter using 16 bits (or 2 bytes) of memory in half-precision, the memory usage in GB is approximately twice the number of parameters. Therefore, a 7B parameter model, for instance, will take up approximately 14 GB of memory. We can comfortably run a 7B parameter model in Nvidia L4 and still have about 10 GB of memory remaining as a buffer for inferencing. Alternatively, you can choose to have 2 Tesla-T4 GPUs with 32G by sharding model across both GPUs, but there will be impacts of moving data around.  

For Models with larger parameter size, resource requirements can be reduced through weights Quantization into lower precision bits. 
Example, for Llama 2 70b model which may need 140G memeory with default half point(16 bits), resource requirements can be reduced with quatization into float 8 bits precision or even further with 4 bits, which only need 35G memory and can fit into 2 L4(48G)GPU. 
Reference: https://www.baseten.co/blog/llm-transformer-inference-guide/ 

### GKE Cluster

To illustrate the distributed nature of Deepspeed technology, we use small GPU (tesla-t4) in region us-west1
export REGION=us-west1
export PROJECT_ID=$(gcloud config get project)

The default shell script will create public GKE cluster, if you prefer to use private cluster to lock down control panel acces, then add the following options to gcloud container clusters create:
  ```
  --enable-ip-alias \
  --enable-private-nodes  \
  --master-ipv4-cidr 172.16.0.32/28 
 ```

### Nodepool
 The default script for nodepool uses nvidia-tesla-t4 1 GPU as example, related nodepool specs:

--accelerator type=nvidia-tesla-t4,count=1,gpu-driver-version=latest   --machine-type n1-standard-8 --node-version=1.27.5.GKE.200

Alternatively, you can choose to use nvidia-l4 1 GPU which can be us-central1 with tweaks to the nodepool specs:
--accelerator type=nvidia-l4,count=1,gpu-driver-version=latest   --machine-type g2-standard-8 --node-version=1.27.5.GKE.200


## Build DeepSpeed Container Image
Among all the options available to provvision DeepSpeed, Bitnami DeepSpeed Helmchart included as  component of VMWare Tanzu Application Catalog, is easist to understand and with one single place values.yaml to config both client(controller) and workers.
Unfortunately, from our tests, current GKE versions is incompatible with the default container image from the helmchart, bitnami/deepspeed:0.12.3-debian-11-r2, the symptom is GPU not found inside the container provisioned from default image from https://github.com/bitnami/containers/blob/main/bitnami/deepspeed/0/debian-11/Dockerfile. 

To build the Container image that can run in GKE, we need to build customized image

Update the artifactory repository to store container image in build/cloudbuild.yaml file, replace the Artifact repository path gke-llm, create the repo if it does not exit yet 

Then run the following command
```
  cd build
  gcloud builds submit.  
 ```

Make sure the build is succesful and container image created at the artifactory repo 
## Deploy deepspeed helmchart

Check and update the values.yaml file,
###
```
image:
  registry: us-east1-docker.pkg.dev
  repository: rick-vertex-ai/gke-llm/deepspeed-mii
  tag: latest
```
###
```
client:
   resources:
    limits: 
       nvidia.com/gpu: 1
   nodeSelector: 
      cloud.google.com/gke-accelerator: nvidia-tesla-t4
```
###
```
worker:
  ## @param worker.enabled Enable Worker deployment
  ##
  enabled: true
  ## @param worker.slotsPerNode Number of slots available per worker node
  ##
  slotsPerNode: 1
   replicaCount: 2
   resources:
    limits: 
       nvidia.com/gpu: 1
   nodeSelector: 
      cloud.google.com/gke-accelerator: nvidia-tesla-t4

```

For a full list of DeepSpeed config parameters and advanced customization, please refer to:

https://artifacthub.io/packages/helm/bitnami/deepspeed

https://github.com/bitnami/charts/blob/main/bitnami/deepspeed/values.yaml

Finally run the following command to deploy DeepSpeed helmchart:

helm install deepspeed -f values.yaml oci://registry-1.docker.io/bitnamicharts/deepspeed


## Validation and tests:
Check the client and worker pods are running without issue,

Then exec into the client(cluster) pod, and kick off a text-generation inference

kubectl exec -it client-XXXXX -- bash

When it is the shell prompt, run the following sample test,
```
cd /deepspeed/DeepSpeedExamples/inference/huggingface/text-generation
deepspeed --num_gpus 1 inference-test.py --model facebook/opt-125m --batch-size=2
```

## Common issues:

CUDA initialization, GPU not found issues, the issues can be shown by running the following command:
```
python
import torch
available_gpus = [torch.cuda.device(i) for i in range(torch.cuda.device_count())]
available_gpus
[]
```
This occurs due to GKE/Kubernetes version incompatible with image provided in Helmchart, check the build folder and test other builds. 