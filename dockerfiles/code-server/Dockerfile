FROM    codercom/code-server:3.9.3

LABEL maintainer="benoit.pourre@doca-consulting.fr"
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