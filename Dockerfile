FROM golang:buster as golang

FROM codercom/code-server:v2
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

COPY --from=golang /usr/local/go /usr/local/go

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

# https://github.com/Microsoft/vscode-go/wiki/Go-tools-that-the-Go-extension-depends-on
USER coder
ENV GOPATH /home/coder/go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH" \
 && go get -u -v github.com/ramya-rao-a/go-outline \
 && go get -u -v github.com/acroca/go-symbols \
 && go get -u -v github.com/mdempsky/gocode \
 && go get -u -v github.com/rogpeppe/godef \
 && go get -u -v golang.org/x/tools/cmd/godoc \
 && go get -u -v github.com/zmb3/gogetdoc \
 && go get -u -v golang.org/x/lint/golint \
 && go get -u -v github.com/fatih/gomodifytags \
 && go get -u -v golang.org/x/tools/cmd/gorename \
 && go get -u -v sourcegraph.com/sqs/goreturns \
 && go get -u -v golang.org/x/tools/cmd/goimports \
 && go get -u -v github.com/cweill/gotests \
 && go get -u -v golang.org/x/tools/cmd/guru \
 && go get -u -v github.com/josharian/impl \
 && go get -u -v github.com/haya14busa/goplay/cmd/goplay \
 && go get -u -v github.com/uudashr/gopkgs/cmd/gopkgs \
 && go get -u -v github.com/davidrjenni/reftools/cmd/fillstruct \
 && curl -sfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.21.0 \
 && go get -u github.com/go-delve/delve/cmd/dlv

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
ENV VSCODE_GO_VERSION=0.11.7
RUN apt-get -qq update \
 && apt-get -qq -y install curl zip unzip \
 && curl -L -o Go-${VSCODE_GO_VERSION}.vsix https://github.com/microsoft/vscode-go/releases/download/${VSCODE_GO_VERSION}/Go-${VSCODE_GO_VERSION}.vsix \
 && unzip -q Go-${VSCODE_GO_VERSION}.vsix \
 && rm Go-${VSCODE_GO_VERSION}.vsix \
 && cd /golang/extension \
 && npm install \
 && npm audit fix --force \
 && npm cache clean --force \
 && rm -r node_modules package-lock.json \
 && npm install \
 && npm cache clean --force \
 && rm -rf ~/.npm \
 && cd /golang \
 && zip -q -r Go-${VSCODE_GO_VERSION}.vsix . \
 && apt-get -q -y purge curl zip unzip \
 && apt-get -q -y autoclean \
 && apt-get -q -y autoremove \
 && rm -rf /var/lib/apt/lists \
 && rm -r /golang/extension

WORKDIR /home/coder/project
USER coder
RUN code-server --install-extension /golang/Go-${VSCODE_GO_VERSION}.vsix

USER root
ADD settings.json /home/coder/.local/share/code-server/User/settings.json
RUN cd / \
 && rm -r /golang \
 && chown -hR coder /home/coder

USER coder

