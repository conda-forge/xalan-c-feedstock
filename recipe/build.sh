#!/bin/bash

# Force C++ 17
perl -pi -e "s#CMAKE_CXX_STANDARD\s+\d+#CMAKE_CXX_STANDARD 17#g" CMakeLists.txt 

mkdir build && cd build
cmake ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.15 \
  -DCMAKE_C_FLAGS="-Wno-error" \
  -DCMAKE_CXX_FLAGS="-Wno-error -fpermissive" \
  -DCMAKE_VERBOSE_MAKEFILE=ON \
  $SRC_DIR
make -j $CPU_COUNT install

