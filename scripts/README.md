# Scripts

Scripts related to deployment, hosting, data migration.

## Processing large files for bird species

Set up 64 GB RAM VM with Ubuntu 20.04 LTS x64. Log in via `ssh` as `root` and install necessary software (`ssh root@IP_ADDRESS`):

```bash
## Install R
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/"
apt update
apt-get install -y r-base

## Install RStudio Server Open Source
add-apt-repository -y ppa:opencpu/opencpu-2.2
apt update
apt-get install -y rstudio-server

## Set up firewall rules
ufw allow ssh
ufw allow http
ufw allow https
ufw allow 8787
ufw enable


# remove:
# sudo deluser --remove-home $USER

useradd peter
passwd peter
sudo mkdir /home/peter
sudo chown -R peter /home/peter

useradd pacha
passwd pacha
sudo mkdir /home/pacha
sudo chown -R peter /home/pacha


## Install Ubuntu Desktop
apt-get install xubuntu-desktop
apt-get install xubuntu-core
## Install x2go for remote sessions
apt-get install x2goserver x2goserver-xsession
apt-get install x2goclient
## Prevent freezing the client by removing the screen saver
apt remove xfce4-screensaver

## need to reboot
reboot
```

Read how to set up x2go client to connect to desktop over `ssh`: <https://www.digitalocean.com/community/tutorials/how-to-set-up-a-remote-desktop-with-x2go-on-ubuntu-20-04>