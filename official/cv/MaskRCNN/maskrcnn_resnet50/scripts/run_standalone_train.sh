#!/bin/bash
# Copyright 2020 Huawei Technologies Co., Ltd
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============================================================================

if [ $# != 2 ] && [ $# != 3 ]
then 
    echo "Usage: bash run_standalone_train.sh [PRETRAINED_PATH] [DATA_PATH] [DEVICE_ID](optional)"
exit 1
fi

get_real_path(){
  if [ "${1:0:1}" == "/" ]; then
    echo "$1"
  else
    echo "$(realpath -m $PWD/$1)"
  fi
}
PATH1=$(get_real_path $1)
PATH2=$(get_real_path $2)
echo $PATH1
echo $PATH2

if [ ! -f $PATH1 ]
then 
    echo "error: PRETRAINED_PATH=$PATH1 is not a file"
exit 1
fi

ulimit -u unlimited
export DEVICE_NUM=1
export RANK_ID=0
export RANK_SIZE=1

DEVICE_ID=0
if [ $# == 3 ];
then
    DEVICE_ID=$3
fi

if [ -d "train" ];
then
    rm -rf ./train
fi
mkdir ./train
cp ../*.py ./train
cp ../*.yaml ./train
cp *.sh ./train
cp -r ../src ./train
cd ./train || exit
echo "start training for device $DEVICE_ID"
env > env.log
python ./train.py --do_train=True --device_id=$DEVICE_ID --pre_trained=$PATH1 --coco_root=$PATH2 &> log.txt &
cd ..
