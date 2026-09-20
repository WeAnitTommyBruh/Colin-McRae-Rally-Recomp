# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION ${CMAKE_VERSION}) # this file comes with cmake

# If CMAKE_DISABLE_SOURCE_CHANGES is set to true and the source directory is an
# existing directory in our source tree, calling file(MAKE_DIRECTORY) on it
# would cause a fatal error, even though it would be a no-op.
if(NOT EXISTS "/home/tommy/Documents/ColinMcRaeRallyRecomp/build-release/_deps/psx_libchdr-src")
  file(MAKE_DIRECTORY "/home/tommy/Documents/ColinMcRaeRallyRecomp/build-release/_deps/psx_libchdr-src")
endif()
file(MAKE_DIRECTORY
  "/home/tommy/Documents/ColinMcRaeRallyRecomp/build-release/_deps/psx_libchdr-build"
  "/home/tommy/Documents/ColinMcRaeRallyRecomp/build-release/_deps/psx_libchdr-subbuild/psx_libchdr-populate-prefix"
  "/home/tommy/Documents/ColinMcRaeRallyRecomp/build-release/_deps/psx_libchdr-subbuild/psx_libchdr-populate-prefix/tmp"
  "/home/tommy/Documents/ColinMcRaeRallyRecomp/build-release/_deps/psx_libchdr-subbuild/psx_libchdr-populate-prefix/src/psx_libchdr-populate-stamp"
  "/home/tommy/Documents/ColinMcRaeRallyRecomp/build-release/_deps/psx_libchdr-subbuild/psx_libchdr-populate-prefix/src"
  "/home/tommy/Documents/ColinMcRaeRallyRecomp/build-release/_deps/psx_libchdr-subbuild/psx_libchdr-populate-prefix/src/psx_libchdr-populate-stamp"
)

set(configSubDirs )
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "/home/tommy/Documents/ColinMcRaeRallyRecomp/build-release/_deps/psx_libchdr-subbuild/psx_libchdr-populate-prefix/src/psx_libchdr-populate-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "/home/tommy/Documents/ColinMcRaeRallyRecomp/build-release/_deps/psx_libchdr-subbuild/psx_libchdr-populate-prefix/src/psx_libchdr-populate-stamp${cfgdir}") # cfgdir has leading slash
endif()
