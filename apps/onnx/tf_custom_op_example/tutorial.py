import tensorflow as tf
import tf2onnx
from onnx import helper

_TENSORFLOW_DOMAIN = "ai.onnx.converters.tensorflow"


def print_handler(ctx, node, name, args):
    # replace tf.Print() with Identity
    #   T output = Print(T input, data, @list(type) U, @string message, @int first_n, @int summarize)
    # becomes:
    #   T output = Identity(T Input)
    node.domain = _TENSORFLOW_DOMAIN
    del node.input[1:]
    return node


with tf.Session() as sess:
    x = tf.placeholder(tf.float32, [2, 3], name="input")
    x_ = tf.add(x, x)
    x_ = tf.Print(x, [x], "hello")
    _ = tf.identity(x_, name="output")
    onnx_graph = tf2onnx.tfonnx.process_tf_graph(sess.graph,
                                                 custom_op_handlers={"Print": (print_handler, ["Identity", "mode"])},
                                                 extra_opset=[helper.make_opsetid(_TENSORFLOW_DOMAIN, 1)],
                                                 input_names=["input:0"],
                                                 output_names=["output:0"])
    model_proto = onnx_graph.make_model("test")
    with open("./model.onnx", "wb") as f:
        f.write(model_proto.SerializeToString())
