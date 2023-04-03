# Set up a cloud VM

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

Change to root user with `sudo -i` to continue with the installation.

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

- `unit GB` to set unit to TB,
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

#### Unmounting

If you need to remove a volume or other device for some reason, for example to create image from it, or to attach it to a different VM, it is best to unmount it first. Unmounting a volume before detaching it helps prevent data corruption.

To unmount our previously mounted volume above, use the following command: `umount /media/data`.

This command will work if no files are being accessed by the operating system or any other program running on the VM. This can be both reading and writing to files. If this is the case, when you try to unmount a volume, you will get a message letting you know that the volume is still busy and it won't be unmounted.

## Scaffolding the file server folder

Create a `/media/data/content` directory with `mkdir /media/data/content`.

Create folder structure inside the `/media/data/content` folder: `cd` into this folder, commands are relative to this folder.

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

Log in with `ssh $USER@$HOST`, `sudo -i`, and the files:

```bash
cp -a /home/ubuntu/Caddyfile /root/Caddyfile
cp -a /home/ubuntu/docker-compose.yml /root/docker-compose.yml
cp -a /home/ubuntu/site/. /root/content
```

The `site` folder includes the `index.html`, `404.html`, and other files.
The `content` folder, this will be the root of the file server.

## The Shiny app

We deploy the Shiny app using [Docker](https://www.docker.com/).

The `app/Dockerfile` is generated by the {golem} package. We had to modify the {golem}-generated Dockerfile to allow the loading of data sets (via loading the package in the `app` directory) and adding a non-privileged user (`shiny` user) to make the app and our deployment more secure.

We use this to build a Docker image:

```bash
export TAG="psolymos/shinywbi:v1"
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

## Custom domain and TLS

Set up domain (we set up `wbi-nwt.analythium.app`) with your DNS provider: and an A or AAA recird for the domain/subdomain, and add the `$HOST` IPv4 address.

You can include the custom domain for the `$HOST` variable by editing the compose file: look for the line with `- HOST=":80"` and change it to `- HOST="wbi-nwt.analythium.app"`.

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

Example: <https://wbi-nwt.analythium.app/api/v1/private/wbi-nwt/index.html>
