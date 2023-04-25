# Get data from Narval processed

Log into Narval: <https://docs.alliancecan.ca/wiki/Narval/en>

```bash
export USER=psolymos
export HOST=narval.computecanada.ca
ssh $USER@$HOST

# you'll be in /home/psolymos
cd projects/rrg-stevec/achubaty/wbi_data/WBI_forecasts/outputs
du -sh # get disk usage is 2.6TB

# Copy single file from Narval to local machine
SRC=/home/psolymos/projects/rrg-stevec/achubaty/wbi_data/WBI_forecasts/outputs/AB_CanESM5_SSP370_run01.tar.gz
DEST=/Users/Peter/tmp/narval/outputs
rsync -a -P $USER@$HOST:$SRC $DEST
```

Files to move (ssh did not work between the 2 hosts):

- Narval to local
- local to host2

```bash
# run 01 ro 05
AB_CanESM5_SSP370_run01.tar.gz
AB_CanESM5_SSP585_run01.tar.gz
AB_CNRM-ESM2-1_SSP370_run01.tar.gz
AB_CNRM-ESM2-1_SSP585_run01.tar.gz
# run aa to an
AB.tar.gz.aa


BC_CanESM5_SSP370_run01.tar.gz
BC_CanESM5_SSP585_run01.tar.gz
BC_CNRM-ESM2-1_SSP370_run01.tar.gz
BC_CNRM-ESM2-1_SSP585_run01.tar.gz
# run aa to ai
BC.tar.gz.aa


MB_CanESM5_SSP370_run01.tar.gz
MB_CanESM5_SSP585_run01.tar.gz
MB_CNRM-ESM2-1_SSP370_run01.tar.gz
MB_CNRM-ESM2-1_SSP585_run01.tar.gz
# run aa to ao
MB.tar.gz.aa


NT_CanESM5_SSP370_run01.tar.gz
NT_CanESM5_SSP585_run01.tar.gz
NT_CNRM-ESM2-1_SSP370_run01.tar.gz
NT_CNRM-ESM2-1_SSP585_run01.tar.gz
# run aa to ay
NT.tar.gz.aa


SK_CanESM5_SSP370_run01.tar.gz
SK_CanESM5_SSP585_run01.tar.gz
SK_CNRM-ESM2-1_SSP370_run01.tar.gz
SK_CNRM-ESM2-1_SSP585_run01.tar.gz
# run aa to aj
SK.tar.gz.aa


YT_CanESM5_SSP370_run01.tar.gz
YT_CanESM5_SSP585_run01.tar.gz
YT_CNRM-ESM2-1_SSP370_run01.tar.gz
YT_CNRM-ESM2-1_SSP585_run01.tar.gz
# run aa to al
YT.tar.gz.aa


# there is also aa to cn
summary.tar.gz.aa

```

Move to local: this can be run directly on te host 2 server, using `tmux`

```bash
# Copy single file from Narval to local machine

# Done
SRC=/home/psolymos/projects/rrg-stevec/achubaty/wbi_data/WBI_forecasts/outputs/AB*
SRC=/home/psolymos/projects/rrg-stevec/achubaty/wbi_data/WBI_forecasts/outputs/BC*
SRC=/home/psolymos/projects/rrg-stevec/achubaty/wbi_data/WBI_forecasts/outputs/SK*

# Not done
SRC=/home/psolymos/projects/rrg-stevec/achubaty/wbi_data/WBI_forecasts/outputs/NT*
SRC=/home/psolymos/projects/rrg-stevec/achubaty/wbi_data/WBI_forecasts/outputs/MB*
SRC=/home/psolymos/projects/rrg-stevec/achubaty/wbi_data/WBI_forecasts/outputs/YT*

SRC=/home/psolymos/projects/rrg-stevec/achubaty/wbi_data/WBI_forecasts/outputs/summary.tar.gz.*

SRC=/home/psolymos/projects/rrg-stevec/achubaty/wbi_data/WBI_forecasts/outputs_postprocess.zip

# DEST=/Users/Peter/tmp/narval/outputs
DEST=/mnt/volume_tor1_01/wbi/outputs2
rsync -Pav $USER@$HOST:$SRC $DEST
```

Once it is there, unpack & process

```bash
cd /mnt/volume_tor1_01/wbi/outputs/

du -sh /mnt/volume_tor1_01

# this will recreate the AB folder
cat AB.tar.gz.* | tar xvfz -
cat BC.tar.gz.* | tar xvfz -

# this will copy things into outputs folder
export PROV=BC
# export SCEN=CNRM-ESM2-1_SSP370
# export SCEN=CNRM-ESM2-1_SSP585
# export SCEN=CanESM5_SSP370
export SCEN=CanESM5_SSP585

du -sh $(pwd)
du -sh /mnt/volume_tor1_01/wbi

export RUN=1
tar -xvf ${PROV}_${SCEN}_run0${RUN}.tar.gz
rm -rf /mnt/volume_tor1_01/wbi/outputs/outputs/${PROV}_${SCEN}_run0${RUN}/*.qs
rm -rf /mnt/volume_tor1_01/wbi/outputs/outputs/${PROV}_${SCEN}_run0${RUN}/pixelGroupMap*
rm -rf /mnt/volume_tor1_01/wbi/outputs/outputs/${PROV}_${SCEN}_run0${RUN}/mortalityMap*
rm -rf /mnt/volume_tor1_01/wbi/outputs/outputs/${PROV}_${SCEN}_run0${RUN}/fireSense*
rm -rf /mnt/volume_tor1_01/wbi/outputs/outputs/${PROV}_${SCEN}_run0${RUN}/ANPPMap*

export RUN=2
tar -xvf ${PROV}_${SCEN}_run0${RUN}.tar.gz
rm -rf /mnt/volume_tor1_01/wbi/outputs/outputs/${PROV}_${SCEN}_run0${RUN}/*.qs
rm -rf /mnt/volume_tor1_01/wbi/outputs/outputs/${PROV}_${SCEN}_run0${RUN}/pixelGroupMap*
rm -rf /mnt/volume_tor1_01/wbi/outputs/outputs/${PROV}_${SCEN}_run0${RUN}/mortalityMap*
rm -rf /mnt/volume_tor1_01/wbi/outputs/outputs/${PROV}_${SCEN}_run0${RUN}/fireSense*
rm -rf /mnt/volume_tor1_01/wbi/outputs/outputs/${PROV}_${SCEN}_run0${RUN}/ANPPMap*

export RUN=3
tar -xvf ${PROV}_${SCEN}_run0${RUN}.tar.gz
rm -rf /mnt/volume_tor1_01/wbi/outputs/outputs/${PROV}_${SCEN}_run0${RUN}/*.qs
rm -rf /mnt/volume_tor1_01/wbi/outputs/outputs/${PROV}_${SCEN}_run0${RUN}/pixelGroupMap*
rm -rf /mnt/volume_tor1_01/wbi/outputs/outputs/${PROV}_${SCEN}_run0${RUN}/mortalityMap*
rm -rf /mnt/volume_tor1_01/wbi/outputs/outputs/${PROV}_${SCEN}_run0${RUN}/fireSense*
rm -rf /mnt/volume_tor1_01/wbi/outputs/outputs/${PROV}_${SCEN}_run0${RUN}/ANPPMap*

export RUN=4
tar -xvf ${PROV}_${SCEN}_run0${RUN}.tar.gz
rm -rf /mnt/volume_tor1_01/wbi/outputs/outputs/${PROV}_${SCEN}_run0${RUN}/*.qs
rm -rf /mnt/volume_tor1_01/wbi/outputs/outputs/${PROV}_${SCEN}_run0${RUN}/pixelGroupMap*
rm -rf /mnt/volume_tor1_01/wbi/outputs/outputs/${PROV}_${SCEN}_run0${RUN}/mortalityMap*
rm -rf /mnt/volume_tor1_01/wbi/outputs/outputs/${PROV}_${SCEN}_run0${RUN}/fireSense*
rm -rf /mnt/volume_tor1_01/wbi/outputs/outputs/${PROV}_${SCEN}_run0${RUN}/ANPPMap*

export RUN=5
tar -xvf ${PROV}_${SCEN}_run0${RUN}.tar.gz
rm -rf /mnt/volume_tor1_01/wbi/outputs/outputs/${PROV}_${SCEN}_run0${RUN}/*.qs
rm -rf /mnt/volume_tor1_01/wbi/outputs/outputs/${PROV}_${SCEN}_run0${RUN}/pixelGroupMap*
rm -rf /mnt/volume_tor1_01/wbi/outputs/outputs/${PROV}_${SCEN}_run0${RUN}/mortalityMap*
rm -rf /mnt/volume_tor1_01/wbi/outputs/outputs/${PROV}_${SCEN}_run0${RUN}/fireSense*
rm -rf /mnt/volume_tor1_01/wbi/outputs/outputs/${PROV}_${SCEN}_run0${RUN}/ANPPMap*

rm ${PROV}_${SCEN}_run01.tar.gz
rm ${PROV}_${SCEN}_run02.tar.gz
rm ${PROV}_${SCEN}_run03.tar.gz
rm ${PROV}_${SCEN}_run04.tar.gz
rm ${PROV}_${SCEN}_run05.tar.gz
# rm -rf BC_*.tar.gz


unzip outputs_postprocess.zip
```

You'll need `sudo chown -R rstudio:rstudio /mnt/volume_tor1_01`

```bash
SRC=/root/data/outputs
DEST=/mnt/volume_tor1_01/wbi
HOST=159.203.31.192
rsync -Pav root@$HOST:$SRC $DEST


```