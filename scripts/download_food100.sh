#!/bin/bash

if [ $# -lt 1 ]; then
  echo 1>&2 "$0: not enough arguments"
  exit 2
elif [ $# -gt 1 ]; then
  echo 1>&2 "$0: too many arguments"
  exit 2
fi

outp_path=`readlink -f $1`

if [ ! -d $outp_path ]; then
  mkdir -p $outp_path;
fi

tmp_folder=`date +%d%H%M%S`
mkdir $tmp_folder
cd $tmp_folder

echo "Download archives..."
wget http://foodcam.mobi/dataset100.zip

echo "Extract archives..."
unzip dataset100.zip -d Food100

echo "Move the dataset to the output directory"
mv Food100/UECFOOD100 $outp_path/FOOD100

cd -
rm -r $tmp_folder

