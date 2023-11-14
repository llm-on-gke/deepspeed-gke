
FROM nvidia/cuda:11.6.2-runtime-ubuntu20.04 as builder

WORKDIR /workspace

COPY serve.py ./
COPY requirements.txt ./
RUN apt-get -y update \
    && apt-get install -y software-properties-common \
    && apt-get -y update \
    && add-apt-repository universe
RUN apt-get -y update
RUN apt-get -y install python3
RUN apt-get -y install python3-pip
RUN python3 -m pip install  --user --upgrade pip
RUN python3 -m pip install  --user -r requirements.txt

FROM nvidia/cuda:11.6.2-base-ubuntu20.04
WORKDIR /root
COPY --from=builder /root/.local/bin .local/bin
ENV PATH=$PATH:/root/.local/bin
WORKDIR /workspace
COPY --from=builder /workspace/serve.py serve.py
ENTRYPOINT ["python3", "serve.py"]


