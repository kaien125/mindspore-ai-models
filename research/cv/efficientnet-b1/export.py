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
"""export efficientnet IR."""
import argparse
import numpy as np
from mindspore import context, Tensor, load_checkpoint, load_param_into_net, export

from src.models.effnet import EfficientNet
from src.config import efficientnet_b1_config_ascend as config


parser = argparse.ArgumentParser(description="export efficientnet IR.")
parser.add_argument("--checkpoint_path", type=str, required=True, help="Checkpoint file path")
parser.add_argument("--file_name", type=str, default="efficientnet-b1", help="output file name.")
parser.add_argument("--width", type=int, default=240, help="input width")
parser.add_argument("--height", type=int, default=240, help="input height")
parser.add_argument("--file_format", type=str, choices=["AIR", "ONNX", "MINDIR"], default="MINDIR", help="file format")
args_opt = parser.parse_args()

if __name__ == "__main__":
    context.set_context(mode=context.GRAPH_MODE, device_target="Ascend")

    net = EfficientNet(width_coeff=config.width_coeff, depth_coeff=config.depth_coeff,
                       dropout_rate=config.dropout_rate, drop_connect_rate=config.drop_connect_rate,
                       num_classes=config.num_classes)

    param_dict = load_checkpoint(args_opt.checkpoint_path)
    load_param_into_net(net, param_dict)
    input_shp = [1, 3, args_opt.height, args_opt.width]
    input_array = Tensor(np.random.uniform(-1.0, 1.0, size=input_shp).astype(np.float32))
    export(net, input_array, file_name=args_opt.file_name, file_format=args_opt.file_format)
