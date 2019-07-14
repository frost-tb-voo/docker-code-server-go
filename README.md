# docker-code-server-go
[![](https://img.shields.io/travis/frost-tb-voo/docker-code-server-go/master.svg?style=flat-square)](https://travis-ci.org/frost-tb-voo/docker-code-server-go/)
[![GitHub stars](https://img.shields.io/github/stars/frost-tb-voo/docker-code-server-go.svg?style=flat-square)](https://github.com/frost-tb-voo/code-server-go/stargazers)
[![GitHub license](https://img.shields.io/github/license/frost-tb-voo/docker-code-server-go.svg?style=flat-square)](https://github.com/frost-tb-voo/code-server-go/blob/master/LICENSE)
[![Docker pulls](https://img.shields.io/docker/pulls/novsyama/code-server-go.svg?style=flat-square)](https://hub.docker.com/r/novsyama/code-server-go)
[![Docker image-size](https://img.shields.io/microbadger/image-size/novsyama/code-server-go.svg?style=flat-square)](https://microbadger.com/images/novsyama/code-server-go)
![Docker layers](https://img.shields.io/microbadger/layers/novsyama/code-server-go.svg?style=flat-square)

An unofficial extended VSCode [code-server](https://github.com/cdr/code-server) image for latest typescript with [vscode-go](https://github.com/microsoft/vscode-go/releases).
See [novsyama/code-server-go](https://hub.docker.com/r/novsyama/code-server-go/)

## How

```bash
ABS_DIR=<workspace absolute path>

sudo docker pull novsyama/code-server-go
sudo docker run --name=vscode --net=host -d \
 -v "${ABS_DIR}:/home/coder/project" \
 -w /home/coder/project \
 novsyama/code-server-go \
 code-server \
 --allow-http --no-auth
```

And open http://localhost:8443 with your favorites browser.
For detail options, see [code-server](https://github.com/cdr/code-server).

### Pathes of vscode code-server
If you want to preserve the settings and extensions, please mount following pathes with `-v` option of `docker run` command.

- Home : /home/coder
- Extension path : ~/.local/share/code-server/extensions
- Settings path : ~/.local/share/code-server/User/settings.json
- GOPATH : ~/go

