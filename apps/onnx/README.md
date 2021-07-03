# OnnxRuntime test

## Convert tf to onnx

```bash
python -m tf2onnx.convert \
    --graphdef ../tensorflow_1/custom_op_example/origraph.pb \
    --output ./origraph.onnx \
    --inputs a:0,b:0,c:0 \
    --outputs add:0
```
