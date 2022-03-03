# Server setup and file transfer

Chreate folder structure:

cp -a /root/content/public/wbi-nwt/elements/. /root/content/api/v1/public/wbi-nwt/elements/

```bash
export USER="root"
export HOST="178.128.225.41"

wbi-nwt.analythium.app

ssh $USER@$HOST

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

Move files to the server:


```bash
export DEST="/root/content/public/wbi-nwt/elements/"
export SRC="/Volumes/WD 2020831 A/tmp/wbi2/"

rsync -a -P $SRC $USER@$HOST:$DEST

```

Install Docker
https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04

```bash
# sudo apt-get update
# sudo apt-get install docker-ce docker-ce-cli containerd.io

sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt-cache policy docker-ce
sudo apt install -y docker-ce
sudo apt install docker-compose

sudo systemctl status docker
```

Set firewall (check in cloud UI as well)

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

Set up domain (we set up `wbi-nwt.analythium.app`).

We will use Caddy with Docker Compose.

Move the `site/index.html`, `site/apps.js`, and `site/404.html` files into the `content` folder, this will be the root of the file server.

Move the `site/Caddyfile` and `site/docker-compose.yml` file into the home folder where the `content` directory is located. You can include the custom domain for the HOST variable (line with `- HOST="wbi-nwt.analythium.app"`)

Deploy the stack with `docker-compose up -d`

Now visit the `$HOST` address.

Also check one of the assets:

http://178.128.225.41/api/v1/public/wbi-nwt/elements/bird-alfl/landr-scfm-v4/2011/1000m/mean.tif

http://178.128.225.41/api/v1/public/wbi-nwt/elements/bird-alfl/landr-scfm-v4/2011/preview.html

http://178.128.225.41/api/v1/public/wbi-nwt/elements/bird-alfl/landr-scfm-v4/2011/tiles

http://178.128.225.41/api/v1/public/wbi-nwt/elements/bird-alfl/landr-scfm-v4/2011/tiles/0/0/0.png

https://wbi-nwt.analythium.app/api/v1/public/wbi-nwt/elements/tree-betu-pap/landr-scfm-v4/2011/preview.html

```R
library(raster)
f <- "http://178.128.225.41/api/v1/public/wbi-nwt/elements/bird-alfl/landr-scfm-v4/2011/1000m/mean.tif"

r <- raster(f)
plot(r)

library(leaflet)
tiles <- "https://wbi-nwt.analythium.app/api/v1/public/wbi-nwt/elements/tree-betu-pap/landr-scfm-v4/2011/tiles/{z}/{x}/{y}.png"

leaflet(
  options = leafletOptions(minZoom = 2, maxZoom = 10), width = "100%") %>%
  #addProviderTiles("Esri.WorldImagery") %>%
  addTiles(
    urlTemplate = tiles,
    options = tileOptions(opacity = 0.8)) %>% 
  setView(-100, 60, 0)

```

## Parking lot

https://caddyserver.com/docs/caddyfile/directives/file_server
https://caddyserver.com/docs/caddyfile/directives/basicauth#basicauth
https://caddyserver.com/docs/command-line#caddy-hash-password
https://hub.docker.com/_/caddy
https://github.com/analythium/docker-compose-shiny-example
caddy hash-password --plaintext hiccup

```R
h <- "JDJhJDEwJEVCNmdaNEg2Ti5iejRMYkF3MFZhZ3VtV3E1SzBWZEZ5Q3VWc0tzOEJwZE9TaFlZdEVkZDhX"
pw <- "hiccup"

bb <- base64enc::base64encode(charToRaw(bcrypt::hashpw(pw)))

# this what we get from caddy
cc <- "JDJhJDE0JGFZSE0xbHlQTG5FeTB1NWRDZmZZUE9SRjZYYkdhZktXQU9YSkZTMXNFaGxubDF4QTYxZkJL"

bcrypt::checkpw(pw, h)
bcrypt::checkpw(pw, bb)
bcrypt::checkpw(pw, cc)

```



