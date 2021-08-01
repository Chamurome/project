# -----------------------------------------------------------------------------
# module:           tools
# version:          2.0.0
# brief:            helper functions and macros.
# news:             
# - Replace functions info and status by module info
# - Replace functions get_files, get_sources, get_headers and to_real_path by
#   module paths.
# -----------------------------------------------------------------------------

include_guard(GLOBAL)
include(CMakeParseArguments)
include(paths)
include(info)

# asegura que _name tenga un valor(p.o. _default)
macro(ensure _name _default)
    if(NOT DEFINED ${_name})
        set(${_name} ${_default})
    endif(NOT DEFINED ${_name})
endmacro(ensure _name _default)

# si la variable esta definida la pone al alcance del padre.
macro(push_up _var)
    if(DEFINED "${_var}")
        set("${_var}" "${${_var}}" PARENT_SCOPE)
    endif(DEFINED "${_var}")
endmacro(push_up _var)

# -----------------------------------------------------------------------------
# Determina un valor en función de _bool.
# cond(<bool> <true> <false> [<out>])
#   bool              valor que determina la salida.
#                     el valor determinado es reasignado a esta variable.
#   true              Valor devuelto si _bool es true.
#   false             Valor devuelto si _bool es false.
#   out               Variable de salida(p.o. <bool>).
#
# <bool> Se considera false si es 0, OFF, FALSE o una cadena vacía. En 
# cualquier otro caso true.
# -----------------------------------------------------------------------------
function(cond _bool _true _false)

    set(OUTPUT ${_bool})
    if(ARGC EQUAL 4)
        set(OUTPUT ${ARGV3})
    endif(ARGC EQUAL 4)
    
    set(EXPR ${${_bool}})
    if(EXPR)
        string(TOUPPER ${EXPR} EXPR)
        if(EXPR STREQUAL 0 OR EXPR STREQUAL OFF OR EXPR STREQUAL FALSE OR EXPR STREQUAL "")
            set(EXPR FALSE)
        else()
            set(EXPR TRUE)
        endif()
    endif(EXPR)

    if(EXPR)
        set(${OUTPUT} ${_true} PARENT_SCOPE)
    else(EXPR)
        set(${OUTPUT} ${_false} PARENT_SCOPE)
    endif(EXPR)

endfunction(cond _bool _true _false)


# -----------------------------------------------------------------------------
# toma todos los ficheros .in de from_dir y los procesa con configure_file
# dejando en to_dir el resultado.
# Los nombre de fichero se generan quitando el .in del nombre.
# -----------------------------------------------------------------------------
function(config_headers _from_dir _to_dir)
    file(REAL_PATH ${_from_dir} _from_dir BASE_DIRECTORY ${PROJECT_SOURCE_DIR})
    file(REAL_PATH ${_to_dir} _to_dir BASE_DIRECTORY ${PROJECT_BINARY_DIR})
    paths(FILES files ROOT ${_from_dir} RECURSIVE PATTERNS *.in)
    foreach(it ${files})
        get_filename_component(name ${it} NAME_WLE)
        get_filename_component(dir ${it} DIRECTORY)
        configure_file("${_from_dir}/${it}" "${_to_dir}/${dir}/${name}")
    endforeach(it ${files})
    
endfunction(config_headers)

 