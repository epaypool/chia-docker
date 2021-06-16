FROM nikolaik/python-nodejs:python3.7-nodejs16-slim as builder

RUN DEBIAN_FRONTEND=noninteractive apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y git lsb-release sudo

ARG BRANCH=latest

RUN git clone --branch ${BRANCH} https://github.com/Chia-Network/chia-blockchain.git \
    && cd chia-blockchain \
    && git submodule update --init mozilla-ca \
    && chmod +x install.sh \
    && /bin/sh ./install.sh

FROM nikolaik/python-nodejs:python3.7-nodejs16-slim as runner

EXPOSE 8555
EXPOSE 8444

ENV keys="generate"
ENV harvester="false"
ENV farmer="false"
ENV plots_dir="/plots"
ENV farmer_address="null"
ENV farmer_port="null"
ENV testnet="false"
ENV full_node_port="null"
ENV TZ="UTC"

WORKDIR /chia-blockchain/

COPY --from=builder /chia-blockchain/ /chia-blockchain/

ENV PATH=/chia-blockchain/venv/bin/:$PATH

ADD ./entrypoint.sh entrypoint.sh
ENTRYPOINT ["bash", "./entrypoint.sh"]
