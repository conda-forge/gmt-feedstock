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

cmake -D CMAKE_INSTALL_PREFIX=$PREFIX \
      -D FFTW3_ROOT=$PREFIX \
      -D GDAL_ROOT=$PREFIX \
      -D NETCDF_ROOT=$PREFIX \
      -D PCRE_ROOT=$PREFIX \
      -D ZLIB_ROOT=$PREFIX \
      -D LIBCURL_ROOT=$PREFIX \
      -DLAPACK_LIBRARIES=$PREFIX/lib/liblapack${SHLIB_EXT} \
      -D GMT_LIBDIR=$PREFIX/lib \
      -D DCW_ROOT=$DCW_DIR \
      -D GSHHG_ROOT=$GSHHG_DIR \
      -D GMT_INSTALL_TRADITIONAL_FOLDERNAMES:BOOL=FALSE \
      -D GMT_INSTALL_MODULE_LINKS:BOOL=FALSE \
      ..

make -j$CPU_COUNT
make check
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
