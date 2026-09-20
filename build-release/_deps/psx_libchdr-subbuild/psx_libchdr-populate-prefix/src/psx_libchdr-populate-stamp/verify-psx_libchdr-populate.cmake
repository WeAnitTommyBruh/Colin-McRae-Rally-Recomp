# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION ${CMAKE_VERSION}) # this file comes with cmake

if("/home/tommy/Documents/ColinMcRaeRallyRecomp/psxrecomp/third_party/libchdr-6cde5348eb118da3baf94f75a69577a005a484fd.tar.gz" STREQUAL "")
  message(FATAL_ERROR "LOCAL can't be empty")
endif()

if(NOT EXISTS "/home/tommy/Documents/ColinMcRaeRallyRecomp/psxrecomp/third_party/libchdr-6cde5348eb118da3baf94f75a69577a005a484fd.tar.gz")
  message(FATAL_ERROR "File not found: /home/tommy/Documents/ColinMcRaeRallyRecomp/psxrecomp/third_party/libchdr-6cde5348eb118da3baf94f75a69577a005a484fd.tar.gz")
endif()

if("SHA256" STREQUAL "")
  message(WARNING "File cannot be verified since no URL_HASH specified")
  return()
endif()

if("a222b1f1c842f988c2aad51e5f56ba94a423ed87ccab71f1abdb757caa7444f5" STREQUAL "")
  message(FATAL_ERROR "EXPECT_VALUE can't be empty")
endif()

message(VERBOSE "verifying file...
     file='/home/tommy/Documents/ColinMcRaeRallyRecomp/psxrecomp/third_party/libchdr-6cde5348eb118da3baf94f75a69577a005a484fd.tar.gz'")

file("SHA256" "/home/tommy/Documents/ColinMcRaeRallyRecomp/psxrecomp/third_party/libchdr-6cde5348eb118da3baf94f75a69577a005a484fd.tar.gz" actual_value)

if(NOT "${actual_value}" STREQUAL "a222b1f1c842f988c2aad51e5f56ba94a423ed87ccab71f1abdb757caa7444f5")
  message(FATAL_ERROR "error: SHA256 hash of
  /home/tommy/Documents/ColinMcRaeRallyRecomp/psxrecomp/third_party/libchdr-6cde5348eb118da3baf94f75a69577a005a484fd.tar.gz
does not match expected value
  expected: 'a222b1f1c842f988c2aad51e5f56ba94a423ed87ccab71f1abdb757caa7444f5'
    actual: '${actual_value}'
")
endif()

message(VERBOSE "verifying file... done")
