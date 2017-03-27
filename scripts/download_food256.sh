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
wget http://foodcam.mobi/dataset256.zip

echo "Extract archives..."
unzip dataset256.zip -d Food256

echo "Move the dataset to the output directory"
mv Food256/UECFOOD256 $outp_path/FOOD256

cd -
rm -r $tmp_folder

