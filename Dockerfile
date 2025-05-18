FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=vrising
ENV HOME=/home/$USER

# Install dependencies
RUN dpkg --add-architecture i386 && \
    apt update && \
    apt install -y \
        software-properties-common \
        cabextract \
        winbind \
        screen \
        xvfb \
        curl \
        wget \
        unzip \
        ca-certificates \
        libnss3 \
        libx11-6 \
        libglu1-mesa \
        libxrandr2 \
        libxinerama1 \
        libxcursor1 \
        libxi6 \
        libwine \
        libwine:i386 \
        wine64 \
        wine32 \
        tar \
        gzip \
        locales \
        lib32gcc-s1 \
        lib32stdc++6 \
        bash

# Set locale to prevent SteamCMD complaints
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Create non-root user
RUN useradd -m ${USER}

# Manually install SteamCMD
WORKDIR ${HOME}
RUN mkdir -p ${HOME}/steamcmd && \
    cd ${HOME}/steamcmd && \
    curl -sSL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar -xz && \
    chmod +x steamcmd.sh
# Install V Rising server
RUN mkdir -p ${HOME}/server ${HOME}/persistentdata


# Optional: Copy start script if you have it
COPY start.sh ${HOME}/start.sh
RUN chown -R ${USER}:${USER} /home/${USER} && \
    chmod +x ${HOME}/start.sh

USER ${USER}
RUN Xvfb :1 -screen 0 1024x768x16 &
# RUN steamcmd +@sSteamCmdForcePlatformType windows +force_install_dir "/home/vrising/server" +login anonymous +app_update 1829350 validate +quit

# # Default workdir and command
WORKDIR ${HOME}
ENTRYPOINT ["./start.sh"]
