#pragma once
#include "core/session/onnxruntime_cxx_api.h"

#ifdef __cplusplus
extern "C" {
#endif

ORT_EXPORT OrtStatus* ORT_API_CALL RegisterCustomOps(OrtSessionOptions* options, const OrtApiBase* api);

#ifdef __cplusplus
}
#endif
