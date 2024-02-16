# syntax=docker/dockerfile:1
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04
LABEL maintainer="alchemine <djyoon0223@gmail.com>"

# ignore interaction
ARG DEBIAN_FRONTEND=noninteractive

# copy context
COPY context/config     /opt/docker/context/config
COPY context/entrypoint /opt/docker/context/entrypoint
COPY context/utils      /opt/docker/context/utils

# use proxy
RUN sed -i 's#http://archive.ubuntu.com/ubuntu/#http://mirror.kakao.com/ubuntu/#g' /etc/apt/sources.list && \
    sed -i 's#http://security.ubuntu.com/ubuntu/#http://mirror.kakao.com/ubuntu/#g' /etc/apt/sources.list

# install fundamental packages
RUN apt update && \
    xargs apt install -y < /opt/docker/context/utils/requirements.apt && \
    rm -rf /var/lib/apt/lists/*

# set fundamental configuration
RUN cat /opt/docker/context/config/account | chpasswd && \
    cat /opt/docker/context/config/sshd_config >> /etc/ssh/sshd_config && \
    cat /opt/docker/context/config/bashrc >> /root/.bashrc && \
    cat /opt/docker/context/config/vimrc >> /usr/share/vim/vimrc && \
    ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

# install python
RUN /opt/docker/context/utils/install_python.sh

# install poetry
RUN /opt/docker/context/utils/install_poetry.sh

# install java
RUN /opt/docker/context/utils/install_java.sh

# install extension packages
COPY context/extension /opt/docker/context/extension
RUN apt update && \
    xargs apt install -y < /opt/docker/context/extension/requirements.apt && \
    rm -rf /var/lib/apt/lists/*

# run entrypoint.sh
ENTRYPOINT [ "/opt/docker/context/entrypoint/entrypoint.sh" ]
CMD [ "/bin/bash" ]
