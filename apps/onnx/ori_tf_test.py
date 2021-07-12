import numpy as np
import onnxruntime

sess = onnxruntime.InferenceSession("./origraph.onnx")

# Numpy reference
data_a = np.random.random([4, 5]).astype(np.float32)
data_b = np.random.random([5, 6]).astype(np.float32)
data_c = np.random.random([6]).astype(np.float32)
ref_d = np.dot(data_a, data_b) + data_c

result = sess.run(
    ["add:0"],
    {
        "a:0": onnxruntime.OrtValue.ortvalue_from_numpy(data_a),
        "b:0": onnxruntime.OrtValue.ortvalue_from_numpy(data_b),
        "c:0": onnxruntime.OrtValue.ortvalue_from_numpy(data_c),
    },
)

np.testing.assert_allclose(result, np.reshape(ref_d, [1, 4, 6]), rtol=1e-6)
print("Check pass.")
