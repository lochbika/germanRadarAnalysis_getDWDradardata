#!/bin/bash
 
set -ex 
in_dir="/home/kai/nobackup/german_radar/get_DWD_Radar_data/processed_bin/"
out_dir="/home/kai/nobackup/german_radar/get_DWD_Radar_data/processed_final/"

months=("03" "10" "11")

for year in $(seq -f "%04g" 2001 2020)
do
  for month in ${months[@]}
  do
    # merge to monthly files
    cdo -f nc4 -z zip_6 mergetime ${in_dir}raa01-yw2017.002_10000-${year:2:2}${month}*-dwd---bin.nc ${out_dir}raa01-yw2017.002_10000-${year}${month}-dwd---bin.nc
    #rm -f ${out_dir}raa01-yw2017.002_10000-${year:2:2}${month}*-dwd---bin.nc
  done
done
