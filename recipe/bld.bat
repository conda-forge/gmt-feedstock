:: TODO: maybe split this into another package.
set DATADIR="%LIBRARY_PREFIX%\share\coast"
if not exist %DATADIR% mkdir %DATADIR%

:: GSHHG (coastlines, rivers, and political boundaries):
rem set EXT="tar.gz"
rem set GSHHG="gshhg-gmt-2.3.6"
rem set URL="ftp://ftp.iag.usp.br/pub/gmt/%GSHHG%.%EXT%"
rem curl %URL% > %GSHHG%.%EXT%
rem tar xzf %GSHHG%.%EXT%
rem cp %GSHHG%/* %DATADIR%

:: DCW (country polygons):
rem DCW="dcw-gmt-1.1.2"
rem URL="ftp://ftp.soest.hawaii.edu/dcw/%DCW%.%EXT%"
rem curl %URL% > %DCW%.%EXT%
rem tar xzf %DCW%.%EXT%
rem cp %DCW%/* %DATADIR%

mkdir build
cd build

rem -D DCW_ROOT=%DATADIR% ^
rem -D GSHHG_ROOT=%DATADIR% ^

cmake -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -D FFTW3_ROOT=%LIBRARY_PREFIX% ^
      -D GDAL_ROOT=%LIBRARY_PREFIX% ^
      -D NETCDF_ROOT=%LIBRARY_PREFIX% ^
      -D PCRE_ROOT=%LIBRARY_PREFIX% ^
      -D ZLIB_ROOT=%LIBRARY_PREFIX% ^
      -D GMT_LIBDIR=%LIBRARY_PREFIX%\lib ^
      %SRC_DIR%
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

ctest
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
