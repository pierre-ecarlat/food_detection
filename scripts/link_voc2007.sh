#!/bin/bash

if [ $# -lt 3 ]; then
  echo 1>&2 "$0: not enough arguments"
  exit 2
elif [ $# -gt 3 ]; then
  echo 1>&2 "$0: too many arguments"
  exit 2
fi


ln -s $1/VOCdevkit $2/data/$3
echo "Symbolic link has been created."
