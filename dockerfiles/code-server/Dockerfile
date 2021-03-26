FROM    codercom/code-server:3.9.2

LABEL maintainer="benoit.pourre@doca-consulting.fr"
LABEL app.kubernetes.io/version="3.9.2"
LABEL app.kubernetes.io/managed-by="Helm"
LABEL app.kubernetes.io/part-of="code-server-hub"
LABEL app.kubernetes.io/component="nginx"
LABEL source="https://gitlab.com/captnbp/code-server-hub"

EXPOSE  8080
COPY    ./install_tools.sh /usr/local/bin/install_tools.sh
COPY    ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

USER    root
RUN     /usr/local/bin/install_tools.sh

USER    coder
ENV     ZSH_CACHE_DIR=/tmp

ENTRYPOINT      ["dumb-init", "docker-entrypoint.sh"]
CMD     ["code-server"]