cmake_minimum_required(VERSION 3.5)

set(SHOW_INFO FALSE CACHE BOOL "" FORCE)
set(CMAKE_INSTALL_PREFIX "${CMAKE_SOURCE_DIR}/installed")
list(APPEND CMAKE_MODULE_PATH  "${CMAKE_SOURCE_DIR}/cmake")
 
include(cxx_compiler_config)
include(config_target)
include(load_tests)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

project(mmo)
config_target(mmo
    TYPE static
    SRC_DIR src
    INC_DIR include
    TEST_DIR test
    TEST_FRAMEWORK googletest
    ALIAS lib::sum
    LIBRARIES subtract
    SUBS_DIR extern
    SUBPROJECTS subtract
    INSTALL_BIN_DIR lib
    INSTALL_INC_DIR include
)
