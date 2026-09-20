# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.31.6)

# Reject any attempt to use a toolchain file. We must not use one because
# we could be downloading it here. If the CMAKE_TOOLCHAIN_FILE environment
# variable is set, the cache variable will have been initialized from it.
unset(CMAKE_TOOLCHAIN_FILE CACHE)
unset(ENV{CMAKE_TOOLCHAIN_FILE})

# We name the project and the target for the ExternalProject_Add() call
# to something that will highlight to the user what we are working on if
# something goes wrong and an error message is produced.

project(psx_libchdr-populate NONE)



include(ExternalProject)
ExternalProject_Add(psx_libchdr-populate
                     "UPDATE_DISCONNECTED" "False" "DOWNLOAD_EXTRACT_TIMESTAMP" "TRUE" "EXTERNALPROJECT_INTERNAL_ARGUMENT_SEPARATOR" "URL" "/home/tommy/Documents/ColinMcRaeRallyRecomp/psxrecomp/third_party/libchdr-6cde5348eb118da3baf94f75a69577a005a484fd.tar.gz" "URL_HASH" "SHA256=a222b1f1c842f988c2aad51e5f56ba94a423ed87ccab71f1abdb757caa7444f5"
                    SOURCE_DIR          "/home/tommy/Documents/ColinMcRaeRallyRecomp/build-release/_deps/psx_libchdr-src"
                    BINARY_DIR          "/home/tommy/Documents/ColinMcRaeRallyRecomp/build-release/_deps/psx_libchdr-build"
                    CONFIGURE_COMMAND   ""
                    BUILD_COMMAND       ""
                    INSTALL_COMMAND     ""
                    TEST_COMMAND        ""
                    USES_TERMINAL_DOWNLOAD  YES
                    USES_TERMINAL_UPDATE    YES
                    USES_TERMINAL_PATCH     YES
)


