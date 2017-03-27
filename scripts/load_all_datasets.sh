#!/bin/bash

PROJECT_PATH="/home/finc/py-faster-rcnn/"
DATASET_PATH="/mnt/datasets/"


cd $PROJECT_PATH/scripts

if [ ! -d $DATASET_PATH/VOCdevkit ]; then
    echo "Process VOCdevkit2007"
    bash download_voc2007.sh $DATASET_PATH
    bash link_voc2007.sh $DATASET_PATH $PROJECT_PATH "VOCdevkit2007"
fi

if [ ! -d $DATASET_PATH/Food100 ]; then
    echo "Process Food100"
    bash download_food100.sh $DATASET_PATH
    bash link_food100.sh $DATASET_PATH $PROJECT_PATH "Food100"
fi

if [ ! -d $DATASET_PATH/Food256 ]; then
    echo "Process Food256"
    bash download_food256.sh $DATASET_PATH
    bash link_food256.sh $DATASET_PATH $PROJECT_PATH "Food256"
fi

cd -
