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
wget http://host.robots.ox.ac.uk/pascal/VOC/voc2007/VOCtrainval_06-Nov-2007.tar
wget http://host.robots.ox.ac.uk/pascal/VOC/voc2007/VOCtest_06-Nov-2007.tar
wget http://host.robots.ox.ac.uk/pascal/VOC/voc2007/VOCdevkit_08-Jun-2007.tar

echo "Extract archives..."
tar xvf VOCtrainval_06-Nov-2007.tar
tar xvf VOCtest_06-Nov-2007.tar
tar xvf VOCdevkit_08-Jun-2007.tar

echo "Move the dataset to the output directory"
mv VOCdevkit $outp_path

cd -
rm -r $tmp_folder

