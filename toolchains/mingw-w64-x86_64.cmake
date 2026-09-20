# Cross-compile a native Windows x64 build from Linux with MinGW-w64.
#   apt install gcc-mingw-w64-x86-64-posix g++-mingw-w64-x86-64-posix binutils-mingw-w64-x86-64
#   cmake -S . -B build-win -G Ninja -DCMAKE_BUILD_TYPE=Release \
#         -DCMAKE_TOOLCHAIN_FILE=toolchains/mingw-w64-x86_64.cmake
set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR x86_64)
set(_tc x86_64-w64-mingw32)
set(CMAKE_C_COMPILER   ${_tc}-gcc-posix)
set(CMAKE_CXX_COMPILER ${_tc}-g++-posix)
set(CMAKE_RC_COMPILER  ${_tc}-windres)
set(CMAKE_FIND_ROOT_PATH /usr/${_tc})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
