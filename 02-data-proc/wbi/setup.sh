#!/bin/bash

# set up on host 2

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


## --- install RStudio Server ---

apt-get -y install gdebi-core

# requisites for different R packages
# this aims at covering as much packages as possible
# see https://packagemanager.rstudio.com/client/#/repos/1/overview
# and also
# https://geocompr.github.io/post/2020/installing-r-spatial-ubuntu/
# http://dirk.eddelbuettel.com/blog/2020/06/22#027_ubuntu_binaries
# this a broad, general setup, no fine detail here
apt-get -y install libopenblas-dev libsodium-dev texlive default-jdk
R CMD javareconf

# install RStudio Server
# strage issue: https://community.rstudio.com/t/dependency-error-when-installing-rstudio-on-ubuntu-22-04-with-libssl/135397/2
wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb
sudo dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb
rm libssl1.1_1.1.1f-1ubuntu2_amd64.deb

RSTUDIO_VER=2023.03.0-386
wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-${RSTUDIO_VER}-amd64.deb
gdebi --n rstudio-server-${RSTUDIO_VER}-amd64.deb
rm rstudio-server-${RSTUDIO_VER}-amd64.deb


# spatial deps
export CPLUS_INCLUDE_PATH=/usr/include/gdal
export C_INCLUDE_PATH=/usr/include/gdal
add-apt-repository ppa:ubuntugis/ppa && sudo apt-get update
Retry sudo apt-get install -y --no-install-recommends gdal-bin libgdal-dev python3-pip python-is-python3 python3-gdal
pip install GDAL

apt install r-cran-rgdal r-cran-raster r-cran-png
R -q -e 'install.packages("tiler")'



## --- Install Caddy Server ---
## https://caddyserver.com/docs/install#debian-ubuntu-raspbian
apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
apt update
apt install -y caddy


# cat <<EOF > /etc/caddy/Caddyfile
# :80 {
#         reverse_proxy 127.0.0.1:8787
# }
# EOF

cat <<EOF > /etc/caddy/Caddyfile
wbi-donkey.analythium.cloud {
        reverse_proxy 127.0.0.1:8787
}
EOF

systemctl reload caddy


## Set up firewall rules
apt-get -y install ufw
ufw allow ssh
ufw allow http
ufw allow https
ufw allow 8787
ufw enable

# add rstudio user and password (make it admin so it can access files without moving them to home folder)
useradd rstudio
passwd rstudio
mkdir /home/rstudio
chown -R rstudio /home/rstudio
usermod -aG rstudio rstudio
usermod -aG sudo rstudio
