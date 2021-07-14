project(torch_custom_op)
cmake_minimum_required(VERSION 3.0)

# Set parameters

set(CMAKE_BUILD_TYPE "Release")
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
add_definitions(-D_GLIBCXX_USE_CXX11_ABI=0)

# Set tf lib

if(NOT DEFINED TORCH_ROOT)
  message(FATAL_ERROR "TORCH_ROOT not set")
endif(NOT DEFINED TORCH_ROOT)

set(TORCH_INCLUDE "${TORCH_ROOT}/include")
set(TORCH_LIBRARY "${TORCH_ROOT}/lib/libtorch_cpu.so")

message(STATUS "TORCH_INCLUDE: ${TORCH_INCLUDE}")
message(STATUS "TORCH_LIBRARY: ${TORCH_LIBRARY}")

# Build lib

file(GLOB_RECURSE LIB_SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cc)

add_library(torch_custom_op SHARED ${LIB_SOURCE})
target_include_directories(torch_custom_op PRIVATE ${TORCH_INCLUDE})
target_link_libraries(torch_custom_op PRIVATE ${TORCH_LIBRARY})
