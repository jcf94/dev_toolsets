project(torch_custom_op)
cmake_minimum_required(VERSION 3.0)

# Set parameters

set(CMAKE_BUILD_TYPE "Release")
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
add_definitions(-D_GLIBCXX_USE_CXX11_ABI=0)

# Set tf lib

if(NOT DEFINED TORCH_ROOT)
  find_package(PythonInterp REQUIRED)
  execute_process(
    COMMAND "${PYTHON_EXECUTABLE}" "-c" "from __future__ import print_function\nimport torch\nimport os\nprint(os.path.dirname(torch.__file__), end = '')"
    RESULT_VARIABLE CMD_RESULT
    OUTPUT_VARIABLE OUT
    ERROR_VARIABLE ERR)
  if(NOT ${CMD_RESULT} EQUAL "0")
    message(FATAL_ERROR "TORCH_ROOT not set")
  else(NOT ${CMD_RESULT} EQUAL "0")
    set(TORCH_ROOT "${OUT}")
  endif(NOT ${CMD_RESULT} EQUAL "0")
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
