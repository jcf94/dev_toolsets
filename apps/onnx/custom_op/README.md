# Custom op test for onnx runtime

Build the onnxruntime first:

```bash
cd /root/onnxruntime

./build.sh --config RelWithDebInfo --build_shared_lib --parallel
```

Then build test:

```bash
mkdir build
cd build
cmake .. -DORT_ROOT=/root/onnxruntime
make -j

cd ..
python custom_op_test.py
```
