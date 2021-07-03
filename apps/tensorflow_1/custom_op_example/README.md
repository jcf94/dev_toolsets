# Custom op test for tensorflow 1.x

Tested for tf 1.15.

```bash
mkdir build
cd build
cmake .. -DTF_ROOT=/root/dev_toolsets/conda/miniconda/envs/tf115/lib/python3.6/site-packages/tensorflow_core
make -j

cd ..
python test.py
```
