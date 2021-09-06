project(tf_custom_op)
cmake_minimum_required(VERSION 3.0)

# Set parameters

set(CMAKE_BUILD_TYPE "Release")
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
add_definitions(-D_GLIBCXX_USE_CXX11_ABI=0)

# Set tf lib

if(NOT DEFINED TF_ROOT)
  find_package(PythonInterp REQUIRED)

  # Process tf version
  execute_process(
    COMMAND "${PYTHON_EXECUTABLE}" "-c" "from __future__ import print_function\nimport tensorflow as tf\nprint(tf.__version__, end = '')"
    RESULT_VARIABLE CMD_RESUTL
    OUTPUT_VARIABLE OUT
    ERROR_VARIABLE ERR)
  if(NOT ${CMD_RESULT} EQUAL "0")
    message(FATAL_ERROR "TF_VERSION not set")
  else(NOT ${CMD_RESULT} EQUAL "0")
    set(TF_VERSION ${OUT})
    if("${OUT}" MATCHES "^1.*")
      set(TF_VERSION_MAJOR "1")
    elseif("${OUT}" MATCHES "^2.*")
      set(TF_VERSION_MAJOR "2")
    endif("${OUT}" MATCHES "^1.*")
  endif(NOT ${CMD_RESULT} EQUAL "0")

  # Process tf root
  execute_process(
    COMMAND "${PYTHON_EXECUTABLE}" "-c" "from __future__ import print_function\nimport tensorflow\nimport os\nprint(os.path.dirname(tensorflow.__file__), end = '')"
    RESULT_VARIABLE CMD_RESULT
    OUTPUT_VARIABLE OUT
    ERROR_VARIABLE ERR)
  if(NOT ${CMD_RESULT} EQUAL "0")
    message(FATAL_ERROR "TF_ROOT not set")
  else(NOT ${CMD_RESULT} EQUAL "0")
    if(${TF_VERSION_MAJOR} EQUAL "1")
      set(TF_ROOT "${OUT}_core")
    else(${TF_VERSION_MAJOR} EQUAL "2")
      set(TF_ROOT "${OUT}")
    endif(${TF_VERSION_MAJOR} EQUAL "1")
  endif(NOT ${CMD_RESULT} EQUAL "0")

endif(NOT DEFINED TF_ROOT)

set(TF_INCLUDE "${TF_ROOT}/include")
set(TF_LIBRARY "${TF_ROOT}/libtensorflow_framework.so.${TF_VERSION_MAJOR}")

message(STATUS "TF_VERSION: ${TF_VERSION}")
message(STATUS "TF_INCLUDE: ${TF_INCLUDE}")
message(STATUS "TF_LIBRARY: ${TF_LIBRARY}")

# Build lib

file(GLOB_RECURSE LIB_SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cc)

add_library(tf_custom_op SHARED ${LIB_SOURCE})
target_include_directories(tf_custom_op PRIVATE ${TF_INCLUDE})
target_link_libraries(tf_custom_op PRIVATE ${TF_LIBRARY})
