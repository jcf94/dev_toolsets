project(onnx_tf_custom_op)
cmake_minimum_required(VERSION 3.0)

# Set parameters

set(CMAKE_BUILD_TYPE "Release")
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
add_definitions(-D_GLIBCXX_USE_CXX11_ABI=0)

# Set onnxruntime lib

if(NOT DEFINED ORT_ROOT)
  message(FATAL_ERROR "ORT_ROOT not set")
endif(NOT DEFINED ORT_ROOT)

# Build lib

file(GLOB_RECURSE LIB_SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cc)
set(LIB_INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/include)

add_library(onnx_tf_custom_op SHARED ${LIB_SOURCE})
target_include_directories(onnx_tf_custom_op PRIVATE ${LIB_INCLUDE_DIR} "${ORT_ROOT}/include/onnxruntime")
target_link_libraries(onnx_tf_custom_op PRIVATE "${ORT_ROOT}/build/Linux/RelWithDebInfo/libonnxruntime.so")
