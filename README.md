# deepspeed-gke

Create cluster
```

```


```
gcloud container clusters get-credentials llama2-inference-cluster --zone us-west1-b
export HF_TOKEN=<paste-your-own-token>
kubectl create secret generic huggingface --from-literal="HF_TOKEN=$HF_TOKEN" -n triton
kubectl apply -f llama2-gke-deploy.yaml -n triton
```

helm install deepspeed -f values.yaml oci://registry-1.docker.io/bitnamicharts/deepspeed

## Common issues:

CUDA initialization, GPU not found issues:

import torch
available_gpus = [torch.cuda.device(i) for i in range(torch.cuda.device_count())]
available_gpus