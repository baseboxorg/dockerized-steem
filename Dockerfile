FROM alpine:3.8

MAINTAINER BaseBoxOrg

ARG STEEM_TAG_NAME
ENV STEEM_TAG_NAME ${STEEM_TAG_NAME:-0.19.12}
ENV STEEMD_ARGS --p2p-endpoint=0.0.0.0:2001 --rpc-endpoint=0.0.0.0:8090 --replay-blockchain

RUN apk --no-cache add \
        ca-certificates \
        cmake \
        alpine-sdk \
        boost-dev==1.60.0-r2 \
        openssl-dev \
        autoconf \
        automake \
        libtool \
        file

RUN mkdir -p /usr/local/src/ && \
        cd /usr/local/src/ && \
        git clone https://github.com/steemit/steem.git && \
        cd steem && \
        git checkout v${STEEM_TAG_NAME} && \
        git submodule update --init --recursive

RUN  mkdir -p /usr/local/src/steem/build && \
        cd /usr/local/src/steem/build && \
        cmake \
                -DCMAKE_BUILD_TYPE=Release \
                -DCMAKE_INSTALL_PREFIX=/usr/local \
                -DLOW_MEMORY_NODE=ON \
                -DCLEAR_VOTES=ON \
                -DBUILD_STEEM_TESTNET=OFF \
                ../CMakeLists.txt

RUN cd /usr/local/src/steem  && \
        make install

RUN apk del cmake \
        alpine-sdk \
        autoconf \
        automake 

RUN rm -rf \
        /tmp/* \
        /var/tmp/* \
        /var/cache/* \
        /usr/include \
        /usr/local/include \
        /usr/local/src

EXPOSE 8090
EXPOSE 2001

ENTRYPOINT steemd
CMD ${STEEMD_ARGS}
