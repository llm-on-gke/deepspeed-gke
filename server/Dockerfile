
FROM bitnami/deepspeed:0.12.3-debian-11-r0
WORKDIR /workspace
COPY requirements.txt ./
RUN pip install  -r requirements.txt
COPY serve.py ./
RUN git clone https://github.com/microsoft/DeepSpeedExamples.git 