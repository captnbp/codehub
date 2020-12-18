FROM    nginxinc/nginx-unprivileged:1.18-alpine

LABEL maintainer="benoit.pourre@doca-consulting.fr"
LABEL app.kubernetes.io/version="3.8.0"
LABEL app.kubernetes.io/managed-by="Helm"
LABEL app.kubernetes.io/part-of="code-server-hub"
LABEL app.kubernetes.io/component="nginx"
LABEL source="https://gitlab.com/captnbp/code-server-hub"

COPY ./nginx.conf	/etc/nginx/nginx.conf

COPY --chown=nginx 30-oauth.sh /docker-entrypoint.d/30-oauth.sh
RUN  chmod +x /docker-entrypoint.d/30-oauth.sh