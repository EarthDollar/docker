FROM ubuntu:trusty
MAINTAINER chrisfranko


ENV DEBIAN_FRONTEND noninteractive

# Usual update / upgrade
RUN apt-get update
RUN apt-get upgrade -q -y
RUN apt-get dist-upgrade -q -y

# Let our containers upgrade themselves
RUN apt-get install -q -y unattended-upgrades

# Install Expanse
RUN apt-get install -q -y software-properties-common
RUN apt-get install -q -y curl git mercurial binutils bison gcc make libgmp3-dev build-essential screen

RUN add-apt-repository ppa:ethereum/ethereum
RUN add-apt-repository ppa:ethereum/ethereum-dev &&\
apt-get update
RUN apt-get install -q -y geth

# Install stuff for nodejs
RUN curl -sL https://deb.nodesource.com/setup | bash - &&\
    apt-get install -y nodejs &&\
	apt-get install -y build-essential

#get eth net intell
RUN cd /root &&\
    git clone https://github.com/cubedro/eth-net-intelligence-api &&\
    cd eth-net-intelligence-api &&\
    npm install &&\
    npm install -g pm2
	
# start the engines
ADD start.sh /root/start.sh
ADD app.json /root/eth-net-intelligence-api/app.json
RUN chmod +x /root/start.sh
	
# Install Go
RUN \
  mkdir -p /goroot && \
  curl https://storage.googleapis.com/golang/go1.4.2.linux-amd64.tar.gz | tar xvzf - -C /goroot --strip-components=1

# Set environment variables.
ENV GOROOT /goroot
ENV GOPATH /gopath
ENV PATH $GOROOT/bin:$GOPATH/bin:$PATH

RUN git clone http://www.github.com/expanse-project/go-expanse.git
RUN cd go-expanse && make gexp
RUN cp -rf /go-expanse/build/bin/gexp /usr/bin/gexp

EXPOSE 9656
EXPOSE 42786
EXPOSE 42786/udp

ENTRYPOINT /root/start.sh
