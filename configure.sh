#!/bin/bash

##############################################
# General variables
ROOT="$EUID"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
NB_GPU="$(lshw -C display | grep "NVIDIA" | wc -l)"
CUDNN=false


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

OPENCV_VERSION="$(pkg-config --modversion opencv)"

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


##############################################
# Don't deal with cudnn


##############################################
# Compile caffe
cd $DIR/py-faster-rcnn/caffe-fast-rcnn
if [ ! -d build ]; then
  echo "Caffe compilation"
  pip install cython
  make clean
  cp Makefile.config.example Makefile.config
  if [ "$CUDNN" = true ]; then sed -i '5s/.*/USE_CUDNN := 1/' Makefile.config; fi
  if [ $NB_GPU -eq 0 ]; then sed -i '8s/.*/CPU_ONLY := 1/' Makefile.config; fi
  if [ ${OPENCV_VERSION::1} -gt 2 ]; then sed -i '21s/.*/OPENCV_VERSION := 3/' Makefile.config; fi
  sed -i '91s/.*/WITH_PYTHON_LAYER := 1/' Makefile.config;
  
  sed -i '174s/.*/INCLUDE_DIRS += $(BUILD_INCLUDE_DIR) .\/src .\/include \/usr\/include\/hdf5\/serial\//' Makefile
  sed -i '181s/.*/LIBRARIES += glog gflags protobuf boost_system boost_filesystem m hdf5_serial_hl hdf5_serial/' Makefile
  git update-index --assume-unchanged Makefile

  if [ $NB_GPU -eq 0 ]; then
    sed -i '205s/.*/__C.USE_GPU_NMS = False/' ../lib/fast_rcnn/config.py
    sed -i '9s/.*/ /' ../lib/fast_rcnn/nms_wrapper.py
    sed -i '17s/.*/ /' ../lib/fast_rcnn/nms_wrapper.py
    sed -i '18s/.*/ /' ../lib/fast_rcnn/nms_wrapper.py
    sed -i '80s/.*/    caffe.set_mode_cpu()/' ../tools/test_net.py
    sed -i '101s/.*/    caffe.set_mode_cpu()/' ../tools/train_net.py
    sed -i '58s/.*/ /' ../lib/setup.py
    sed -i '90s/.*/ /' ../lib/setup.py
    sed -i '125s/.*/ /' ../lib/setup.py
    for i in `seq 125 141`; do
      sed -i $i's/.*/ /' ../lib/setup.py
    done
    git update-index --assume-unchanged ../lib/fast_rcnn/config.py
    git update-index --assume-unchanged ../lib/fast_rcnn/nms_wrapper.py
    git update-index --assume-unchanged ../tools/test_net.py
    git update-index --assume-unchanged ../tools/train_net.py
    git update-index --assume-unchanged ../lib/setup.py
  fi
  
  cd ../lib
  make
  cd ../caffe-fast-rcnn

  mkdir -p build
  cd build
  cmake ..
  cd ..
  
  ldconfig -v
  make -j$(nproc --all) all
  
  if [ $NB_GPU -eq 0 ]; then
    mv src/caffe/test/test_roi_pooling_layer.cpp src/caffe/test/test_roi_pooling_layer.cpp.orig
  fi
  make -j$(nproc --all) test
  make -j$(nproc --all) runtest
  if [ $NB_GPU -eq 0 ]; then
    mv src/caffe/test/test_roi_pooling_layer.cpp.orig src/caffe/test/test_roi_pooling_layer.cpp
  fi
  
  make -j$(nproc --all) pycaffe
  make -j$(nproc --all) distribute
  
else
  echo "Caffe already compiled, remove the `build` directory to recompile it"
fi





# Initialize the py-faster-rcnn/data directory
# Deal with the data issue on gitignore
# Fetch imagenet (./data/scripts/fetch_imagenet_models.sh)





# Initialize the py-faster-rcnn/data directory
# Deal with the data issue on gitignore
# Fetch imagenet (./data/scripts/fetch_imagenet_models.sh)


##############################################
# A few optional libraries
pip install easydict
pip install numpy --upgrade
apt-get install python-skimage
apt-get install python-protobuf
