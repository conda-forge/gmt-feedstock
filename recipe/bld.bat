set LIBPATH=%LIBRARY_LIB%;%LIBPATH%
set INCLUDE=%LIBRARY_INC%;%INCLUDE%

:: VS2008 doesn't have stdbool.h so copy in our own
:: to 'lib' where the other headers are so it gets picked up.
if "%VS_MAJOR%" == "9" (
    copy %RECIPE_DIR%\stdbool.h src\
)

mkdir build
cd build

rem -D DCW_ROOT=%DATADIR% ^
rem -D GSHHG_ROOT=%DATADIR% ^

cmake -G "NMake Makefiles" ^
      -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
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
