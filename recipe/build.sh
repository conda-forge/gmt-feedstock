#!/bin/bash

GSHHG_DIR="$PREFIX/share/gshhg-gmt"

# TODO: Maybe split this into another package.
DATADIR="$PREFIX/share/coast"
mkdir -p $DATADIR

# DCW (country polygons):
DCW="dcw-gmt-1.1.2"
URL="ftp://ftp.soest.hawaii.edu/dcw/$DCW.$EXT"
curl $URL > $DCW.$EXT
tar xzf $DCW.$EXT
cp $DCW/* $DATADIR

export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"

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
      $SRC_DIR

make -j$CPU_COUNT
make check
make install
