FROM alpine:latest

# Define versions
ARG DOGENODE_VERSION=1.14.2

# Define download URLs
ARG DOGENODE_URL=https://github.com/dogecoin/dogecoin/releases/download/v${DOGENODE_VERSION}/dogecoin-${DOGENODE_VERSION}-x68_64-linux-gnu.tar.gz

RUN \
  echo ${DOGENODE_URL} && \
  apk -U upgrade && \
  apk add \
    curl \
    gnupg \
    ca-certificates \
    tar \
     \
    && \
  echo Downloading dogecoind source && \
  mkdir dogecoin-bin && \
  curl -# -L ${DOGENODE_URL} |tar xz --strip 1 -C dogecoin-bin && \
  echo Compiling Dogenode ${DOGENODE_VERSION} && \
  cd dogecoin-bin && \
  if [ ! -f ~/.dogecoin/dogecoin.conf ]; then \
    echo Generating dogecoin.conf file; \
    mkdir ~/.dogecoin; \
    echo rpcuser=dogecoinrpc > ~/.dogecoin/dogecoin.conf; \
    PWord=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1` ; \
    echo rpcpassword=$PWord >> ~/.dogecoin/dogecoin.conf; \
  fi && \
  if [ -f ~/.dogecoin/bootstrap.dat.old ]; then\
    rm ~/.dogecoin/bootstrap.dat.old; \
  fi && \
  echo Running dogecoin && \
  ~/dogecoin-bin/bin/dogecoind -maxconnections=500 -printtoconsole -shrinkdebugfile

LABEL \
  name="dogecoin-node" \
  version="${DOGENODE_VERSION}" \
  description="Dogecoin fullnode container based off Alpine"
