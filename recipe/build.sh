#!/bin/bash

set -e # Abort on error

GSHHG_DIR="$PREFIX/share/gshhg-gmt"
DCW_DIR="$PREFIX/share/dcw-gmt"

if [[ "$c_compiler" == "gcc" ]]; then
  export PATH="${PATH}:${BUILD_PREFIX}/${HOST}/sysroot/usr/lib"
fi

export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
export CFLAGS="$CFLAGS -fPIC -I$PREFIX/include"

mkdir build && cd build

cmake ${CMAKE_ARGS} -D CMAKE_INSTALL_PREFIX=$PREFIX \
      -D CMAKE_BUILD_TYPE=Release \
      -D FFTW3_ROOT=$PREFIX \
      -D GDAL_ROOT=$PREFIX \
      -D NETCDF_ROOT=$PREFIX \
      -D PCRE_ROOT=$PREFIX \
      -D ZLIB_ROOT=$PREFIX \
      -D CURL_ROOT=$PREFIX \
      -D BLA_VENDOR=Generic \
      -D GMT_ENABLE_OPENMP=TRUE \
      -D GMT_USE_THREADS=TRUE \
      -D GMT_LIBDIR=lib \
      -D DCW_ROOT=$DCW_DIR \
      -D GSHHG_ROOT=$GSHHG_DIR \
      -D COPY_GSHHG=FALSE \
      -D COPY_DCW=FALSE \
      -D GMT_INSTALL_TRADITIONAL_FOLDERNAMES=FALSE \
      -D GMT_INSTALL_MODULE_LINKS=FALSE \
      ..

make -j$CPU_COUNT
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
make check
fi
make install

# We are fixing the paths to dynamic library files inside library and binary
# files because something in 'make install' is doubling up the path to the
# library files. This only happens on OSX. Anyone who knows how to solve that
# problem is free to contact the maintainers.
if [[ "$(uname)" == "Darwin" ]];then
    install_name_tool -id $PREFIX/lib/libgmt.6.dylib $PREFIX/lib/libgmt.6.dylib
    install_name_tool -id $PREFIX/lib/libpostscriptlight.6.dylib $PREFIX/lib/libpostscriptlight.6.dylib
    install_name_tool -change $PREFIX/$PREFIX/lib/libgmt.6.dylib $PREFIX/lib/libgmt.6.dylib $PREFIX/lib/gmt/plugins/supplements.so
    install_name_tool -change $PREFIX/$PREFIX/lib/libpostscriptlight.6.dylib $PREFIX/lib/libpostscriptlight.6.dylib $PREFIX/lib/gmt/plugins/supplements.so
    install_name_tool -change $PREFIX/$PREFIX/lib/libgmt.6.dylib $PREFIX/lib/libgmt.6.dylib $PREFIX/bin/gmt
    install_name_tool -change $PREFIX/$PREFIX/lib/libpostscriptlight.6.dylib $PREFIX/lib/libpostscriptlight.6.dylib $PREFIX/bin/gmt
    install_name_tool -change $PREFIX/$PREFIX/lib/libpostscriptlight.6.dylib $PREFIX/lib/libpostscriptlight.6.dylib $PREFIX/lib/libgmt.6.dylib
fi
