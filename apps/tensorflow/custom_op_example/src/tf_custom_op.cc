
#include "tensorflow/core/framework/op_kernel.h"

using namespace tensorflow;

/*! \brief A custom op for D = A * B + C */
class TestCustomOp : public OpKernel {
 public:
  explicit TestCustomOp(OpKernelConstruction* context) : OpKernel(context) {}

  void Compute(OpKernelContext* context) override {
    assert(context->num_inputs() == 3);
    const Tensor& a = context->input(0);
    const Tensor& b = context->input(1);
    const Tensor& c = context->input(2);

    const auto& a_shape = a.shape();
    const auto& b_shape = b.shape();
    const auto& c_shape = c.shape();
    assert(a_shape.dims() == 2);
    assert(b_shape.dims() == 2);
    assert(c_shape.dims() == 1);
    assert(a_shape.dim_size(1) == b_shape.dim_size(0));
    assert(b_shape.dim_size(1) == c_shape.dim_size(0));

    TensorShape d_shape({a_shape.dim_size(0), b_shape.dim_size(1)});
    Tensor* d_ptr = NULL;
    OP_REQUIRES_OK(context, context->allocate_output(0, d_shape, &d_ptr));

    auto* a_data = reinterpret_cast<const float*>(a.tensor_data().data());
    auto* b_data = reinterpret_cast<const float*>(b.tensor_data().data());
    auto* c_data = reinterpret_cast<const float*>(c.tensor_data().data());
    auto* d_data = const_cast<float*>(reinterpret_cast<const float*>(d_ptr->tensor_data().data()));
    for (int64 i = 0; i < a_shape.dim_size(0); i++) {
      for (int64 j = 0; j < b_shape.dim_size(1); j++) {
        (*(d_data + i * b_shape.dim_size(1) + j)) = 0;
        for (int64 k = 0; k < a_shape.dim_size(1); k++) {
          (*(d_data + i * b_shape.dim_size(1) + j)) +=
              (*(a_data + i * a_shape.dim_size(1) + k)) * (*(b_data + k * b_shape.dim_size(1) + j));
        }
        (*(d_data + i * b_shape.dim_size(1) + j)) += (*(c_data + j));
      }
    }

    std::cout << "[In TensorFlow Custom Op.]\n";
  }
};

REGISTER_OP("TestCustomOp")
    .Input("input: Tin")
    .Output("output: Tout")
    .Attr("Tin: list(type) >= 1")
    .Attr("Tout: list(type)");

REGISTER_KERNEL_BUILDER(Name("TestCustomOp").Device(DEVICE_CPU), TestCustomOp);
