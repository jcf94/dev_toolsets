# Custom op test for pytorch

```bash
mkdir build
cd build
cmake .. -DTF_ROOT=/root/dev_toolsets/dev/conda/miniconda/envs/tf115/lib/python3.7/site-packages/torch
make -j

cd ..
python test.py
```
