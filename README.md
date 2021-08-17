# get_DWD_Radar_data

This is how I download and convert RADKLIM binary files to monthly NetCDF files.

## Steps
### Download
* set the years and months in download_bin.sh file
* a bandwidth limit can be set via the wget cli option
* run the script

### Unpack the daily tar.gz files
* create a folder named download
* unpack all tar files into it

### Create daily NetCDF files
* use the R script to automatically create daily nc files from RADKLIM binaries
* the script does this in parallel
* set the years and months accordingly

### Concatenate daily to monthly files
* the last bash script will concatenate the daily files to monthly NetCDF files
* this script uses the tool cdo