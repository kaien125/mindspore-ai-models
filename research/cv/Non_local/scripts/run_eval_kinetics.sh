#!/bin/bash
# Copyright 2022 Huawei Technologies Co., Ltd
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

if [[ $# != 5 ]]; then
    echo "Usage: run_eval_kinetics.sh [DATASET_DIR][ANNOTATION_PATH][MODE][CHECKPOINT_PATH][DEVICE_ID]"
exit 1
fi

get_real_path(){
  if [ -z $1 ]; then
    echo "error: DATASET_DIR is empty"
    exit 1
  elif [ "${1:0:1}" == "/" ]; then
    echo "$1"
  else
    echo "$(realpath -m $PWD/$1)"
  fi
}
DATASET_DIR=$(get_real_path $1)

if [ ! -d $DATASET_DIR ]
then
    echo "error: DATASET_PATH=$DATASET_DIR is not a directory"
exit 1
fi
echo "$(dirname $PWD)"

cd "$(dirname $PWD)" || exit

python eval.py  --video_path $DATASET_DIR \
                --annotation_path $2 \
                --batch_size 8 \
                --dataset kinetics \
                --sample_size 256 \
                --sample_duration 32 \
                --n_threads 8 \
                --ckpt $4 \
                --device_id $5 \
                --mode $3 \
                > eval.log 2>&1 &