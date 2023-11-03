FROM ubuntu:jammy
LABEL org.opencontainers.image.authors="mikael.marche@orange.com" 

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

# Generate locale C.UTF-8
ENV LANG C.UTF-8
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


#Dev env 
RUN apt update \
  && apt upgrade -y \
  && apt install -y --no-install-recommends \
    build-essential \
    git \
    repo \
    gcc \
    g++ \
    pkg-config \
    libssl-dev \
    libdbus-1-dev \
    libglib2.0-dev \
    libavahi-client-dev \
    ninja-build \
    python3-venv \
    python3-dev \
    python3-pip \
    libgirepository1.0-dev \
    libcairo2-dev \
    libreadline-dev \
    liblua5.1-0 \
    liblua5.1-0-dev \
    lua5.1 \
    libjson-c-dev \
    cmake \
    liburiparser-dev \ 
    libyajl-dev \  
    libcap-ng-dev \
    libevent-dev \ 
    m4 \
    bison \
    flex \
    strace \
    gdb \
    gdbserver \
    python3-ptrace \
    libfcgi-dev \
    libxml2-dev \
    libxslt1-dev \
    protobuf-c-compiler \
    protobuf-compiler \
    libprotobuf-c-dev \
    && apt clean all \
  && apt autoremove

#Tools 
RUN apt update \
  && apt upgrade -y \
  && apt install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    nano \
    tar \
    vim \
    unzip \
    sudo \
    openssh-client \ 
  && apt clean all \
  && apt autoremove


  RUN mkdir -p /sdkworkdir/workspace
  WORKDIR /sdkworkdir/workspace

#Openwrt wrapper
RUN git clone git://git.openwrt.org/project/libubox.git \
    && cd libubox \
    && git checkout 75a3b870cace1171faf57bd55e5a9a2f1564f757 \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make \
    && make install \
    && cd ../.. \
    && git clone git://git.openwrt.org/project/ubus.git \
    && cd ubus \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make \
    && make install \
    && cd ../.. \
    && git clone git://git.openwrt.org/project/uci.git \
    && cd uci \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make \
    && make install \
    && cd ../.. \
    && git clone git://git.openwrt.org/project/procd.git\
    && cd procd \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make \
    && make install \
    && cd ../.. \
    && rm -r libubox ubus uci procd \
    && ldconfig /usr/local/lib

RUN git clone https://gitlab.com/prpl-foundation/components/core/libraries/libsahtrace.git \
    && cd libsahtrace \
    && make \
    && make install 

#ambiorix
RUN mkdir ambiorix && cd  ambiorix \
    && ssh-keygen -N "" -t rsa -b 2048 -C "prpldev@orange.com" -f ~/.ssh/id_rsa \
    && git config --global user.email "prpldev@orange.com" \
    && git config --global user.name "prpldev" \
    && repo init -u https://gitlab.com/prpl-foundation/components/ambiorix/ambiorix.git \
    && repo sync 
#    && repo forall  -c "sh git checkout master"



RUN cd  ambiorix \
    && rm -r bus_adaptors/amxb_pcb \
    && rm -r bindings/lua  \
    && rm -r applications/acl-manager \
    && source .repo/manifests/scripts/local_commands.sh \
    && amx_rebuild_libs \
    && amx_rebuild_bus_backends \
    && amx_rebuild_bindings \
    && amx_rebuild_cli_mods \
    && amx_rebuild_examples \
    && repo forall -e -v applications/* -c "sudo make clean && make && sudo -E make install" \
    && mv examples ../../ \
    && cd bindings/python3/src/dist \
    && pip install *.whl \
    && cd /sdkworkdir/workspace \
    && rm -r ambiorix
    
#USP LIB
RUN git clone https://gitlab.com/soft.at.home/usp/libraries/libprotobuf.git \
    && cd libprotobuf \
    && make \
    && make install \
    && cd .. \
    && git clone https://gitlab.com/soft.at.home/usp/libraries/libimtp.git \
    && cd libimtp \
    && make \
    && make install \
    && cd .. \
    && git clone https://gitlab.com/soft.at.home/usp/libraries/libusp.git \
    && cd libusp \
    && make \
    && make install \
    && cd .. \
    && git clone https://gitlab.com/soft.at.home/usp/libraries/libuspi.git \
    && cd libuspi \
    && make \
    && make install \
    && cd .. \
    && rm -r libusp libuspi libimtp libprotobuf


#USP AGENT
ENV TERM=linux
RUN git clone https://gitlab.com/soft.at.home/usp/applications/uspagent.git \
    && cd uspagent \
    && make \
    && make install \
    && cd .. \
    && git clone https://gitlab.com/soft.at.home/usp/applications/usp-endpoint.git \
    && cd usp-endpoint \
    && make \
    && make install \
    && cd .. \
    && git clone https://gitlab.com/soft.at.home/usp/applications/tr181-localagent.git \
    && cd tr181-localagent \
    && make \
    && make install \
    && cd .. \
    && git clone https://gitlab.com/soft.at.home/usp/applications/tr181-uspservices.git \
    && cd tr181-uspservices \
    && make \
    && make install \
    && cd .. \
    && rm -r usp-endpoint uspagent tr181-localagent tr181-uspservices


#Modules 
RUN git clone https://gitlab.com/prpl-foundation/components/core/modules/mod-dmext.git \
    && cd mod-dmext \
    && make \
    && make install \
    && cd .. \
    && rm -r mod-dmext 

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]


