#include "custom_op_library.h"

#include <assert.h>

#include <cmath>
#include <iostream>
#include <memory>
#include <mutex>
#include <vector>

static const char* c_OpDomain = "test.customop";

struct OrtCustomOpDomainDeleter {
  explicit OrtCustomOpDomainDeleter(const OrtApi* ort_api) { ort_api_ = ort_api; }
  void operator()(OrtCustomOpDomain* domain) const { ort_api_->ReleaseCustomOpDomain(domain); }

  const OrtApi* ort_api_;
};

using OrtCustomOpDomainUniquePtr = std::unique_ptr<OrtCustomOpDomain, OrtCustomOpDomainDeleter>;
static std::vector<OrtCustomOpDomainUniquePtr> ort_custom_op_domain_container;
static std::mutex ort_custom_op_domain_mutex;

static void AddOrtCustomOpDomainToContainer(OrtCustomOpDomain* domain, const OrtApi* ort_api) {
  std::lock_guard<std::mutex> lock(ort_custom_op_domain_mutex);
  auto ptr = std::unique_ptr<OrtCustomOpDomain, OrtCustomOpDomainDeleter>(
      domain, OrtCustomOpDomainDeleter(ort_api));
  ort_custom_op_domain_container.push_back(std::move(ptr));
}

struct TestCustomOpKernel {
  TestCustomOpKernel(OrtApi api) : api_(api), ort_(api_) {}

  void Compute(OrtKernelContext* context) {
    // Setup inputs
    const OrtValue* input_A = ort_.KernelContext_GetInput(context, 0);
    const OrtValue* input_B = ort_.KernelContext_GetInput(context, 1);
    const OrtValue* input_C = ort_.KernelContext_GetInput(context, 2);
    const float* A = ort_.GetTensorData<float>(input_A);
    const float* B = ort_.GetTensorData<float>(input_B);
    const float* C = ort_.GetTensorData<float>(input_C);

    auto info_A = ort_.GetTensorTypeAndShape(input_A);
    auto info_B = ort_.GetTensorTypeAndShape(input_B);
    auto info_C = ort_.GetTensorTypeAndShape(input_C);
    const auto& shape_A = ort_.GetTensorShape(info_A);
    const auto& shape_B = ort_.GetTensorShape(info_B);
    const auto& shape_C = ort_.GetTensorShape(info_C);
    ort_.ReleaseTensorTypeAndShapeInfo(info_A);
    ort_.ReleaseTensorTypeAndShapeInfo(info_B);
    ort_.ReleaseTensorTypeAndShapeInfo(info_C);
    assert(shape_A.size() == 2);
    assert(shape_B.size() == 2);
    assert(shape_C.size() == 1);
    assert(shape_A[1] == shape_B[0]);
    assert(shape_B[1] == shape_C[0]);

    std::vector<int64_t> output_dims{shape_A[0], shape_B[1]};
    OrtValue* output =
        ort_.KernelContext_GetOutput(context, 0, output_dims.data(), output_dims.size());
    float* out = ort_.GetTensorMutableData<float>(output);

    for (int64_t i = 0; i < shape_A[0]; i++) {
      for (int64_t j = 0; j < shape_B[1]; j++) {
        (*(out + i * shape_B[1] + j)) = 0;
        for (int64_t k = 0; k < shape_A[1]; k++) {
          (*(out + i * shape_B[1] + j)) +=
              (*(A + i * shape_A[1] + k)) * (*(B + k * shape_B[1] + j));
        }
        (*(out + i * shape_B[1] + j)) += (*(C + j));
      }
    }

    std::cout << "In Onnxruntime Custom Op\n";
  }

 private:
  OrtApi api_;  // keep a copy of the struct, whose ref is used in the ort_
  Ort::CustomOpApi ort_;
};

struct TestCustomOp : Ort::CustomOpBase<TestCustomOp, TestCustomOpKernel> {
  void* CreateKernel(OrtApi api, const OrtKernelInfo* /* info */) const {
    return new TestCustomOpKernel(api);
  };

  const char* GetName() const { return "TestCustomOp"; };

  size_t GetInputTypeCount() const { return 3; };
  ONNXTensorElementDataType GetInputType(size_t /*index*/) const {
    return ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT;
  };

  size_t GetOutputTypeCount() const { return 1; };
  ONNXTensorElementDataType GetOutputType(size_t /*index*/) const {
    return ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT;
  };

} c_TestCustomOp;

OrtStatus* ORT_API_CALL RegisterCustomOps(OrtSessionOptions* options, const OrtApiBase* api) {
  OrtCustomOpDomain* domain = nullptr;
  const OrtApi* ortApi = api->GetApi(ORT_API_VERSION);

  if (auto status = ortApi->CreateCustomOpDomain(c_OpDomain, &domain)) {
    return status;
  }

  AddOrtCustomOpDomainToContainer(domain, ortApi);

  if (auto status = ortApi->CustomOpDomain_Add(domain, &c_TestCustomOp)) {
    return status;
  }

  return ortApi->AddCustomOpDomain(options, domain);
}
