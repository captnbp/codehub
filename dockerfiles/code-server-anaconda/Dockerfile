FROM    nvcr.io/nvidia/pytorch:21.10-py3

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
 && apt-get install -y \
    curl \
    dumb-init \
    zsh \
    htop \
    locales \
    man \
    nano \
    git \
    procps \
    openssh-client \
    sudo \
    vim.tiny \
    lsb-release \
  && rm -rf /var/lib/apt/lists/*

# https://wiki.debian.org/Locale#Manually
RUN sed -i "s/# en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen \
  && locale-gen
ENV LANG=en_US.UTF-8

RUN adduser --gecos '' --disabled-password coder && \
  echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd

RUN ARCH="$(dpkg --print-architecture)" && \
    curl -fsSL "https://github.com/boxboat/fixuid/releases/download/v0.5/fixuid-0.5-linux-$ARCH.tar.gz" | tar -C /usr/local/bin -xzf - && \
    chown root:root /usr/local/bin/fixuid && \
    chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid && \
    printf "user: coder\ngroup: coder\n" > /etc/fixuid/config.yml

RUN curl -L https://github.com/cdr/code-server/releases/download/v3.12.0/code-server_3.12.0_amd64.deb -o /tmp/code-server_3.12.0_amd64.deb && dpkg -i /tmp/code-server*$(dpkg --print-architecture).deb && rm /tmp/code-server*.deb

EXPOSE 8080
# This way, if someone sets $DOCKER_USER, docker-exec will still work as
# the uid will remain the same. note: only relevant if -u isn't passed to
# docker-run.
USER 1000
ENV USER=coder
WORKDIR /home/coder

LABEL maintainer="benoit.pourre@doca-consulting.fr"
LABEL source="https://gitlab.com/captnbp/code-server-hub"

USER root

EXPOSE  8080
COPY    ./install_tools.sh /usr/local/bin/install_tools.sh
COPY    ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

USER    root
RUN     /usr/local/bin/install_tools.sh

USER    coder
ENV     ZSH_CACHE_DIR=/tmp

ENTRYPOINT      ["dumb-init", "docker-entrypoint.sh"]
CMD     ["code-server"]
