import torch
import onnxruntime as onnxrt

import numpy as np

# Numpy reference
data_a = np.random.random([4, 5]).astype(np.float32)
data_b = np.random.random([5, 6]).astype(np.float32)
data_c = np.random.random([6]).astype(np.float32)
ref_d = np.dot(data_a, data_b) + data_c

torch.ops.load_library("../../pytorch/custom_op_example/build/libtorch_custom_op.so")
model = torch.jit.load("../../pytorch/custom_op_example/custom.pt")

torch_a = torch.from_numpy(data_a)
torch_b = torch.from_numpy(data_b)
torch_c = torch.from_numpy(data_c)
ref = model(torch_a, torch_b, torch_c)
assert torch.allclose(torch.from_numpy(ref_d), ref)

# Create custom symbolic function
from torch.onnx.symbolic_helper import parse_args
@parse_args('v', 'v', 'v')
def symbolic_foo_forward(g, a, b, c):
    return g.op("test.customop::TestCustomOp", a, b, c)

# Register custom symbolic function
from torch.onnx import register_custom_op_symbolic
register_custom_op_symbolic('CustomOpTest::TestCustomOp', symbolic_foo_forward, 8)

torch.onnx.export(
    model,
    (torch_a, torch_b, torch_c),
    "./pytorch_custom_op.onnx",
    example_outputs=ref,
    custom_opsets={"test.customop": 8},
    input_names=['a', 'b', 'c'],
    output_names=['output'],
)

so = onnxrt.SessionOptions()
so.register_custom_ops_library("./build/libonnx_custom_op.so")
sess = onnxrt.InferenceSession("./pytorch_custom_op.onnx", so)

# Run with input data

res = sess.run(["output"], {"a": data_a, "b": data_b, "c": data_c})
np.testing.assert_allclose(res, np.reshape(ref_d, [1, 4, 6]), rtol=1e-6)
print("Result check pass")
