project(tf_custom_op)
cmake_minimum_required(VERSION 3.0)

# Set parameters

set(CMAKE_BUILD_TYPE "Release")
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
add_definitions(-D_GLIBCXX_USE_CXX11_ABI=0)

# Set tf lib

if(NOT DEFINED TF_ROOT)
  message(FATAL_ERROR "TF_ROOT not set")
endif(NOT DEFINED TF_ROOT)

set(TF_INCLUDE "${TF_ROOT}/include")
set(TF_LIBRARY "${TF_ROOT}/libtensorflow_framework.so.1")

message(STATUS "TF_INCLUDE: ${TF_INCLUDE}")
message(STATUS "TF_LIBRARY: ${TF_LIBRARY}")

# Build lib

file(GLOB_RECURSE LIB_SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cc)

add_library(tf_custom_op SHARED ${LIB_SOURCE})
target_include_directories(tf_custom_op PRIVATE ${TF_INCLUDE})
target_link_libraries(tf_custom_op PRIVATE ${TF_LIBRARY})
