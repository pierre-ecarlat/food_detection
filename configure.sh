#!/bin/bash

##############################################
# General variables
ROOT="$EUID"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
NB_GPU="$(lshw -C display | grep "NVIDIA" | wc -l)"


##############################################
# Invalid conditions
# Return if not root
if [ $ROOT -ne 0 ]
  then echo "Please run as root"
  exit
fi


##############################################
# Install OpenCV
if [ ! -d $DIR/lib ]; then
  mkdir -p $DIR/lib;
fi
if [ ! -d $DIR/lib/opencv ]; then
  cd $DIR/lib
  git clone https://github.com/Itseez/opencv.git
fi
if [ ! -d $DIR/lib/opencv_contrib ]; then
  cd $DIR/lib
  git clone https://github.com/Itseez/opencv_contrib.git
fi

pkg-config --modversion opencv
if [ $? -eq 0 ]; then
  echo "OpenCV already installed"
else
  echo "Install OpenCV"
  apt-get install build-essential cmake cmake-gui git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev python-dev python-numpy libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libjasper-dev libdc1394-22-dev
  cd $DIR/lib/opencv
  mkdir $DIR/lib/opencv/build
  cmake-gui
  cd build
  make -j$(nproc --all)
  make install
fi


##############################################
# If GPU compatible
if [ $NB_GPU -gt 0 ]; then
  nvcc --version
  if [ $? -eq 0 ]; then
    echo "Cuda already installed"
  else
    echo "Install Cuda"
    cd $DIR/lib
    wget https://developer.nvidia.com/compute/cuda/8.0/Prod2/local_installers/cuda_8.0.61_375.26_linux-run
    sh cuda_8.0.61_375.26_linux.run
    source ~/.bashrc
  fi
fi







# Initialize the py-faster-rcnn/data directory
# Fetch imagenet (./data/scripts/fetch_imagenet_models.sh)
