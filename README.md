# deepspeed-gke

Create cluster
```

```


```
gcloud container clusters get-credentials llama2-inference-cluster --zone us-west1-b
export HF_TOKEN=<paste-your-own-token>
kubectl create secret generic llama2 --from-literal="HF_TOKEN=$HF_TOKEN" -n triton
kubectl apply -f llama2-gke-deploy.yaml -n triton
```

