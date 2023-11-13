
FROM nvidia/cuda:11.2.2-base-ubuntu20.04
WORKDIR /workspace

COPY serve.py ./
COPY requirements.txt ./

RUN python3 -m pip install  --user --upgrade pip
RUN python3 -m pip install  --user -r requirements.txt
ENTRYPOINT ["python3", "serve.py"]


