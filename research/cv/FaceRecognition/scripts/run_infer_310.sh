#!/bin/bash
# Copyright 2021 Huawei Technologies Co., Ltd
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

if [[ $# -lt 1 || $# -gt 2 ]]; then
    echo "Usage: bash run_infer_310.sh [MINDIR_PATH] [DEVICE_ID]
    DEVICE_ID is optional, it can be set by environment variable device_id, otherwise the value is zero"
exit 1
fi

get_real_path(){
    if [ "${1:0:1}" == "/" ]; then
        echo "$1"
    else
        echo "$(realpath -m $PWD/$1)"
    fi
}

model=$(get_real_path $1)
dirname_path=$(dirname "$(pwd)")
USE_DEVICE_ID=$2
echo 'start device '$USE_DEVICE_ID
echo ${dirname_path}
dev=`expr $USE_DEVICE_ID + 0`
export DEVICE_ID=$dev
export PYTHONPATH=${dirname_path}:$PYTHONPATH
export RANK_SIZE=1
export RANK_ID=0
export ASCEND_HOME=/usr/local/Ascend/
if [ -d ${ASCEND_HOME}/ascend-toolkit ]; then
    export ASCEND_HOME=/usr/local/Ascend/ascend-toolkit/latest
else
    export ASCEND_HOME=/usr/local/Ascend/latest
fi
export PATH=$ASCEND_HOME/compiler/ccec_compiler/bin:$PATH
export LD_LIBRARY_PATH=$ASCEND_HOME/lib64:/usr/local/Ascend/driver/lib64:$LD_LIBRARY_PATH
export ASCEND_OPP_PATH=$ASCEND_HOME/opp

function preprocess_data()
{
    if [ -d preprocess_Result ]; then
        rm -rf ./preprocess_Result
    fi
    mkdir preprocess_Result
    python ../preprocess.py --config_path=../inference_config.yaml &> preprocess.log &
}

function compile_app()
{
    cd ../ascend310_infer/ || exit
    bash build.sh &> build.log
}

function infer()
{
    cd - || exit
    if [ -d result_Files ]; then
        rm -rf ./result_Files
    fi
    if [ -d time_Result ]; then
        rm -rf ./time_Result
    fi
    mkdir result_Files
    mkdir time_Result

    ../ascend310_infer/out/main --mindir_path=$model --dataset_path=./preprocess_Result/ --cpu_dvpp='CPU' --device_id=$USE_DEVICE_ID  &> infer.log

}

function cal_acc()
{
    python ../postprocess.py --config_path=../inference_config.yaml  &> acc.log
}

preprocess_data
wait
if [ $? -ne 0 ]; then
    echo "preprocess dataset failed"
    exit 1
fi

compile_app
if [ $? -ne 0 ]; then
    echo "compile app code failed"
    exit 1
fi
infer
if [ $? -ne 0 ]; then
    echo " execute inference failed"
    exit 1
fi
cal_acc
if [ $? -ne 0 ]; then
    echo "calculate accuracy failed"
    exit 1
fi
