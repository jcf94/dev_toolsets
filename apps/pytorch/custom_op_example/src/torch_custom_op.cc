#include <torch/script.h>

namespace torch {

Tensor TestCustomOp(Tensor a, Tensor b, Tensor c) {
    int dim_a = a.dim();
    int dim_b = b.dim();
    int dim_c = c.dim();
    assert(dim_a == 2);
    assert(dim_b == 2);
    assert(dim_c == 1);
    assert(a.size(1) == b.size(0));
    assert(b.size(1) == c.size(0));

    a = a.contiguous();
    b = b.contiguous();
    c = c.contiguous();

    Tensor output = at::mm(a, b) + c;

    std::cout << "[In Pytorch Custom Op.]\n";

    return output.clone();
}

TORCH_LIBRARY(CustomOpTest, m) {
    m.def("TestCustomOp", TestCustomOp);
}

}
