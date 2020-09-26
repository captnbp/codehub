FROM    codercom/code-server:3.5.0

LABEL maintainer="benoit.pourre@doca-consulting.fr"
LABEL app.kubernetes.io/version="3.5.0"
LABEL app.kubernetes.io/managed-by="Helm"
LABEL app.kubernetes.io/part-of="code-server-hub-anaconda"
LABEL app.kubernetes.io/component="nginx"
LABEL source="https://gitlab.com/captnbp/code-server-hub"

EXPOSE  8080
COPY    ./install_tools.sh /usr/local/bin/install_tools.sh
COPY    ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

USER    root
RUN     /usr/local/bin/install_tools.sh

ENV PATH /opt/conda/bin:$PATH

RUN wget --quiet https://repo.anaconda.com/archive/Anaconda3-2020.07-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh

USER    coder
ENV     ZSH_CACHE_DIR=/tmp

ENTRYPOINT      ["dumb-init", "fixuid", "-q", "docker-entrypoint.sh"]
CMD     ["code-server"]