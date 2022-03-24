#!/bin/bash
# Copyright 2020-2022 Huawei Technologies Co., Ltd
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
    echo "Usage: bash train_PCB_market.sh [DATASET_PATH] [CONFIG_PATH] [PRETRAINED_CKPT_PATH](optional)"
exit 1
fi


get_real_path(){
  if [ "${1:0:1}" == "/" ]; then
    echo "$1"
  else
    echo "$(realpath -m $PWD/$1)"
  fi
}

DATASET_PATH=$(get_real_path $1)
CONFIG_PATH=$(get_real_path $2)

if [ $# == 3 ]; then
  PRETRAINED_CKPT_PATH=$(get_real_path $3)
else
  PRETRAINED_CKPT_PATH=""
fi

if [ ! -d $DATASET_PATH ]
then 
    echo "error: DATASET_PATH=$DATASET_PATH is not a directory"
exit 1
fi

if [ ! -f $CONFIG_PATH ]
then 
    echo "error: CONFIG_PATH=$CONFIG_PATH is not a file"
exit 1
fi

if [ $# == 3 ] && [ ! -f $PRETRAINED_CKPT_PATH ]
then
    echo "error: PRETRAINED_CKPT_PATH=$PRETRAINED_CKPT_PATH is not a file"
exit 1
fi

export DEVICE_NUM=1
export RANK_ID=0
export RANK_SIZE=1

script_path=$(readlink -f "$0")
script_dir_path=$(dirname "${script_path}")

LOG_SAVE_PATH=${script_dir_path}/output/log/PCB/marekt/train/
CHECKPOINT_SAVE_PATH=${script_dir_path}/output/checkpoint/PCB/market/train/
if [ -d $LOG_SAVE_PATH ];
then
    rm -rf $LOG_SAVE_PATH
fi

if [ -d $CHECKPOINT_SAVE_PATH ];
then
    rm -rf $CHECKPOINT_SAVE_PATH
fi

python ${script_dir_path}/../train.py \
--dataset_path=$DATASET_PATH \
--config_path=$CONFIG_PATH \
--checkpoint_file_path=$PRETRAINED_CKPT_PATH \
--output_path ${script_dir_path}/output/ \
--device_target GPU > ../output.train.log 2>&1 &
