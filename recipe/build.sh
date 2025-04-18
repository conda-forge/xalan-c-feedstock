#!/bin/bash
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* .

export XERCESCROOT=${PREFIX}
export XALANCROOT=${SRC_DIR}

if [[ ${target_platform} == osx-64 ]]; then
    platform=macosx
else
    platform=linux
    export CXXCPP=${CPP}
fi

./runConfigure -p ${platform} -c $CC -x $CXX -b 64 -P ${PREFIX}

make
make install
