#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export XERCESCROOT=${PREFIX}
export XALANCROOT=${SRC_DIR}

sed -i 's/CMAKE_CXX_STANDARD 14/CMAKE_CXX_STANDARD 17/' CMakeLists.txt

if [[ ${CONDA_BUILD_CROSS_COMPILATION:-0} == 1 ]]; then
    BOOTSTRAP_CMAKE_ARGS=${CMAKE_ARGS//${PREFIX}/${BUILD_PREFIX}}
    BOOTSTRAP_CMAKE_ARGS=${BOOTSTRAP_CMAKE_ARGS//${CONDA_TOOLCHAIN_HOST}/${CONDA_TOOLCHAIN_BUILD}}

    CROSS_LDFLAGS=${LDFLAGS}
    CROSS_CC="${CC}"
    CROSS_CXX="${CXX}"
    CROSS_LD="${LD}"
    CROSS_PKG_CONFIG_PATH=${PKG_CONFIG_PATH}

    LDFLAGS=${LDFLAGS//${PREFIX}/${BUILD_PREFIX}}
    CC=${CC//${CONDA_TOOLCHAIN_HOST}/${CONDA_TOOLCHAIN_BUILD}}
    CXX=${CXX//${CONDA_TOOLCHAIN_HOST}/${CONDA_TOOLCHAIN_BUILD}}
    LD="${LD//${CONDA_TOOLCHAIN_HOST}/${CONDA_TOOLCHAIN_BUILD}}"

    cmake -G Ninja -S . -B build_host \
        -DCMAKE_POLICY_VERSION_MINIMUM=3.15 \
        -DICU_UC_LIBRARY=${BUILD_PREFIX}/lib/libicuuc${SHLIB_EXT} \
        -DICU_I18N_LIBRARY=${BUILD_PREFIX}/lib/libicui18n${SHLIB_EXT} \
        -DXercesC_LIBRARY=${BUILD_PREFIX}/lib/libxerces-c${SHLIB_EXT} \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_VERBOSE_MAKEFILE=ON \
        -Wno-dev \
        ${BOOTSTRAP_CMAKE_ARGS}

    cmake --build build_host -j${CPU_COUNT}
    cmake --install build_host

    LDFLAGS="${CROSS_LDFLAGS}"
    CC=${CROSS_CC}
    CXX=${CROSS_CXX}
    LD=${CROSS_LD}

    sed -i -e "s,\$<TARGET_FILE:MsgCreator>,${BUILD_PREFIX}/bin/MsgCreator,g" src/xalanc/Utils/CMakeLists.txt
    sed -i -e "/add_subdirectory(samples)/d" CMakeLists.txt
    sed -i -e "/add_subdirectory(Tests)/d" CMakeLists.txt
fi


cmake -G Ninja -S . -B build \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.15 \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -Wno-dev \
    ${CMAKE_ARGS}

cmake --build build -j${CPU_COUNT}
cmake --install build

exit 1
