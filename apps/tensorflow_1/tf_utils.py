import os
from typing import Any, Dict, List, Tuple, Union

import google.protobuf.text_format as pb_text_format
import tensorflow as tf
import numpy as np

################ Model save ################


def save_graph_def(
    graph_def: Union[tf.Graph, tf.compat.v1.GraphDef],
    name: str,
    logdir: str = ".",
    overwrite: bool = False,
):
    """
    Parameters
    ----------
    graph_def : Union[tf.Graph, tf.compat.v1.GraphDef]

    name : str

    logdir : Optional[str] = "."

    overwrite : Optional[bool] = False
    """
    target = os.path.join(logdir, name)
    if os.path.isfile(target):
        if overwrite:
            os.remove(target)
        else:
            print("Skip saving for the %s exists." % (target))
            return

    as_text = False
    if name.endswith(".pbtxt"):
        as_text = True

    tf.compat.v1.io.write_graph(graph_def, logdir, name, as_text)


################ Model import ################


def load_graph_def(graph_def_file_name: str) -> tf.compat.v1.GraphDef:
    """
    Parameters
    ----------
    graph_def_file_name : str

    Returns
    -------
    g : tf.compat.v1.Graph
    """
    gd = tf.compat.v1.GraphDef()
    try:
        with tf.compat.v1.gfile.GFile(graph_def_file_name, "r") as f:
            pb_str = f.read()
            pb_text_format.Merge(pb_str.encode("utf-8"), gd)
    except Exception:
        with tf.compat.v1.gfile.GFile(graph_def_file_name, "rb") as f:
            pb_str = f.read()
            gd.ParseFromString(pb_str)

    return gd


def load_saved_model(
    saved_model_dir: str,
) -> Tuple[tf.compat.v1.Graph, Dict[str, str], List[str]]:
    """
    Parameters
    ----------
    saved_model_dir : str

    Returns
    -------
    g : tf.compat.v1.Graph
    input_dict : Dict[str, str]
    fetch_list : List[str]
    """
    tf.compat.v1.reset_default_graph()
    g = tf.compat.v1.Graph()

    with g.as_default():
        with tf.compat.v1.Session() as sess:
            imported = tf.compat.v1.saved_model.load(sess, {"serve"}, saved_model_dir)

    inputs = imported.signature_def["serving_default"].inputs
    outputs = imported.signature_def["serving_default"].outputs

    input_dict = {}
    for inp in inputs:
        input_dict[inp] = inputs[inp].name

    fetch_list = []
    for output in outputs:
        fetch_list.append(outputs[output].name)

    return g, input_dict, fetch_list


################ Data import ################


def load_data_from_eas_tf_request_bin(
    filename: str, input_dict: Dict[str, str]
) -> Dict[str, Any]:
    """Warm up data loaded from EAS requests.

    Parameters
    ----------
    filename : str
    input_dict : Dict[str, str]

    Returns
    -------
    feed_dict : Dict[str, Any]
    """
    from eas_prediction import TFRequest, tf_request_pb2

    request = TFRequest("serving_default")

    with open(filename, "rb") as f:
        request.request_data = tf_request_pb2.PredictRequest()
        request.request_data.ParseFromString(f.read())

    feed_dict = {}
    for name in request.request_data.inputs:
        data = request.request_data.inputs[name]
        shape = data.array_shape.dim
        if data.dtype == TFRequest.DT_FLOAT:
            feed_type = np.float
            feed_value = data.float_val
        elif data.dtype == TFRequest.DT_DOUBLE:
            feed_type = np.double
            feed_value = data.double_val
        elif data.dtype == TFRequest.DT_STRING:
            feed_type = np.string_
            feed_value = data.string_val
        elif data.dtype == TFRequest.DT_INT32:
            feed_type = np.int
            feed_value = data.int_val
        else:
            raise ValueError(name)
        feed_dict[input_dict[name]] = np.array(feed_value, feed_type).reshape(shape)

    return feed_dict


################ Test ################


def test_with_session(
    sess: tf.compat.v1.Session,
    fetch_list: List[str],
    feed_dict: Dict[str, Any],
    warm_up_steps: int = 10,
    num_steps: int = 100,
):
    """Test the performance with the given session.

    Parameters
    ----------
    sess : tf.compat.v1.Session
    fetch_list : List[str]
    feed_dict : Dict[str, Any]
    warm_up_steps : int
    num_steps : int
    """
    import time
    from tensorflow.python.client import timeline

    for _ in range(warm_up_steps):
        sess.run(fetch_list, feed_dict)

    times = []
    for _ in range(num_steps):
        start_t = time.time()
        sess.run(fetch_list, feed_dict)
        end_t = time.time()
        times.append(end_t - start_t)

    run_options = tf.compat.v1.RunOptions(
        trace_level=tf.compat.v1.RunOptions.FULL_TRACE
    )
    run_metadata = tf.compat.v1.RunMetadata()

    sess.run(fetch_list, feed_dict, options=run_options, run_metadata=run_metadata)

    tl = timeline.Timeline(run_metadata.step_stats)
    ctf = tl.generate_chrome_trace_format()
    with open("tl.json", "w") as f:
        f.write(ctf)

    times.sort()
    print("Costs: %.4f ms" % (times[int(len(times) / 2)] * 1000))
