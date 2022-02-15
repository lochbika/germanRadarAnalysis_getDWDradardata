# germanRadarAnalysis_getDWDradardata

This is how I download and convert RADKLIM binary files to monthly NetCDF files.

This repository is part of the germanRADARanalysis project. More details about the project can be found on [my personal website](https://lochbihler.nl/?page_id=302).

## Steps

### Download
* set the years and months in the download_bin.sh file
* a bandwidth limit can be set via the wget cli option
* run the script

### Unpack the daily tar.gz files
* create a folder named download
* unpack all tar files into it

### Create daily NetCDF files
Remember to set the working directory in R to the project location.

* use the R script (convert_bin2dailyNC.R) to automatically create daily NetCDF files from RADKLIM binaries
* the script does this in parallel
* set the years and months accordingly

### Concatenate daily to monthly files
* the last bash script (concat_daily2monthly_nc.sh) will concatenate the daily files to monthly NetCDF files
* this script uses the tool cdo
