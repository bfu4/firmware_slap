FROM amd64/ubuntu:20.04

COPY dependencies /dependencies

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update

# Install xargs
RUN apt install --yes findutils

# Install dependencies
RUN xargs apt install --yes < /dependencies

# Docker install (docker-ception moment)
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
RUN bash -c 'echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null'
RUN apt update
RUN apt install --yes docker-ce docker-ce-cli containerd.io docker-compose-plugin

RUN service rabbitmq-server start

WORKDIR /
RUN git clone https://github.com/ChrisTheCoolHut/Firmware_Slap /slap
RUN bash -c "wget https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_10.1.4_build/ghidra_10.1.4_PUBLIC_20220519.zip"
RUN bash -c "unzip ghidra_10.1.4_PUBLIC_20220519.zip -d ghidra"
RUN echo "export PATH=\$PATH:/ghidra/ghidra_10.1.4/support" >> ~/.bashrc

WORKDIR /slap
RUN pip3 install -r requirements

WORKDIR /
RUN virtualenv -p python3 slap

WORKDIR /slap
RUN celery -A firmware_slap.celery_tasks worker --loglevel=info &> /etc/celery.log &
RUN bash -c "python3 setup.py install"

RUN mkdir /mount

WORKDIR /slap
RUN echo "source /slap/bin/activate" >> ~/.bashrc
