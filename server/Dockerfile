
FROM bitnami/deepspeed:0.12.3-debian-11-r0
WORKDIR /app
COPY requirements.txt ./
RUN pip install  -r requirements.txt
COPY serve.py ./
ENTRYPOINT ["python", "serve.py"]
