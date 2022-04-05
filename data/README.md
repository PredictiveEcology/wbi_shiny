# Data
> Data related scripts, i.e. compile final data to be displayed by the app.

- [Data](#data)
  - [Processing large files for bird species](#processing-large-files-for-bird-species)
  - [System dependencies](#system-dependencies)
  - [Data processing](#data-processing)
  - [Moving files around](#moving-files-around)
  - [Regional summaries](#regional-summaries)

## Processing large files for bird species

Set up 64 GB RAM VM with Ubuntu 20.04 LTS x64. Log in via `ssh` as `root` and install necessary software (`ssh root@$HOST`):

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

# add rstudio user and password
useradd rstudio
passwd rstudio
sudo mkdir /home/rstudio
sudo chown -R rstudio /home/rstudio

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

Read [how to set up x2go client](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-remote-desktop-with-x2go-on-ubuntu-20-04) to connect to desktop over `ssh`.

Connect to the server using x2go and use the GUI to download file from Google Drive.
You can also use CLI tools to connect to google drive.
You can log into RStudio Server at port `$HOST:8787` and run scripts interactively.

## System dependencies

The following are required for spatial packages:

```bash
apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    libudunits2-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    && rm -rf /var/lib/apt/lists/*
```

Now you can install these: sp, leaflet, raster, rgdal, rgeos, sf.

The [tiler](https://cran.r-project.org/web/packages/tiler/vignettes/tiler-intro.html) package needs Python (>= 2.7) and the python-gdal library (For Windows, gdal installed via OSGeo4W <https://trac.osgeo.org/osgeo4w/> recommended), and clipboard. The install steps are described [here for Windows](https://opensourceoptions.com/blog/how-to-install-gdal-for-python-with-pip-on-windows/) and [here for Mac OS](https://gist.github.com/kelvinn/f14f0fc24445a7994368f984c3e37724?permalink_comment_id=3074415#gistcomment-3074415).

## Data processing

The [`01-process-qs-files.R`](01-process-qs-files.R) file explains how to process the qs files to break up into smaller chunks that one can work on with less memory. The output is a set of parquet files.

The [`02-process-parquet-files.R`](02-process-parquet-files.R) file explains how to iterate on the parquet files and save GeoTIFF files with results at 250 m and 1 km resolutions. We need a raster template (`raster-template-NWT.tif`) for this.

The [`03-process-png-tiles.R`](03-process-png-tiles.R) file explains the process of taking the GeoTIFF files and writing the [TMS](https://en.wikipedia.org/wiki/Tile_Map_Service) tiles.

## Moving files around

Using `rsync` and `cp`. Use `cp` for moving files around on a server, use `rsync` to move files across machines.

```bash
# check if you have rsync
rsync --version

export USER="root"
export HOST="178.128.225.41"

# move files from the server to local machine
rsync -a -P $USER@$HOST:$SRC $DEST

# move files from local machine to server
export DEST="/home/rstudio/analythium/tiff_output/"
export SRC="/Volumes/WD 2020831 A/tmp/wbi/"
rsync -a -P $SRC $USER@$HOST:$DEST

# move files between folders (recursive, keeping attributes), example
cp -a /root/content/public/wbi-nwt/elements/. /root/content/api/v1/public/wbi-nwt/elements/
```

The file organization structure is dictated by the file server (API) structure, which is described in the `scripts` folder of the repository.

## Regional summaries

The [`04-study-area-and-regions.R`](04-study-area-and-regions.R) file describes how we processed regions of interest.

The following regional delineations were used:

- [Terrestrial bird conservation regions](https://www.birdscanada.org/download/gislab/bcr_terrestrial_shape.zip) by NABCI
- [Ecoregions](https://sis.agr.gc.ca/cansis/nsdb/ecostrat/gis_data.html) by the National Ecological Framework for Canada
- [Protected areas](https://www.canada.ca/en/environment-climate-change/services/national-wildlife-areas/protected-conserved-areas-database.html) by CPCAD
- [Important Wildlife Areas In The NWT](https://www.geomatics.gov.nt.ca/en/importantwildlifeareasnwt)

Boundaries from these files were organized into a single sf data frame and saved as R binary and GeoPackage file format (`regions/regions.rds` and `regions/regions.gpkg`).

The [`05-regional-summaries.R`](05-regional-summaries.R) file outlines how to summarize across the layers for each elements (species, etc.).
