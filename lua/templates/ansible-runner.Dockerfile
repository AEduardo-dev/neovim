ARG DEP_PROXY_PREFIX=docker.io
FROM ${DEP_PROXY_PREFIX}/python:slim as builder

SHELL ["/bin/bash", "-c"]
ENV CONFIG_SHELL="/bin/bash"

ENV container=docker
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -yq --no-install-recommends wget ssh sshpass git vim && \
    rm -rf /var/lib/apt/lists/*

# Install ansible and ansible-lint
RUN apt-get update && \
    apt-get install -yq --no-install-recommends ansible && \
    rm -rf /var/lib/apt/lists/*
RUN python3 -m pip install ansible-lint passlib
RUN ansible-galaxy collection install ansible.posix community.docker community.general


# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1

WORKDIR /app

ENTRYPOINT [ "bash" ]


