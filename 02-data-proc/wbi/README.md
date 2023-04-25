# Data processing for full extent WBI results

> Data related scripts, i.e. compile final data to be displayed by the app.

This section describes the workflow on Digital Research Alliance of Canada servers.

Prerequisites:

- users with access added to the group
- ACLs set up on Narval to process data

Describe how to set up jobs and what scripts to run, also RAM/CPU requests etc.

## API

`<PROTOCOL>://<HOST>/api/<VERSION>/<ACCESS>/<PROJECT>/<REGION>/<KIND>/<ELEMENT>/<SCENARIO>/<PERIOD>/<RESOLUTION>/<FILE.EXT>`.

- `PROTOCOL`: protocol name, `http` or `https`
- `HOST`: IP address (`178.128.225.41`) or domain name (`wbi.predictiveecology.org`)
- `VERSION`: API version, `v1`
- `ACCESS`: access level, `public` is not password protected, `private` is intended to be password protected (this will house sensitive information with similar nested structure)
- `PROJECT`: a project, e.g. `wbi-nwt`
- `REGION`: region, e.g. `ab`, `yt`, etc. or `full-extent` for full extent
- `KIND`: the kind of information being displayed, `elements`, `summaries`, `assets`, etc.
- `ELEMENT`: element name (bird or tree species abbreviation), e.g. `bird-alfl` or `tree-betu-pap`
- `SCENARIO`: screnario or treatment type (`landr-scfm-v4`, `landrcs-fs-v6a`)
- `PERIOD`: time period, i.e. year (`2011`, `2100`)
- `RESOLUTION`: resolution (`250m` or `1000m`), `lonlat`, `tiles`, etc.
- `FILE.EXT`: file name, e.g. `mean.tif` meaning that the pixel values are the mean of the runs