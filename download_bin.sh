#!/bin/bash

years=(2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020)
months=("04" "05" "06" "07" "08" "09")

for year in ${years[@]}
do
  for month in ${months[@]}
  do
    wget --limit-rate 2048k https://opendata.dwd.de/climate_environment/CDC/grids_germany/5_minutes/radolan/reproc/2017_002/bin/${year}/YW2017.002_${year}${month}.tar
  done
done
