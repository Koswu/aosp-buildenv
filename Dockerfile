FROM ubuntu:18.04

# fetch require package
RUN apt-get update && \
    apt-get install -y vim python3 kmod rsync ccache rclone repo git-core gnupg flex bison build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 libncurses5 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig libssl-dev &&\
    mkdir /code && mkdir /cache && update-alternatives --remove python /usr/bin/python2 && update-alternatives --install /usr/bin/python python /usr/bin/python3 10
    

# add execute user and group
RUN addgroup --gid 1000 docker && \
    adduser --uid 1000 --ingroup docker --home /home/docker --shell /bin/sh --disabled-password --gecos "" docker

# fetch fixuid tool
RUN USER=docker && \
    GROUP=docker && \
    curl -SsL https://github.com/boxboat/fixuid/releases/download/v0.5.1/fixuid-0.5.1-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf - && \
    chown root:root /usr/local/bin/fixuid && \
    chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid && \
    printf "user: $USER\ngroup: $GROUP\n" > /etc/fixuid/config.yml

# default cache size is 50G
ENV CCACHE_DIR=/cache CCACHE_EXEC=/usr/bin/ccache USE_CCACHE=0 CACHE_SIZE=50G 


WORKDIR /code
USER docker:docker
ENTRYPOINT "/usr/bin/ccache -M $CACHE_SIZE"
#CMD "/bin/bash"
# usage: docker run --rm -it -u <uid>:<gid> <image name> sh