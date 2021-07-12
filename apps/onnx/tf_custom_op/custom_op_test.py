import os
import sys
from pathlib import Path

import numpy as np
import onnxruntime as onnxrt
import tensorflow as tf
import tf2onnx
from onnx import helper

tf1_root = os.path.normpath(
    os.path.join(Path(__file__).absolute(), "..", "..", "..", "tensorflow_1")
)
sys.path.append(tf1_root)

import tf_utils as tf_u


_TENSORFLOW_DOMAIN = "test.customop"

onnx_custom_op_library = "./build/libonnx_tf_custom_op.so"
if not os.path.exists(onnx_custom_op_library):
    raise FileNotFoundError("Unable to find '{0}'".format(onnx_custom_op_library))

this = os.path.dirname(__file__)
tf_custom_op_model = os.path.join(
    this, "..", "..", "tensorflow_1", "custom_op_example", "custom.pb"
)
if not os.path.exists(tf_custom_op_model):
    raise FileNotFoundError("Unable to find '{0}'".format(tf_custom_op_model))

tf_custom_op_library = os.path.join(
    this, "..", "..", "tensorflow_1", "custom_op_example", "build", "libtf_custom_op.so"
)
if not os.path.exists(tf_custom_op_library):
    raise FileNotFoundError("Unable to find '{0}'".format(tf_custom_op_library))

def custom_op_handler(ctx, node, name, args):
    node.domain = args[0]
    print(node)
    return node

# Numpy reference
data_a = np.random.random([4, 5]).astype(np.float32)
data_b = np.random.random([5, 6]).astype(np.float32)
data_c = np.random.random([6]).astype(np.float32)
ref_d = np.dot(data_a, data_b) + data_c

# Process TF graph
graph = tf.Graph()
with graph.as_default():
    tf.load_library(tf_custom_op_library)
    gd = tf_u.load_graph_def(tf_custom_op_model)
    tf.import_graph_def(gd, name="")
    with tf.compat.v1.Session(graph=graph) as sess:
        out_d = sess.run("output:0", {"a:0": data_a, "b:0": data_b, "c:0": data_c})
np.testing.assert_allclose(out_d, ref_d, rtol=1e-6)

# Process Onnx graph
onnx_graph = tf2onnx.tfonnx.process_tf_graph(
    graph,
    custom_op_handlers={"TestCustomOp": (custom_op_handler, ["TestCustomOp", _TENSORFLOW_DOMAIN])},
    extra_opset=[helper.make_opsetid(_TENSORFLOW_DOMAIN, 8)],
    input_names=["a:0", "b:0", "c:0"],
    output_names=["output:0"],
    continue_on_error=True,
)

so = onnxrt.SessionOptions()
so.register_custom_ops_library(onnx_custom_op_library)
sess = onnxrt.InferenceSession(onnx_graph.make_model("test").SerializeToString(), so)

# Run with input data

res = sess.run(["output:0"], {"a:0": data_a, "b:0": data_b, "c:0": data_c})
np.testing.assert_allclose(res, np.reshape(ref_d, [1, 4, 6]), rtol=1e-6)
print("Result check pass")
