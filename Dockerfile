# vnc-password -> debian
# run          -> (v1) docker run -it --rm -p 5901:5901 -e USER=docker dewian-desktop bash -c "vncserver :1 -geometry 1204x768 -depth 24 && tail -F ~/.vnc/*.log"
#                 (v2) docker run -it --rm dewian-desktop

FROM        debian:unstable-slim
MAINTAINER  Claude Henchoz  <https://claude.io>

ENV DEBIAN_FRONTEND noninteractive
ENV VNCDISPLAY 1
ENV VNCDEPTH 24
ENV VNCGEOMETRY 1920x1200

# Exclude some directories to reduce size
RUN echo "path-exclude /usr/share/doc/*\n#\
we need to keep copyright files for legal reasons\n\
path-include /usr/share/doc/*/copyright\n\
path-exclude /usr/share/man/*\n\
path-exclude /usr/share/groff/*\n\
path-exclude /usr/share/info/*\n#\
lintian stuff is small, but really unnecessary\n\
path-exclude /usr/share/lintian/*\n\
path-exclude /usr/share/linda/*" \
>> /etc/dpkg/dpkg.cfg.d/01_nodoc

# Update/Upgrade/Cleansing
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -yq --no-install-recommends apt-utils && \
    apt-get install -yq --no-install-recommends sudo nano wget && \
    apt-get install -y lightdm xfce4 xfce4-terminal numix-icon-theme numix-gtk-theme firefox tightvncserver autocutsel && \
    apt-get install -yq --no-install-recommends websockify git && \
    apt-get clean -y && \
    apt-get autoclean -y && \
    apt-get autoremove -y && \
    rm -rf /usr/share/locale/* && \
    rm -rf /var/cache/debconf/*-old && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/share/doc/*

# Aliases & Add normal user
RUN \
    echo "alias ls='ls --color=auto'" >> /root/.bashrc && \
    echo "alias ll='ls -lha --color=auto --group-directories-first'" >> /root/.bashrc && \
    echo "alias l='ls -lh --color=auto --group-directories-first'" >> /root/.bashrc && \
    addgroup --system docker && \
    adduser \
        --home /home/docker \
        --disabled-password \
        --shell /bin/bash \
        --gecos "Mr. Docker" \
        --ingroup docker \
        --quiet \
        docker && \
    cp /root/.bashrc /home/docker && \
    echo 'docker ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN cd / && git clone git://github.com/kanaka/noVNC

# Add vnc start command
ADD vnc /home/docker/.vnc
RUN chmod +x /home/docker/.vnc/xstartup
ADD start-vnc.sh /home/docker
RUN chmod +x /home/docker/start-vnc.sh

# Add firefox profile
ADD mozilla /home/docker/.mozilla

# Set owner to docker
RUN chown -R docker.docker /home/docker

# Define working directory
WORKDIR /home/docker

# Activate docker
USER docker

RUN touch ~/.Xresources && \
    touch ~/.Xauthority && \
    echo "debian" | vncpasswd -f > ~/.vnc/passwd && \
    chmod 600 ~/.vnc/passwd

# Expose ports
EXPOSE 5901

# Default command
CMD ["/home/docker/start-vnc.sh"]
