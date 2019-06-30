#FROM codercom/code-server:1.939
FROM codercom/code-server:latest
MAINTAINER Novs Yama

ARG VCS_REF
LABEL org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/frost-tb-voo/docker-code-server-go"

USER root
# gcc for cgo
RUN apt-get -qq update \
 && apt-get -qq -y install --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
 && apt-get -q -y autoclean \
 && apt-get -q -y autoremove \
 && rm -rf /var/lib/apt/lists

ENV GOLANG_VERSION 1.12.6
ENV goRelArch linux-amd64
ENV goRelSha256 dbcf71a3c1ea53b8d54ef1b48c85a39a6c9a935d01fc8291ff2b92028e59913c

RUN set -eux; \
	url="https://golang.org/dl/go${GOLANG_VERSION}.${goRelArch}.tar.gz"; \
	wget -nv -O go.tgz "$url"; \
	echo "${goRelSha256} *go.tgz" | sha256sum -c -; \
	tar -C /usr/local -xzf go.tgz; \
	rm go.tgz; \
	export PATH="/usr/local/go/bin:$PATH"; \
	go version

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

USER coder
ENV GOPATH /home/coder/go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH" \
 && go get -v github.com/mdempsky/gocode \
 && go get -v github.com/uudashr/gopkgs/cmd/gopkgs \
 && go get -v github.com/ramya-rao-a/go-outline \
 && go get -v github.com/acroca/go-symbols \
 && go get -v golang.org/x/tools/cmd/guru \
 && go get -v golang.org/x/tools/cmd/gorename \
 && go get -v github.com/go-delve/delve/cmd/dlv \
 && go get -v github.com/stamblerre/gocode \
 && go get -v github.com/rogpeppe/godef \
 && go get -v github.com/sqs/goreturns \
 && go get -v golang.org/x/lint/golint

USER root
WORKDIR /golang
RUN apt-get -qq update \
 && apt-get -qq -y install npm \
 && apt-get -q -y autoclean \
 && apt-get -q -y autoremove \
 && rm -rf /var/lib/apt/lists \
 && npm install -g n --silent \
 && npm cache clean --force -g \
 && n stable
RUN npm install -g yarn typescript --silent \
 && npm cache clean --force -g
RUN apt-get -qq update \
 && apt-get -qq -y install curl zip unzip \
 && curl -L -o Go-0.11.0.vsix https://github.com/microsoft/vscode-go/releases/download/0.11.0/Go-0.11.0.vsix \
 && unzip -q Go-0.11.0.vsix \
 && rm Go-0.11.0.vsix \
 && cd /golang/extension \
 && npm install \
 && npm audit fix --force \
 && npm cache clean --force \
 && rm -r node_modules package-lock.json \
 && yarn install \
 && yarn cache clean \
 && cd /golang \
 && zip -q -r Go-0.11.0.vsix . \
 && apt-get -q -y purge curl zip unzip \
 && apt-get -q -y autoclean \
 && apt-get -q -y autoremove \
 && rm -rf /var/lib/apt/lists \
 && rm -r /golang/extension

WORKDIR /home/coder/project
USER coder
RUN code-server --install-extension /golang/Go-0.11.0.vsix

USER root
ADD settings.json /home/coder/.local/share/code-server/User/settings.json
RUN cd / \
 && rm -r /golang \
 && chown -hR coder /home/coder

USER coder


