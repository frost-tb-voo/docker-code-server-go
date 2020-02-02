FROM golang:buster as golang
MAINTAINER Novs Yama
ARG VCS_REF
LABEL org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/frost-tb-voo/docker-code-server-go"

FROM node as extension
MAINTAINER Novs Yama
ARG VCS_REF
LABEL org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/frost-tb-voo/docker-code-server-go"

ENV VSCODE_GO_VERSION=0.12.0
WORKDIR /golang
RUN git clone https://github.com/microsoft/vscode-go.git \
 && cd ./vscode-go \
 && git checkout ${VSCODE_GO_VERSION} \
 && npm install --silent \
 && npm audit fix --force \
 && npm cache clean --force \
 && rm -rf node_modules package-lock.json \
 && npm install --silent \
 && npm audit fix --force \
 && npm install -g vsce \
 && vsce package \
 && npm cache clean --force \
 && rm -rf ~/.npm \
 && mv *.vsix ../ \
 && cd ../ \
 && rm -rf /golang/vscode-go

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

ADD settings.json /home/coder/.local/share/code-server/User/settings.json
RUN chown -hR coder /home/coder

# https://github.com/Microsoft/vscode-go/wiki/Go-tools-that-the-Go-extension-depends-on
USER coder
ENV GOPATH /home/coder/go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH" \
 && go get -u -v github.com/stamblerre/gocode \
 && go get -u -v github.com/ramya-rao-a/go-outline \
 && go get -u -v github.com/acroca/go-symbols \
 && go get -u -v github.com/uudashr/gopkgs/cmd/gopkgs \
 && go get -u -v golang.org/x/tools/cmd/guru \
 && go get -u -v golang.org/x/tools/cmd/gorename \
 && go get -u -v github.com/sqs/goreturns \
 && go get -u -v golang.org/x/tools/cmd/goimports \
 && go get -u -v github.com/rogpeppe/godef \
 && go get -u -v github.com/zmb3/gogetdoc \
 && go get -u -v golang.org/x/tools/cmd/godoc \
 && go get -u -v github.com/zmb3/gogetdoc \
 && go get -u -v golang.org/x/lint/golint \
 && curl -sfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.21.0 \
 && go get -u -v github.com/mgechev/revive \
 && go get -u -v github.com/go-delve/delve/cmd/dlv \
 && go get -u -v github.com/fatih/gomodifytags \
 && go get -u -v github.com/haya14busa/goplay \
 && go get -u -v github.com/josharian/impl \
 && go get -u -v github.com/tylerb/gotype-live \
 && go get -u -v github.com/cweill/gotests \
 && go get -u -v github.com/sourcegraph/go-langserver \
 && go get -u -v github.com/davidrjenni/reftools/cmd/fillstruct

ENV VSCODE_GO_VERSION=0.12.0
WORKDIR /home/coder/project
COPY --from=extension /golang/Go-${VSCODE_GO_VERSION}.vsix /home/coder/
RUN code-server --install-extension /home/coder/Go-${VSCODE_GO_VERSION}.vsix

