# Contributing

## A. Setup

Make sure your environment is setup [correctly](./README.md).

## B. Repository
### B.1. File organization
Overview of the file structure:
```
MGF Ostsee/
├─ Code/                  # Code files
├─ GIS/                   # GIS files
│  ├─ layers/               # layer data
│  │  ├─ raster/              # raster layer data (only synced via Dropbox)
│  │  └─ vector/              # vector layer data (as text files, e.g. GeoJSON)
│  ├─ styles/               # QGIS style files
│  └─ MGF Ostsee.qgs        # QGIS project file (as text file instead of .qgz)
├─ ressources/            # other ressources
│  └─ images/               # images
└─ README.md
```

#### B.1.1. Raster data
Raster data should not be pushed to GitHub as GitHub's free plan is limited to 1GB storage. As a workaround, the `GIS/layers/raster/` folder should be synced via Dropbox. On the client side that Dropbox shared folder has to be placed within `GIS/layers/` (see above).

#### B.1.2. Vector data
Vector data should be stored as GeoJSON. This way it is stored as text files, which can easily be version controlled.

## C. Contributing
The core contributors are:
- Mischa Schönke ([GitHub @SchoenkeM](https://github.com/SchoenkeM))
- David Clemens ([GitHub @davidclemens](https://github.com/davidclemens))

### C.1 Issues
Use GitHub's issue tracker as a to-do list, report bugs or request features.

### C.2 Editing files
#### C.2.1 Editing the QGIS project
Any changes to the project (layer ordering, styles, etc.) should be explained in the commit messages, as they are not obvious from the file diff.

#### C.2.2 Editing vector data
##### C.2.2.1. Adding features
If features are added to vector files the id column should be populated with a unique numeric id. To make merging easier if multiple persons worked on the same file, contributors gets their own id offset:
- Mischa Schönke: `10000`
- David Clemens: `0`

If *Mischa* already added 10 features (with id `10000` to `10009`) and adds another new feature, the new id would be `10010`. If *David* already added 15 features (with id `0` to `14`) and *David* adds a feature, the new id would be `15`. If the files are merged, the id stays unique, as long as each user does not exceed 10000 features.

##### C.2.2.2. Adding columns
New columns should follow the following naming conventions
- the first character should always be lower case letter, no numbers.
- no spaces, instead indicate a new word by a capital letter
- no special characters
- in English

**Example**
- `id_trawl_mark` should be `idTrawlMark`
