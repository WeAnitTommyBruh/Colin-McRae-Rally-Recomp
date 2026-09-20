# Install script for directory: /home/tommy/src/ColinMcRaeRallyRecomp/build-recompiler/_deps/psx_libchdr-src

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/usr/local")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "1")
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set path to fallback-tool for dependency-resolution.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/usr/bin/objdump")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  foreach(file
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libchdr.so.0.3"
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libchdr.so.0"
      )
    if(EXISTS "${file}" AND
       NOT IS_SYMLINK "${file}")
      file(RPATH_CHECK
           FILE "${file}"
           RPATH "")
    endif()
  endforeach()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES
    "/home/tommy/src/ColinMcRaeRallyRecomp/build-recompiler/libchdr.so.0.3"
    "/home/tommy/src/ColinMcRaeRallyRecomp/build-recompiler/libchdr.so.0"
    )
  foreach(file
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libchdr.so.0.3"
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libchdr.so.0"
      )
    if(EXISTS "${file}" AND
       NOT IS_SYMLINK "${file}")
      if(CMAKE_INSTALL_DO_STRIP)
        execute_process(COMMAND "/usr/bin/strip" "${file}")
      endif()
    endif()
  endforeach()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "/home/tommy/src/ColinMcRaeRallyRecomp/build-recompiler/libchdr.so")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/libchdr" TYPE FILE FILES
    "/home/tommy/src/ColinMcRaeRallyRecomp/build-recompiler/_deps/psx_libchdr-src/include/libchdr/bitstream.h"
    "/home/tommy/src/ColinMcRaeRallyRecomp/build-recompiler/_deps/psx_libchdr-src/include/libchdr/cdrom.h"
    "/home/tommy/src/ColinMcRaeRallyRecomp/build-recompiler/_deps/psx_libchdr-src/include/libchdr/chd.h"
    "/home/tommy/src/ColinMcRaeRallyRecomp/build-recompiler/_deps/psx_libchdr-src/include/libchdr/chdconfig.h"
    "/home/tommy/src/ColinMcRaeRallyRecomp/build-recompiler/_deps/psx_libchdr-src/include/libchdr/coretypes.h"
    "/home/tommy/src/ColinMcRaeRallyRecomp/build-recompiler/_deps/psx_libchdr-src/include/libchdr/flac.h"
    "/home/tommy/src/ColinMcRaeRallyRecomp/build-recompiler/_deps/psx_libchdr-src/include/libchdr/huffman.h"
    "/home/tommy/src/ColinMcRaeRallyRecomp/build-recompiler/_deps/psx_libchdr-src/include/libchdr/macros.h"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/pkgconfig" TYPE FILE FILES "/home/tommy/src/ColinMcRaeRallyRecomp/build-recompiler/libchdr.pc")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/home/tommy/src/ColinMcRaeRallyRecomp/build-recompiler/_deps/psx_libchdr-build/tests/cmake_install.cmake")

endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/home/tommy/src/ColinMcRaeRallyRecomp/build-recompiler/_deps/psx_libchdr-build/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
