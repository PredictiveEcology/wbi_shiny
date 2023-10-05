# Set up a cloud VM

> This page describes how to set up and host the data and the apps on Digital Research Alliance.
Previous setup scripts in the [`old`](./old/) directory refer to the DigitalOcean server that is not live any more.

- [Set up a cloud VM](#set-up-a-cloud-vm)
  - [Adding SSH keys](#adding-ssh-keys)
  - [Install system requirements for hosting](#install-system-requirements-for-hosting)
    - [Install Docker](#install-docker)
    - [Set firewall](#set-firewall)
  - [Mount a volume](#mount-a-volume)
      - [Partition](#partition)
      - [Format](#format)
      - [Mount](#mount)
      - [Unmounting](#unmounting)
  - [Scaffolding the file server folder](#scaffolding-the-file-server-folder)
  - [Static WBI website](#static-wbi-website)
  - [Migrating files](#migrating-files)
      - [Migrating files](#migrating-files-1)
      - [Setting up R and GDAL to process TIFs](#setting-up-r-and-gdal-to-process-tifs)
      - [Generating long/lat version of 1k rasters](#generating-longlat-version-of-1k-rasters)
  - [The Shiny app](#the-shiny-app)
  - [Deployment](#deployment)
  - [Custom domain and TLS](#custom-domain-and-tls)
  - [Updating the server configs](#updating-the-server-configs)
  - [Restricted access](#restricted-access)

We are using the Arbutus Cloud from Digital Research Alliance (former Compute Canada):
<https://arbutus.cloud.computecanada.ca/>.

- Log into the dashboard with your CCID
- Click "Key Pairs" and create a key pair or upload a public key that you can use later for `ssh`
- Click "Instances" then click "Launch Instance"
- Give a name, description
  - pick availability zone "Persistent_01"
  - leave count at 1
- Boot source: image
  - Create New Volume: No
  - Search for Ubuntu and pick Ubuntu 22.04 at least
- Flavor: p4-8gb (4 vCPUs, 8 GB RAM, 20 GB root disk)
- Networks: select both `def-stevec-subnet` and `IPv6`
- Security groups: add the wbi group that has SSH, HTTP, HTTPS ports defined for ingress
- Add a key pair
- Click Create

You should see the instance state "Running"

Read more: <https://docs.alliancecan.ca/wiki/Cloud_Quick_Start>

Once the instance is created, allocate a floating IP and associate with the instance. This will connect the instance to the public network. Copy the floating IP address for ssh login:

```bash
export USER="ubuntu"
export HOST="206.12.95.40"

ssh $USER@$HOST
```

Change to the root user with `sudo -i` to continue with the installation.

## Adding SSH keys

If you want to add new public keys for additional admin users:

- edit the file `/root/.ssh/authorized_keys` with `nano` or `vim`
- add the public key at a new line
- save and exit

## Install system requirements for hosting

Using Ubuntu 22.04 LTS x64 machine image.
Here we install system requirements for hosting (not for data processing).

### Install Docker

We are following [this](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-22-04) tutorial

```bash
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
apt-cache policy docker-ce

sudo apt install docker-ce
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

## Mount a volume

Go to the dashboard:

- click Volumes, then Volumes
- there is a 5TB volume available (`cac0f4fd-c85b-47f0-bf74-90cb4f4cae5b`), click the dropdown
- select Manage Attachments
- select the instance (`wbi`) and click Attach Volume (you'll see it is attached to `/dev/vdb`)

**The next section will need to be run only on first mount, no need to format later when there are data stored on the volume!**

#### Partition

For volumes up to 2TB, follow: <https://docs.alliancecan.ca/wiki/Using_a_new_empty_volume_on_a_Linux_VM>.
Create a partition on the volume with `fdisk /dev/vdb`. At the prompt, use this sequence:

- `n` => new partition
- `p` => primary, only one partition on disk
- `2` => partition number 2
- `<return>` => first sector (use default)
- `w` => write partition table to disk and exit

`fdisk -l /dev/vdb` will give you the info.

For volumes > 2TB, follow: <https://www.dell.com/support/kbdoc/en-ca/000140053/how-to-create-a-linux-partition-larger-than-2-terabytes>.
Type `parted /dev/vdb`. At the prompt, use this sequence:

- `unit GB` to set unit to GB,
- `mklabel gpt` to create a new partition table,
- `mkpart primary 0 5000GB` to define the start and end,
- then `quit`.

`parted /dev/vdb print` will give you the info.

#### Format

Format with `mkfs -t ext4 /dev/vdb1`. 

#### Mount

```bash
# create a directory
mkdir /media/data

# mount the volume
mount /dev/vdb1 /media/data

# check available space
df -k --block-size=G
```

If the VM is rebooted, the volume will need to be remounted. To cause the VM to mount the volume automatically at boot time, edit `/etc/fstab` and add a line like:

```
/dev/vdb1 /media/data ext4 defaults 0 2
```

#### Unmounting

If you need to remove a volume or other device for some reason, for example to create image from it, or to attach it to a different VM, it is best to unmount it first. Unmounting a volume before detaching it helps prevent data corruption.

To unmount our previously mounted volume above, use the following command: `umount /media/data`.

This command will work if no files are being accessed by the operating system or any other program running on the VM. This can be both reading and writing to files. If this is the case, when you try to unmount a volume, you will get a message letting you know that the volume is still busy and it won't be unmounted.

## Scaffolding the file server folder

Create a `/media/data` directory with `mkdir /media/data` if it does not already exists (note: `/media/data` is the mount point for the volume described above).

Create folder structure inside the `/media/data` folder: `cd /media/data` into this folder, commands are relative to this location.

```bash
mkdir content
mkdir content/api
mkdir content/api/v1
mkdir content/api/v1/public
mkdir content/api/v1/public/wbi-nwt
mkdir content/api/v1/public/wbi-nwt/elements
mkdir content/api/v1/private
mkdir content/api/v1/private/wbi-nwt
```

## Static WBI website

Move the `site/Caddyfile` and `site/docker-compose.yml` file into the home folder (`~`):

```bash
rsync -a -P $(pwd)/01-cloud-vm/Caddyfile $USER@$HOST:/home/ubuntu/Caddyfile
rsync -a -P $(pwd)/01-cloud-vm/docker-compose.yml $USER@$HOST:/home/ubuntu/docker-compose.yml
rsync -a -P $(pwd)/01-cloud-vm/site/ $USER@$HOST:/home/ubuntu/site/
```

Log in with `ssh $USER@$HOST`, `sudo -i`, and copy the files:

```bash
cp -a /home/ubuntu/Caddyfile /root/Caddyfile
cp -a /home/ubuntu/docker-compose.yml /root/docker-compose.yml

cp -a /home/ubuntu/site/. /media/data/content
```

The `site` folder includes the `index.html`, `404.html`, and other files.
The `content` folder, this will be the root of the file server.

## Migrating files

This section is related to migration and can safely be ignored for future updates, but is kept here for reference. Note: `wbi-nwt.analythium.app` was the domain for the NWT project.

#### Migrating files

Set up ssh key between the machines:

```bash
su - root -c 'ssh-keygen -t rsa -q -f "/root/.ssh/id_rsa" -N ""'
cat /root/.ssh/id_rsa.pub 
# copy this key into /root/.ssh/authorized_keys on the other machine
ssh root@wbi-nwt.analythium.app
```

```R
f <- list.files("/root/content/api", recursive=TRUE)
ex <- tools::file_ext(f)
f2 <- f[ex %in% c("json","tif")]
for (i in seq_along(f2)) {
  message(i, ": ", f2[i])
  x <- f2[i]
  ds <- strsplit(x, "/")[[1]]
  ds <- ds[-length(ds)]
  for (j in seq_along(ds)) {
    dir.create(
      paste0("/root/content2/api/", paste0(ds[1:j], collapse="/"))
    )
  }
  file.copy(
    paste0("/root/content/api/", f2[i]),
    paste0("/root/content2/api/", f2[i])
  )
}

f3 <- list.files("/root/content2/api", recursive=TRUE)
```

```bash
rsync -av root@wbi-nwt.analythium.app:/root/content/api/v1/private/wbi-nwt/index.html /media/data/content/api/v1/private/wbi-nwt/index.html
rsync -av root@wbi-nwt.analythium.app:/root/content2/api/ /media/data/content/api
```

Moving all files using `tmux` to run processes in the background even after we log out of the server:

- `tmux new -s bench` for new session
- Ctrl+B then D to exit without stopping the processes
- `tmux a` to go back
- Ctrl+B then X to stop the session (answer yes)

```bash
ssh $USER@$HOST

sudo -i

## examples
# tmux                         # start new
# tmux new -s myname           # start new with session name
# tmux a                       #  (or at, or attach)
# tmux a -t myname             # attach to named
# tmux ls                      # list sessions
# tmux kill-session -t myname  # kill session
# tmux ls | grep : | cut -d. -f1 | awk '{print substr($1, 0, length($1)-1)}' | xargs kill # Kill all the tmux sessions:

tmux new -s migrate

export DIR=v1/public/wbi-nwt/elements
rsync --ignore-existing -hvrPt root@wbi-nwt.analythium.app:/root/content/api/${DIR}/ /media/data/content/api/${DIR}
```

It is also a good idea to give the ubuntu user permission to the `/media/data/content` folder: `sudo chown -R ubuntu:ubuntu /media/data/content`.
Otherwise `rsync` might now work, i.e. you'll have to move file in 2 steps and the VM hard drive outside of the mounted volume might not be large enough to do that efficiently.

#### Setting up R and GDAL to process TIFs

```bash
## --- Set up R with BSPM a la r2u ---
## from https://github.com/eddelbuettel/r-ci/blob/master/docs/run.sh

Retry() {
    if "$@"; then
        return 0
    fi
    for wait_time in 5 20 30 60; do
        echo "Command failed, retrying in ${wait_time} ..."
        sleep ${wait_time}
        if "$@"; then
            return 0
        fi
    done
    echo "Failed all retries!"
    exit 1
}

## Check for sudo_release and install if needed
test -x /usr/bin/sudo || apt-get install -y --no-install-recommends sudo
## Hotfix for key issue
echo 'Acquire::AllowInsecureRepositories "true";' | sudo tee /etc/apt/apt.conf.d/90local-secure >/dev/null

## Check for lsb_release and install if needed
test -x /usr/bin/lsb_release || sudo apt-get install -y --no-install-recommends lsb-release
## Check for add-apt-repository and install if needed, using a fudge around the (manual) tz config dialog
test -x /usr/bin/add-apt-repository || \
(echo 12 > /tmp/input.txt; echo 5 >> /tmp/input.txt; sudo apt-get install -y tzdata < /tmp/input.txt; sudo apt-get install -y --no-install-recommends software-properties-common)

## from r2u setup script
sudo apt update -qq && sudo apt install --yes --no-install-recommends wget ca-certificates dirmngr gnupg gpg-agent
wget -q -O- https://eddelbuettel.github.io/r2u/assets/dirk_eddelbuettel_key.asc | sudo tee -a /etc/apt/trusted.gpg.d/cranapt_key.asc
echo "deb [arch=amd64] https://r2u.stat.illinois.edu/ubuntu $(lsb_release -cs) main" | sudo tee -a /etc/apt/sources.list.d/cranapt.list
wget -q -O- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc  | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
echo "deb [arch=amd64] https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" | sudo tee -a /etc/apt/sources.list.d/cran_r.list
echo "Package: *" | sudo tee -a /etc/apt/preferences.d/99cranapt
echo "Pin: release o=CRAN-Apt Project" | sudo tee -a /etc/apt/preferences.d/99cranapt
echo "Pin: release l=CRAN-Apt Packages" | sudo tee -a /etc/apt/preferences.d/99cranapt
echo "Pin-Priority: 700" | sudo tee -a /etc/apt/preferences.d/99cranapt

# Update after adding all repositories.  Retry several times to work around
# flaky connection to Launchpad PPAs.
Retry sudo apt-get update -qq
Retry sudo apt-get upgrade

# Install an R development environment. qpdf is also needed for
# --as-cran checks:
#   https://stat.ethz.ch/pipermail/r-help//2012-September/335676.html
# May 2020: we also need devscripts for checkbashism
# Sep 2020: add bspm and remotes
Retry sudo apt-get install -y --no-install-recommends r-base r-base-dev r-recommended qpdf devscripts r-cran-bspm r-cran-remotes

# Default to no recommends
echo 'APT::Install-Recommends "false";' | sudo tee /etc/apt/apt.conf.d/90local-no-recommends >/dev/null

# Change permissions for /usr/local/lib/R/site-library
# This should really be via 'staff adduser travis staff'
# but that may affect only the next shell
sudo chmod 2777 /usr/local/lib/R /usr/local/lib/R/site-library

# We add a backports PPA for more recent TeX packages.
# sudo add-apt-repository -y "ppa:texlive-backports/ppa"
Retry sudo apt-get install -y --no-install-recommends \
        texlive-base texlive-latex-base \
        texlive-fonts-recommended texlive-fonts-extra \
        texlive-extra-utils texlive-latex-recommended texlive-latex-extra \
        texinfo lmodern
# no longer exists: texlive-generic-recommended

echo "suppressMessages(bspm::enable())" | sudo tee --append /etc/R/Rprofile.site >/dev/null
echo "options(bspm.version.check=FALSE)" | sudo tee --append /etc/R/Rprofile.site >/dev/null

## spatial libs
sudo add-apt-repository ppa:ubuntugis/ppa && sudo apt-get update
sudo apt-get install gdal-bin libgdal-dev
export CPLUS_INCLUDE_PATH=/usr/include/gdal
export C_INCLUDE_PATH=/usr/include/gdal
sudo apt install python-is-python3 python3-gdal python3-pip
pip install GDAL
R -q -e 'install.packages(c("rgdal","raster","png","tiler","terra","sf","stars"))'
```

#### Generating long/lat version of 1k rasters

```R
f <- list.files("/media/data/content/api", recursive=TRUE)

f1k <- f[endsWith(f, "1000m/mean.tif")]
f1k <- paste0("/media/data/content/api/", f1k)
o1k <- gsub("/1000m/", "/lonlat/", f1k)

library(raster)
library(stars)
rt <- raster("https://peter.solymos.org/testapi/amro1k.tif")

#i <- 1
for (i in 1:length(f1k)) {
  message("Writing file ", i)
  r <- raster(f1k[i])
  r2 <- projectRaster(r, rt)
  s2 <- st_as_stars(r2)
  dr <- gsub("/mean.tif", "/", o1k[i])
  if (!dir.exists(dr))
    dir.create(dr)
  write_stars(s2, o1k[i], options = c("COMPRESS=LZW"))
}
## TODO
## - need to catch extremes (by percentile)
## - register max values

f1k <- f[endsWith(f, "lonlat/mean.tif")]
f1k <- paste0("/media/data/content/api/", f1k)
for (i in 1:length(f1k)) {
  message("Writing file ", i)
  r <- raster(f1k[i])
  q <- quantile(values(r), 0.999, na.rm=TRUE)
  values(r)[!is.na(values(r)) & values(r) > q] <- q
  s2 <- st_as_stars(r)
  write_stars(s2, f1k[i], options = c("COMPRESS=LZW"))
}
```

## The Shiny app

We deploy the Shiny app using [Docker](https://www.docker.com/).

The `app/Dockerfile` is generated by the {golem} package. We had to modify the {golem}-generated Dockerfile to allow the loading of data sets (via loading the package in the `app` directory) and adding a non-privileged user (`shiny` user) to make the app and our deployment more secure.

We use this to build a Docker image:

```bash
cd app
export TAG="psolymos/shinywbi:v2"
docker build -t $TAG .
```

Test the app locally:

```bash
docker run -p 8080:8080 $TAG
```

Now open `http://localhost:8080` in your browser.

Push to Docker Hub: `docker push $TAG`.

The server will pull the image upon deployment.

## Deployment

We will use [Caddy Server](https://caddyserver.com) with Docker Compose. Caddy takes care of redirects, obtaining and renewing TLS/SSL certificates for HTTPS. The setup by default uses HTTP (`$HOST:80`). Once you add a custom domain, it will start serving over HTTPS.

Deploy the stack with `docker-compose up -d` from the home (`~`) folder. Where you have the Caddyfile and the compose YAML matters, because the Caddy service is looking for the Caddyfile in the current directory (`$PWD`).

Now visit the `$HOST` address to see the landing page and navigate to the Shiny app.

If you need to test the file server, you might want to use the contents of the `Caddyfile-CORS` to allow cross-origin resource sharing (CORS).

## Custom domain and TLS

Set up domain (we set up `wbi.predictiveecology.org`) with your DNS provider: and an A or AAA recird for the domain/subdomain, and add the `$HOST` IPv4 address.

You can include the custom domain for the `$HOST` variable by editing the compose file: look for the line with `- HOST=":80"` and change it to `- HOST="wbi.predictiveecology.org"`.

Then use `docker-compose up -d` and Docker Compose will pick up the changes and restart the Caddy service (without interrupting other services).

## Updating the server configs

If you change the Caddyfile, it will not be picked up by Docker Compose.

Use `docker-compose restart caddy` command.

## Restricted access

The `$HOST/api/v1/private/*` routes are password protected using [HTTP basic authentication](https://caddyserver.com/docs/caddyfile/directives/basicauth). The Caddyfile contains the hashed and encoded password.

Here is the R code to generate the hashed password to be entered into the Caddyfile:

```R
base64enc::base64encode(charToRaw(bcrypt::hashpw("shiny")))
```

The current username:password is set to `shiny:shiny`.

This form of authentication is only secure over HTTPS because password is transmitted as encoded plain text.

Example: <https://wbi.predictiveecology.org/api/v1/private/wbi-nwt/index.html>
