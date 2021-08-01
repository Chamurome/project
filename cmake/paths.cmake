# -----------------------------------------------------------------------------
# module:           paths
# version:          1.0.0
# brief             helper functions for paths operations.
# -----------------------------------------------------------------------------

include_guard(GLOBAL)
include(CMakeParseArguments)

# -----------------------------------------------------------------------------
# Realiza operaciones sobre rutas
#
# paths(ABSOLUTE <output> [ROOT <root_dir>] <relative...>)
#   Convierte en absolutas la lista de rutas relativas con base en ROOT
# paths(RELATIVE <output> [ROOT <root_dir>] <relative...>)
#   Convierte en relativas la lista de rutas absolutas con base en ROOT
# path(FILES <output> [ROOT <root_dir>] [RECURSIVE] PATTERNS <glob-expr...>)
#   Escanea directorio ROOT en busca de ficheros coincidentes con las expresiones
#    glob. Estas busquedas se rechequean con cada construcción(CONFIGURE_DEPENDS)
# path(SOURCES <output> [ROOT <root_dir>] [RECURSIVE])
# path(HEADERS <output> [ROOT <root_dir>] [RECURSIVE])
#   Como FILES, pero con los patrones
#       *.cpp *.cxx *.c para SOURCES y
#       *.hpp *.hxx *.h para HEADERS
# 
# ROOT, por omisión, es el valor de PROJECT_SOURCE_DIR 
# -----------------------------------------------------------------------------
function(paths _cmd _out )
    set(options RECURSIVE)
    set(singles ROOT)
    set(multiples PATHS PATTERNS)

    cmake_parse_arguments(_arg "${options}" "${singles}" "${multiples}" ${ARGN} )
    
    set(res "")
    ensure(_arg_ROOT ${PROJECT_SOURCE_DIR})
    if("${_cmd}" STREQUAL ABSOLUTE)
        foreach(file ${_arg_PATHS})
            file(REAL_PATH "${file}" file BASE_DIRECTORY "${_arg_ROOT}" )
            list(APPEND res ${file})
        endforeach(file ${_arg_PATHS})
    elseif("${_cmd}" STREQUAL RELATIVE)
        foreach(file ${_arg_PATHS})
            file(RELATIVE_PATH file "${_arg_ROOT}" "${file}")
            list(APPEND res ${file})
        endforeach(file ${_arg_PATHS})
    elseif("${_cmd}" STREQUAL FILES)
        if(NOT DEFINED _arg_PATTERNS)
            message(FATAL_ERROR "No pattern argunments for paths function")
        endif()
        foreach(it ${_arg_PATTERNS})
            file(REAL_PATH "${it}" file BASE_DIRECTORY "${_arg_ROOT}" )
            list(APPEND pats ${file})
        endforeach(it ${ARGN})
        if(IS_DIRECTORY ${_arg_ROOT})
            if(_arg_RECURSIVE)
                file(GLOB_RECURSE res LIST_DIRECTORIES false RELATIVE ${_arg_ROOT} CONFIGURE_DEPENDS ${pats})
            else()
                file(GLOB res LIST_DIRECTORIES false RELATIVE ${_arg_ROOT} CONFIGURE_DEPENDS ${pats})
            endif()
        endif()
    elseif("${_cmd}" STREQUAL SOURCES)
        _find_glob_patterns(res ${_arg_ROOT} ${_arg_RECURSIVE} "*.cpp;*.cxx;*.c")
    elseif("${_cmd}" STREQUAL HEADERS)
        _find_glob_patterns(res ${_arg_ROOT} ${_arg_RECURSIVE} "*.hpp;*.hxx;*.h")    
    endif()
    set(${_out} ${res} PARENT_SCOPE)
endfunction()

function(_find_glob_patterns _out _root _recursive _patterns)
    if(_recursive)
        paths(FILES res ROOT ${_root} RECURSIVE PATTERNS ${_patterns})
    else()
        paths(FILES res ROOT ${_root} PATTERNS ${_patterns})
    endif()
    set(${_out} ${res} PARENT_SCOPE)
endfunction()