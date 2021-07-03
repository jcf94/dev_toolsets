from typing import List, Union

import tensorflow as tf
from tensorflow.core.framework import attr_value_pb2, tensor_shape_pb2


def add_op(
    graph_def: tf.compat.v1.GraphDef,
    op: str,
    name: str,
) -> tf.compat.v1.NodeDef:
    new_node = graph_def.node.add()
    new_node.op = op
    new_node.name = name
    return new_node


def add_placeholder(
    graph_def: tf.compat.v1.GraphDef,
    name: str,
    dtype: Union[str, tf.DType],
    shape: List[int],
) -> tf.compat.v1.NodeDef:
    if isinstance(dtype, str):
        dtype = tf.as_dtype(dtype).as_datatype_enum
    elif isinstance(dtype, tf.DType):
        dtype = dtype.as_datatype_enum
    else:
        raise ValueError("dtype should be str or tf.DType")

    new_node = add_op(graph_def, "Placeholder", name)
    new_node.attr["dtype"].CopyFrom(attr_value_pb2.AttrValue(type=dtype))
    new_node.attr["shape"].CopyFrom(
        attr_value_pb2.AttrValue(
            shape=tensor_shape_pb2.TensorShapeProto(
                dim=[tensor_shape_pb2.TensorShapeProto.Dim(size=d) for d in shape]
            )
        )
    )
    new_node.attr["_output_shapes"].CopyFrom(
        attr_value_pb2.AttrValue(
            shape=tensor_shape_pb2.TensorShapeProto(
                dim=[tensor_shape_pb2.TensorShapeProto.Dim(size=d) for d in shape]
            )
        )
    )
