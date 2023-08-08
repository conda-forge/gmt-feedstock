set LIBPATH=%LIBRARY_LIB%;%LIBPATH%
set INCLUDE=%LIBRARY_INC%;%INCLUDE%

mkdir build
cd build

set GSHHG_DIR="%LIBRARY_PREFIX%\share\gshhg-gmt"
set DCW_DIR="%LIBRARY_PREFIX%\share\dcw-gmt"

cmake -G "NMake Makefiles" ^
      -D CMAKE_BUILD_TYPE=Release ^
      -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -D FFTW3_ROOT=%LIBRARY_PREFIX% ^
      -D GDAL_ROOT=%LIBRARY_PREFIX% ^
      -D NETCDF_ROOT=%LIBRARY_PREFIX% ^
      -D PCRE_ROOT=%LIBRARY_PREFIX% ^
      -D ZLIB_ROOT=%LIBRARY_PREFIX% ^
      -D CURL_ROOT=%LIBRARY_PREFIX% ^
      -D GMT_ENABLE_OPENMP=TRUE ^
      -D GMT_USE_THREADS=TRUE ^
      -D GMT_LIBDIR=lib ^
      -D DCW_ROOT=%DCW_DIR% ^
      -D GSHHG_ROOT=%GSHHG_DIR% ^
      -D COPY_GSHHG=TRUE ^
      -D COPY_DCW=TRUE ^
      -D GMT_INSTALL_TRADITIONAL_FOLDERNAMES=FALSE ^
      -D GMT_INSTALL_MODULE_LINKS=FALSE ^
      %SRC_DIR%
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
