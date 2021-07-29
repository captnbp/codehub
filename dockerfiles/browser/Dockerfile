FROM alpine:3.14

EXPOSE 6080

# Setup testing repo for novnc
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

# Install basic packages
# hadolint ignore=DL3018
RUN apk --update --no-cache add chromium x11vnc novnc xvfb openbox supervisor xfce4-terminal \
        wget ca-certificates ttf-ubuntu-font-family ttf-font-awesome websockify && \
    update-ca-certificates

# Set index.html for auto loading
RUN ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# Hide status bar
#RUN sed -i 's/style="margin-top: 0px;"/style="margin-top: 0px; display:none;"/g' /usr/share/novnc/vnc.html

# Setup basic environment
ENV TERM=xterm
ENV VNC_COL_DEPTH=24
ENV VNC_RESOLUTION=1800x920

# Add new user
RUN addgroup coder && adduser -G coder -s /bin/sh -D coder

# Add supervisord
COPY supervisord.conf /etc/supervisord.conf

COPY ui.js /usr/share/novnc/app/ui.js

USER coder
WORKDIR /home/coder
VOLUME [ "/home/coder" ]

# Entrypoint
CMD ["/usr/bin/supervisord","-j","/tmp/supervisord.pid","-l","/tmp/supervisord.log","-c","/etc/supervisord.conf"]
