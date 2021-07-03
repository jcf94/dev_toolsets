import os
import sys
from pathlib import Path

import tensorflow as tf
from tensorflow.core.framework import attr_value_pb2
import numpy as np

tf1_root = os.path.normpath(os.path.join(Path(__file__).absolute(), "..", ".."))
sys.path.append(tf1_root)

import graphdef_builder as gd_b
import tf_utils as tf_u


# Numpy reference
data_a = np.random.random([4, 5]).astype(np.float32)
data_b = np.random.random([5, 6]).astype(np.float32)
data_c = np.random.random([6]).astype(np.float32)
ref_d = np.dot(data_a, data_b) + data_c

# Original network def
graph = tf.Graph()
with graph.as_default():
    a = tf.compat.v1.placeholder(shape=[4, 5], dtype="float32", name="a")
    b = tf.compat.v1.placeholder(shape=[5, 6], dtype="float32", name="b")
    c = tf.compat.v1.placeholder(shape=[6], dtype="float32", name="c")
    d = tf.matmul(a, b) + c
    with tf.compat.v1.Session(graph=graph) as sess:
        out_d = sess.run(d, {"a:0": data_a, "b:0": data_b, "c:0": data_c})
        tf_u.save_graph_def(tf.get_default_graph(), "origraph.pb")

np.testing.assert_allclose(out_d, ref_d, rtol=1e-6)

# Check custom op
new_graphdef = tf.compat.v1.GraphDef()
new_a = gd_b.add_placeholder(new_graphdef, "a", "float32", [4, 5])
new_b = gd_b.add_placeholder(new_graphdef, "b", "float32", [5, 6])
new_c = gd_b.add_placeholder(new_graphdef, "c", "float32", [6])

new_node = gd_b.add_op(new_graphdef, "TestCustomOp", "output")
new_node.attr["Tin"].CopyFrom(
    attr_value_pb2.AttrValue(
        list=attr_value_pb2.AttrValue.ListValue(
            type=[tf.as_dtype("float32").as_datatype_enum for _ in range(3)]
        )
    )
)
new_node.attr["Tout"].CopyFrom(
    attr_value_pb2.AttrValue(
        list=attr_value_pb2.AttrValue.ListValue(
            type=[tf.as_dtype("float32").as_datatype_enum]
        )
    )
)
new_node.input.extend(["a", "b", "c"])

graph = tf.Graph()
with graph.as_default():
    tf.load_library("./build/libtf_custom_op.so")
    tf.import_graph_def(new_graphdef, name="")
    with tf.compat.v1.Session(graph=graph) as sess:
        new_out_d = sess.run("output:0", {"a:0": data_a, "b:0": data_b, "c:0": data_c})

np.testing.assert_allclose(new_out_d, ref_d, rtol=1e-6)
