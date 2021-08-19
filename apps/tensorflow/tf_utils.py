import os
from typing import Any, Dict, List, Tuple, Union

import google.protobuf.text_format as pb_text_format
import tensorflow as tf
import numpy as np

################ Model store ################


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


def store_saved_model(
    input_dict: Dict[str, Any],
    output_dict: Dict[str, Any],
    model_path: str,
    sess: Optional[tf.compat.v1.Session] = None,
    tags: Set[str] = {tf.compat.v1.saved_model.tag_constants.SERVING},
    as_text: bool = False,
    override: bool = False,
) -> None:
    """Store the runtime default graph as SavedModel.

    Parameters
    ----------
    input_dict : Dict[str, Any]
        Map the input names to the input tensors.

    output_dict : Dict[str, Any]
        Map the output names to the output tensors.

    model_path : str
        The model export path.

    sess : Optional[tf.compat.v1.Session] = None
        If the graph has not been freezed, the variables will be contained in the tf session.

    tags : Ste[str]
        SavedModel tags.

    as_text : bool = False

    override : bool = False
    """
    inputs = {
        name: tf.compat.v1.saved_model.build_tensor_info(input_dict[name]) for name in input_dict
    }
    outputs = {
        name: tf.compat.v1.saved_model.build_tensor_info(output_dict[name]) for name in output_dict
    }
    model_signature = tf.compat.v1.saved_model.signature_def_utils.build_signature_def(
        inputs, outputs, tf.compat.v1.saved_model.signature_constants.PREDICT_METHOD_NAME
    )

    builder = tf.compat.v1.saved_model.builder.SavedModelBuilder(model_path)
    builder.add_meta_graph_and_variables(
        sess if sess is not None else tf.compat.v1.Session(),
        tags,
        signature_def_map={
            tf.compat.v1.saved_model.signature_constants.DEFAULT_SERVING_SIGNATURE_DEF_KEY: model_signature
        },
        clear_devices=True,
    )
    if override:
        shutil.rmtree(model_path, ignore_errors=True)
    builder.save(as_text)


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
    model_path: str, tags: Set[str] = {tf.compat.v1.saved_model.tag_constants.SERVING}
) -> Tuple[tf.compat.v1.Graph, List[str], Dict[str, str], tf.compat.v1.Session]:
    """Load SavedModel from a model_path.

    Parameters
    ----------
    model_path : str
        The model load path.

    tags : Set[str]
        SavedModel tags.

    Returns
    -------
    graph : tf.compat.v1.Graph
        The loaded tf graph.

    fetch_list : List[str]
        The name of the graph outputs.

    input_dict : Dict[str, str]
        Map the SavedModel input signature to the real tensor name in graph.

    sess : tf.compat.v1.Session
        The session used to load the graph. If the model is not freezed, this will contain the
        loaded variables.
    """
    graph = tf.compat.v1.Graph()

    with graph.as_default():
        # This session contains the loaded variables
        sess = tf.compat.v1.Session(graph=graph)
        imported = tf.compat.v1.saved_model.load(sess, tags, model_path)

    inputs = imported.signature_def["serving_default"].inputs
    outputs = imported.signature_def["serving_default"].outputs

    input_dict = {}
    for inp in inputs:
        input_dict[inp] = inputs[inp].name

    fetch_list = []
    for output in outputs:
        fetch_list.append(outputs[output].name)

    return graph, fetch_list, input_dict, sess


def get_graph_def_from_saved_model(model_path: str, freeze: bool = True) -> tf.compat.v1.GraphDef:
    """Get GraphDef from a SavedModel model path.

    Parameters
    ----------
    model_path : str
        The model load path.

    freeze : bool = True
        True to freeze the model.

    Returns
    -------
    graph_def : tf.compat.v1.GraphDef
        The loaded GraphDef.
    """
    graph, fetch_list, _, sess = load_saved_model(model_path)
    output_node_names = [name.split(":")[0] for name in fetch_list]
    if freeze:
        return tf.compat.v1.graph_util.convert_variables_to_constants(
            sess, graph.as_graph_def(), output_node_names
        )
    return graph.as_graph_def()


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


def benchmark(
    sess: tf.compat.v1.Session,
    fetch_list: List[str],
    feed_dict: Dict[str, Any],
    warm_up: int = 50,
    num: int = 5,
    steps: int = 100,
    trace: bool = False,
) -> float:
    """Test the performance with the given session.

    Parameters
    ----------
    sess : tf.compat.v1.Session
        The running session.

    fetch_list : List[str]

    feed_dict : Dict[str, Any]

    warm_up : int = 50

    num : int = 5

    steps : int = 100

    trace : bool = False
        True to export chrome timeline.

    Returns
    -------
    costs : float
        Time cost for one inference batch(in ms).
    """
    for _ in range(warm_up):
        _ = sess.run(fetch_list, feed_dict)

    times = []
    for _ in range(num):
        start_t = time.time()
        for _ in range(steps):
            _ = sess.run(fetch_list, feed_dict)
        end_t = time.time()
        times.append((end_t - start_t) / steps * 1e3)  # ms
    times.sort()

    if trace:
        run_options = tf.compat.v1.RunOptions(trace_level=tf.compat.v1.RunOptions.FULL_TRACE)
        run_metadata = tf.compat.v1.RunMetadata()
        _ = sess.run(fetch_list, feed_dict, options=run_options, run_metadata=run_metadata)

        tl = timeline.Timeline(run_metadata.step_stats)
        ctf = tl.generate_chrome_trace_format()
        with open("tl.json", "w") as f:
            f.write(ctf)

    times.sort()
    return times[int(len(times) / 2)]
