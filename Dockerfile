FROM amd64/ubuntu:20.04

WORKDIR /build
COPY setup.sh /build/setup.sh

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update
RUN apt install --yes \
	curl \
	gnupg \
        lsb-release

# Docker install (docker-ception moment)
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
RUN bash -c 'echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null'

RUN apt update
RUN apt install --yes \
	docker-ce \
	docker-ce-cli \
	containerd.io \
	docker-compose-plugin

RUN bash -c "/build/setup.sh"

RUN service rabbitmq-server start

RUN rm -f "/build/setup.sh"

WORKDIR /

COPY bin /slap/bin
COPY firmware_slap /slap/firmware_slap
COPY elastic /slap/elastic

WORKDIR /
RUN virtualenv -p python3 slap

WORKDIR /slap
RUN celery -A firmware_slap.celery_tasks worker --loglevel=info &> /etc/celery.log &

WORKDIR /slap/bin
RUN echo "source /slap/bin/activate" >> ~/.bashrc
