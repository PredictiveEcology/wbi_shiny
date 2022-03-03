# Scripts
> Scripts related to deployment, hosting, data migration.

- [Scripts](#scripts)
  - [Overview](#overview)
  - [Server setup and file transfer](#server-setup-and-file-transfer)
  - [Install system requirements](#install-system-requirements)
    - [Install Docker](#install-docker)
    - [Set firewall](#set-firewall)
  - [Shiny app](#shiny-app)
  - [Deployment](#deployment)
  - [Custom domain and TLS](#custom-domain-and-tls)
  - [Updating the server configs](#updating-the-server-configs)

## Overview

- `$HOST/` static file root will have `index.html` with a general outline and links to follow (apps, methods etc) and a 404 (page not found)
- `$HOST/apps/` is static file folder with a list of available apps
  - `$HOST/apps/nwt/` will proxy to the Shiny app (other apps later as `$HOST/apps/<appname>/`)
- `$HOST/api/v1` holds the static file assets required for the apps

## Server setup and file transfer

`ssh` into your server:

```bash
export USER="root"
export HOST="178.128.225.41"

ssh $USER@$HOST
```

Create folder structure insode the folder of your choce (makes sense to use a home folder, i.e. `~` directory). `cd` into this folder, commands are relative to this folder.

```bash
mkdir content
mkdir content/api
mkdir content/api/v1
mkdir content/api/v1/public
mkdir content/api/v1/public/wbi-nwt
mkdir content/api/v1/public/wbi-nwt/elements
mkdir content/api/v1/private
mkdir content/api/v1/private/wbi-nwt
exit
```

Move elements (species, variables) related files (preprocessed tif and png) to the server:

```bash
export SRC="/Volumes/WD 2020831 A/tmp/wbi2/"
export DEST="/root/content/public/wbi-nwt/elements/"

rsync -a -P $SRC $USER@$HOST:$DEST
```

## Install system requirements

Using Ubuntu 20.04 LTS x64 machine image.


Here we install system requirements for hosting (not for data processing).

### Install Docker

We are following [this](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04) tutorial

```bash
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt-cache policy docker-ce

sudo apt install -y docker-ce
sudo apt install docker-compose

## check if docker process is running
sudo systemctl status docker
```

### Set firewall

We install `ufw` (uncomplicated firewall) and set it up to allow all outgoing traffic and allow incoming only on select ports (SSH, HTTP, HTTPS).

Check in your cloud provider's dashboard, sometimes you have to set security rules in their UI as well.

```bash
sudo apt install ufw

sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw enable

ufw status
```

## Shiny app

The shiny app deployment to be described here (using Docker).

## Deployment

We will use [Caddy Server](https://caddyserver.com) with Docker Compose. Caddy takes care of redirects, obtaining and renewing TLS/SSL certificates for HTTPS. The setup by default uses HTTP (`$HOST:80`). Once you add a custom domain, it will start serving over HTTPS.

Move the `site/Caddyfile` and `site/docker-compose.yml` file into the home folder (`~`) where the `content` directory is located. 

Move the `site/index.html`, `site/apps.js`, and `site/404.html` files into the `content` folder, this will be the root of the file server.

Deploy the stack with `docker-compose up -d` from the home (`~`) folder. Where you have the Caddyfile and the compose YAML matters, because the Caddy service is looking for the Caddyfile in the current directort (`$PWD`).

Now visit the `$HOST` address to see the landing page and navigate to the Shiny app.

## Custom domain and TLS

Set up domain (we set up `wbi-nwt.analythium.app`) with your DNS provider: and an A or AAA recird for the domain/subdomain, and add the `$HOST` IPv4 address.

You can include the custom domain for the `$HOST` variable by editing the compose file: look for the line with `- HOST=":80"` and change it to `- HOST="wbi-nwt.analythium.app"`.

Then use `docker-compose up -d` and Docker Compose will pick up the changes and restart the Caddy service (without interrupting other services).

## Updating the server configs

If you change the Caddyfile, it will not be picked up by Docker Compose.

Use `docker-compose restart caddy` command.
