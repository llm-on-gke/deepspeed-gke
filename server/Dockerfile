
FROM europe-docker.pkg.dev/vertex-ai/training/pytorch-gpu.1-12.py310:latest

WORKDIR /app

RUN install_packages build-essential ca-certificates curl git jq libbz2-1.0 libcom-err2 libcrypt1 libffi7 libgcc-s1 libgomp1 libgssapi-krb5-2 libjemalloc2 libk5crypto3 libkeyutils1 libkrb5-3 libkrb5support0 liblzma5 libncursesw6 libnsl2 libreadline8 libsqlite3-0 libssl1.1 libstdc++6 libtinfo6 libtirpc3 libuuid1 numactl openssh-server pkg-config procps unzip zlib1g

LABEL com.nvidia.volumes.needed=nvidia_driver

ENV PATH=/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64

COPY requirements.txt requirements.txt

RUN pip install -r requirements.txt
RUN git clone https://github.com/microsoft/DeepSpeedExamples.git
COPY serve.py ./

ENTRYPOINT ["deepspeed", "--num_gpus=1", "serve.py"]
CMD "python"


