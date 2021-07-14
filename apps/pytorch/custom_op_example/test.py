import torch
import torch.nn as nn

class MyModule(nn.Module):
    def __init__(self):
        super(MyModule, self).__init__()

    def forward(self, a, b, c):
        return torch.matmul(a, b) + c

model = torch.jit.script(MyModule())

print("Model before: ----------")
print(model.forward.graph)
print(model.forward.code)
print("------------------------")
print()

data_a = torch.randn([10, 20])
data_b = torch.randn([20, 30])
data_c = torch.randn([30])
ref = model(data_a, data_b, data_c)

# Replace model with custom op
torch._C._jit_pass_custom_pattern_based_rewrite_graph("""
graph(%a, %b, %c):
    %1 = prim::Constant[value=1]()
    %d = aten::matmul(%a, %b)
    %r = aten::add(%d, %c, %1)
    return (%r)""", """
graph(%a, %b, %c):
    %r = CustomOpTest::TestCustomOp(%a, %b, %c)
    return (%r)""", model.forward.graph)

torch.ops.load_library("./build/libtorch_custom_op.so")

print("Model after: -----------")
print(model.forward.graph)
print(model.forward.code)
print("------------------------")

# Save model
torch.jit.save(model, "./custom.pt")

# Load model
new_model = torch.jit.load("./custom.pt")

res1 = new_model(data_a, data_b, data_c)
res2 = torch.ops.CustomOpTest.TestCustomOp(data_a, data_b, data_c)

assert torch.allclose(ref, res1)
assert torch.allclose(ref, res2)
print("Result check pass")
