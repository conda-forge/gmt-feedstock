#!/bin/bash

GSHHG_DIR="$PREFIX/share/gshhg-gmt"
DATADIR="$PREFIX/share/coast"

mkdir -p $DATADIR

# DCW (country polygons):
DCW="dcw-gmt-1.1.2"
URL="ftp://ftp.soest.hawaii.edu/dcw/$DCW.tar.gz"
curl $URL > $DCW.tar.gz
tar xzf $DCW.tar.gz
cp $DCW/* $DATADIR

#export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export LDFLAGS=

mkdir build && cd build

cmake -D CMAKE_INSTALL_PREFIX=$PREFIX \
      -D FFTW3_ROOT=$PREFIX \
      -D GDAL_ROOT=$PREFIX \
      -D NETCDF_ROOT=$PREFIX \
      -D PCRE_ROOT=$PREFIX \
      -D ZLIB_ROOT=$PREFIX \
      -D GMT_LIBDIR=$PREFIX/lib \
      -D DCW_ROOT=$DATADIR \
      -D GSHHG_ROOT=$GSHHG_DIR \
      -D GMT_INSTALL_TRADITIONAL_FOLDERNAMES:BOOL=FALSE \
      -D GMT_INSTALL_MODULE_LINKS:BOOL=FALSE \
      $SRC_DIR

make -j$CPU_COUNT
make check
make install

# We are fixing the paths to dynamic library files inside library and
# binary files because something in make install is doubling up the
# path to the library files.  Anyone who knows how to solve that
# problem is free to contact the maintainers.

if [[ "$(uname)" == "Darwin" ]];then
    install_name_tool -id $PREFIX/lib/libgmt.5.dylib $PREFIX/lib/libgmt.5.dylib
    install_name_tool -id $PREFIX/lib/libpostscriptlight.5.dylib $PREFIX/lib/libpostscriptlight.5.dylib

    install_name_tool -change $PREFIX/$PREFIX/lib/libgmt.5.dylib $PREFIX/lib/libgmt.5.dylib $PREFIX/lib/gmt/plugins/supplements.so
    install_name_tool -change $PREFIX/$PREFIX/lib/libpostscriptlight.5.dylib $PREFIX/lib/libpostscriptlight.5.dylib $PREFIX/lib/gmt/plugins/supplements.so

    install_name_tool -change $PREFIX/$PREFIX/lib/libgmt.5.dylib $PREFIX/lib/libgmt.5.dylib $PREFIX/bin/gmt
    install_name_tool -change $PREFIX/$PREFIX/lib/libpostscriptlight.5.dylib $PREFIX/lib/libpostscriptlight.5.dylib $PREFIX/bin/gmt

    install_name_tool -change $PREFIX/$PREFIX/lib/libpostscriptlight.5.dylib $PREFIX/lib/libpostscriptlight.5.dylib $PREFIX/lib/libgmt.5.4.2.dylib
fi
