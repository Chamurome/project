# -----------------------------------------------------------------------------
#   module:     cxx_compiler_config 
#   version:    0.1.0
#   brief:      Determina flags de compilación en función del compilador.
# -----------------------------------------------------------------------------

include(tools)
include(info)

enable_language(CXX)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Debug CACHE STRING "Built type" FORCE)
endif()

 

set(CXX_FLAGS)
set(CXX_FLAGS_DEBUG ) # -fprofile-arcs -ftest-coverage
set(CXX_FLAGS_RELEASE)
set(CXX_DEFS)
set(CXX_DEFS_DEBUG "DEGUB")
set(CXX_DEFS_RELEASE "NDEBUG")


if(CMAKE_CXX_COMPILER_ID MATCHES Clang)
    list(APPEND CXX_FLAGS "-Wall" "-Wextra" "-pedantic" "-fcolor-diagnostics")
    list(APPEND CXX_FLAGS_DEBUG "-Wdocumentation") 
    list(APPEND CXX_FLAGS_RELEASE "-O3" "-Wno-unused")
elseif(CMAKE_CXX_COMPILER_ID MATCHES GNU)
    list(APPEND CXX_FLAGS "-fPIC" "-Wall" "-Wextra" "-pedantic")
    list(APPEND CXX_FLAGS_RELEASE "-O3" "-Wno-unused")
else()
    message(WARNING "Compilador no contemplado.Sólo se han considerado CLang y GNU")
endif()

# set compile options for the main executable
add_compile_options(${CXX_FLAGS}
     "$<$<CONFIG:Debug>:${CXX_FLAGS_DEBUG}>"
     "$<$<CONFIG:Release>:${CXX_FLAGS_RELEASE}>"
)

add_compile_definitions(${CXX_DEFS}
    "$<$<CONFIG:Debug>:${CXX_DEFS_DEBUG}>"
    "$<$<CONFIG:Release>:${CXX_DEFS_RELEASE}>"
)

info(compilation "Build type: ${CMAKE_BUILD_TYPE}")
info(compilation "Standard: ${CMAKE_CXX_STANDARD}")
info(compilation "Compiler path: ${CMAKE_CXX_COMPILER}")
info(compilation "Compiler ID: ${CMAKE_CXX_COMPILER_ID}")
info(compilation "Compiler version: ${CMAKE_CXX_COMPILER_VERSION}")
info(compilation "Compiler is part of GCC: ${CMAKE_COMPILER_IS_GNUCXX}")