ARG VSCODE_GO_VERSION=0.26.0

FROM golang:buster as golang

FROM node:12 as extension
ARG VSCODE_GO_VERSION

WORKDIR /golang
RUN git clone https://github.com/golang/vscode-go.git \
 && cd ./vscode-go \
 && git checkout v${VSCODE_GO_VERSION} \
 && npm audit fix --force \
 && npm install --silent --audit=false\
 && npm install -g vsce \
 && vsce package \
 && npm cache clean --force \
 && rm -rf node_modules package-lock.json \
 && rm -rf ~/.npm \
 && mv *.vsix ../ \
 && cd ../ \
 && rm -rf /golang/vscode-go

FROM codercom/code-server
ARG VCS_REF
ARG VSCODE_GO_VERSION

LABEL maintainer="Novs Yama"
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
ADD settings.json /home/coder/.local/share/code-server/Machine
ADD settings.json /home/coder/project/.vscode/settings.json
COPY --from=extension /golang/go-${VSCODE_GO_VERSION}.vsix /home/coder/
RUN chown -hR coder /home/coder

# https://github.com/golang/vscode-go/blob/master/docs/tools.md
USER coder
ENV GOPATH /home/coder/go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH" \
 && GO111MODULE=on go get golang.org/x/tools/gopls@latest \
 && go get -u github.com/go-delve/delve/cmd/dlv \
 && go get -u github.com/stamblerre/gocode \
 && go get -u github.com/ramya-rao-a/go-outline \
 && go get -u github.com/acroca/go-symbols \
 && go get -u golang.org/x/tools/cmd/guru \
 && go get -u golang.org/x/tools/cmd/gorename \
 && go get -u github.com/sqs/goreturns \
 && go get -u golang.org/x/tools/cmd/goimports \
 && go get -u github.com/rogpeppe/godef \
 && go get -u github.com/zmb3/gogetdoc \
 && go get -u golang.org/x/tools/cmd/godoc \
 && go get -u github.com/zmb3/gogetdoc \
 && go get -u golang.org/x/lint/golint \
 && curl -sfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.21.0 \
 && go get -u github.com/mgechev/revive \
 && go get -u github.com/fatih/gomodifytags \
 && go get -u github.com/haya14busa/goplay \
 && go get -u github.com/josharian/impl \
 && go get -u github.com/tylerb/gotype-live \
 && go get -u github.com/cweill/gotests \
 && go get -u github.com/davidrjenni/reftools/cmd/fillstruct

WORKDIR /home/coder/project
RUN code-server --install-extension /home/coder/go-${VSCODE_GO_VERSION}.vsix

