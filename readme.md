`Serve.sh`
================================================
Serve any directory as a public HTTP web site

`serve.sh` can serve a Laravel site if your target directory is a Laravel project and a php environment can be detected, otherwise the directory will be serve as a simple static website

# Requirements

1. install python from https://www.python.org/downloads/
1. download `cloudflared`
   from https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/installation/
1. place the `cloudflared` to any directory which is included in your system env $PATH

# Install

1. download `serve.sh` to any place

# Usage

```bash
sh your-path/serve.sh -d dir-path [-p your-port]
```