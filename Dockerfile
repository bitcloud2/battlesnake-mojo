# FROM ubuntu:22.04
FROM debian:stable-slim

RUN apt-get update \
    && apt-get install -y \
    wget \
    curl \
    libedit2 \
    git

# Download/Install minicoda py3.11 for linux x86/x64.
RUN mkdir -p /opt/conda 
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py311_24.1.2-0-Linux-x86_64.sh -O /opt/conda/miniconda.sh \ 
    && bash /opt/conda/miniconda.sh -b -p /opt/miniconda

ENV PATH=/opt/miniconda/bin:$PATH
RUN conda init

# Auth token for downloading mojo
# Pass in arg through CLI as below:
# fly launch --build-arg AUTH_TOKEN=put_token_here_from_modular_config_id
ARG AUTH_TOKEN
ENV AUTH_TOKEN=${AUTH_TOKEN}

# Install Modular/Mojo
RUN curl -s https://get.modular.com | sh -
RUN modular auth $AUTH_TOKEN
RUN modular install mojo

ARG MODULAR_HOME="/root/.modular"
ENV MODULAR_HOME=$MODULAR_HOME
ENV PATH="$PATH:$MODULAR_HOME/pkg/packages.modular.com_mojo/bin"

# Install app
COPY . /usr/app
WORKDIR /usr/app
# Pull lightbug_http package directly
RUN wget https://github.com/saviorand/lightbug_http/releases/download/latest-build/lightbug_http.mojopkg

# Run Battlesnake
CMD [ "mojo", "main.mojo" ]
