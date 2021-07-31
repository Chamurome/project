# module:           tools
# version:          1.0.0
# brief             helper functions and macros.

include_guard(GLOBAL)
include(CMakeParseArguments)

# Muestra mensaje de estado si SHOW_INFO es ON
# MSG           mensaje
# ARGV1         projecto que envia el mensaje(por omisión el actual)
function(info)
    if(SHOW_INFO)
        status(${ARGN})
    endif()
endfunction(info)

# Muestra mensaje de estado 
# MSG           mensaje
# ARGV1         projecto que envia el mensaje(por omisión el actual)
function(status)
    message(STATUS "${PROJECT_NAME}> ${ARGN}")
endfunction(status)

macro(var_info _var)
    if(DEFINED "${_var}")
        info("${_var}: ${${_var}}" ${ARGN})
    endif(DEFINED "${_var}")
endmacro(var_info _var)

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

# Determina un valor en función de BOOL_VALUE.
# BOOL_VALUE        valor que determina la salida. Si se omite ARGV4(output)
#                   el valor determinado es reasignado a esta variable.
# TRUE_VALUE        Valor devuelto si BOOL_VALUE es true.
# FALSE_VALUE       Valor devuelto si BOOL_VALUE es false.
# ARV4(output)      Opcional. Variable de salida. Si se omite se asigna a BOOL_VALUE.
function(cond BOOL_VALUE TRUE_VALUE FALSE_VALUE)

    set(OUTPUT ${BOOL_VALUE})
    if(ARGC EQUAL 4)
        set(OUTPUT ${ARGV3})
    endif(ARGC EQUAL 4)
    
    set(EXPR ${${BOOL_VALUE}})
    if(EXPR)
        string(TOUPPER ${EXPR} EXPR)
        if(EXPR STREQUAL 0 OR EXPR STREQUAL OFF OR EXPR STREQUAL FALSE OR EXPR STREQUAL "")
            set(EXPR FALSE)
        else()
            set(EXPR TRUE)
        endif()
    endif(EXPR)

    if(EXPR)
        set(${OUTPUT} ${TRUE_VALUE} PARENT_SCOPE)
    else(EXPR)
        set(${OUTPUT} ${FALSE_VALUE} PARENT_SCOPE)
    endif(EXPR)

endfunction(cond BOOL_VALUE TRUE_VALUE FALSE_VALUE)


# escanea el directorio recursivamente para los patrones glob indicados
# devuelve rutas relativas a dir.
function(get_files _dir _out)

    set(RESULT "")
    set(pat "")
    foreach(it ${ARGN})
        list(APPEND pat ${_dir}/${it})
    endforeach(it ${ARGN})
    
    if(IS_DIRECTORY ${_dir})
        file(GLOB_RECURSE RESULT LIST_DIRECTORIES false RELATIVE ${_dir} CONFIGURE_DEPENDS ${pat})
    endif(IS_DIRECTORY ${_dir})

    set("${_out}" ${RESULT} PARENT_SCOPE)

endfunction(get_files _dir _out)


# escanea el directorio para las extensiones .cpp .cxx .c
macro(get_sources _dir _out)
    get_files(${_dir} ${_out} *.cpp *.cxx *.c)
endmacro(get_sources _dir _out)
 
# escanea el directorio para las extensiones .hpp .hxx .h
macro(get_headers _dir _out)
    get_files(${_dir} ${_out} *.hpp *.hxx *.h)
endmacro(get_headers _dir _out)

# toma todos los ficheros .in de from_dir y los procesa con configure file
# dejando en to_dir el resultado.
# Los nombre de fichero se generan quitando el .in del nombre.
function(config_headers _from_dir _to_dir)
    get_files(${_from_dir} files *.in)
    foreach(it ${files})
        get_filename_component(name ${it} NAME_WLE)
        get_filename_component(dir ${it} DIRECTORY)
        configure_file("${_from_dir}/${it}" "${_to_dir}/${dir}/${name}")
    endforeach(it ${files})
    
endfunction(config_headers)