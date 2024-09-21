# FROM ubuntu:22.04
FROM debian:stable-slim

RUN apt-get update \
    && apt-get install -y curl
#     wget \
#     curl \
#     libedit2 \
#     git

# Install Magic package manager
RUN curl -ssL https://magic.modular.com/ea225f62-55d7-46cc-904a-bbc76037d2bf | bash
ENV PATH="$PATH:/root/.modular/bin"

# Install app
COPY . /usr/app
WORKDIR /usr/app

# Install dependencies of the project
RUN magic install

# Run Battlesnake
CMD [ "magic", "run", "mojo", "main.mojo" ]
