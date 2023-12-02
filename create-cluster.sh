export REGION=us-west1
export PROJECT_ID=$(gcloud config get project)

gcloud container clusters create llm-inference-l4 --location ${REGION} \
  --workload-pool ${PROJECT_ID}.svc.id.goog \
  --enable-image-streaming --enable-shielded-nodes \
  --shielded-secure-boot --shielded-integrity-monitoring \
  --enable-ip-alias \
  --node-locations=$REGION-a \
  --cluster-version=1.27.5-gke.200
  --workload-pool=${PROJECT_ID}.svc.id.goog \
  --addons GcsFuseCsiDriver   \
  --no-enable-master-authorized-networks \
  --machine-type n2d-standard-4 \
  --num-nodes 1 --min-nodes 1 --max-nodes 3

gcloud container node-pools create llm-inference-pool --cluster llm-inference-l4  --accelerator type=nvidia-tesla-t4,count=1,gpu-driver-version=latest   --machine-type n1-standard-4   --ephemeral-storage-local-ssd=count=1   --enable-autoscaling --enable-image-streaming   --num-nodes=0 --min-nodes=0 --max-nodes=3   --shielded-secure-boot   --shielded-integrity-monitoring   --node-locations $REGION-b --region $REGION --spot
