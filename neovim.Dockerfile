# TODO: Write config copy from path given as argument (ease of configuration with multiple plugins)
# NOTE: Mounts should be done externally when starting the container -> alias for easier access 
# NOTE: Container should always be started with removal and dettachment to prevent dangling images
# NOTE: Each container build could include different configs for neovim -> tag accordingly
ARG DEP_DOCKER_PREFIX=docker.io
FROM ${DEP_DOCKER_PREFIX}/ubuntu:jammy as builder



RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends build-essential wget python3 && \
  rm -rf /var/lib/apt/lists/*

# Install Kinexon root CA
RUN mkdir -p /usr/local/share/ca-certificates && \
  wget -q http://release.knx/devops/KinexonGlobalRootCA.crt -P /usr/local/share/ca-certificates && \
  update-ca-certificates
ENV PIP_CERT=/etc/ssl/ca-certificates.crt

#Install nvim with lazy vim 
RUN sudo apt install neovim && \
  git clone https://github.com/LazyVim/starter ~/.config/nvim && \
  rm -rf ~/.config/nvim/.git

# install pip requirements if any
COPY requirements.txt .
RUN python3 -m pip install --user -r requirements.txt

FROM ${DEP_DOCKER_PREFIX}/ubuntu:jammy as app
COPY --from=builder /root/.local /root/.local 

# Keep python from generating pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1

# Turn off buffering  for easier container logging
ENV PYTHONBUFFERED=1

WORKDIR /app
COPY . /app

ENTRYPOINT [ "cd /work" ]


