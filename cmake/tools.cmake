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

macro(check_tests)
    set(TEST test)
    if(ARGC EQUAL 1)
        set(TEST ${ARGV0})
    endif()
    if("${CMAKE_PROJECT_NAME}" STREQUAL "${PROJECT_NAME}")
        include(CTest)
        if(BUILD_TESTING)
            status("Configurando tests ${PROJECT_NAME}")
            add_subdirectory(${TEST})
        endif(BUILD_TESTING)
    endif()
endmacro(check_tests)

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

# escanea el directorio para las extensiones .cpp .cxx .c
function(get_sources DIR OUTPUT)

    set(RESULT "")
    
    if(IS_DIRECTORY ${DIR})
        file(GLOB_RECURSE RESULT LIST_DIRECTORIES false CONFIGURE_DEPENDS "${DIR}/*.cpp" "${DIR}/*.cxx" "${DIR}/*.c")
    endif(IS_DIRECTORY ${DIR})

    set("${OUTPUT}" ${RESULT} PARENT_SCOPE)

endfunction(get_sources DIR OUTPUT)

 
# escanea el directorio para las extensiones .hpp .hxx .h
function(get_headers DIR OUTPUT)

    set(RESULT "")
    
    if(IS_DIRECTORY ${DIR})
        file(GLOB_RECURSE RESULT LIST_DIRECTORIES false CONFIGURE_DEPENDS "${DIR}/*.hpp" "${DIR}/*.hxx" "${DIR}/*.h")
    endif(IS_DIRECTORY ${DIR})

    set("${OUTPUT}" ${RESULT} PARENT_SCOPE)

endfunction(get_headers DIR OUTPUT)

function(to_real_path _root _output)
    set(res "")
    foreach(file ${ARGN})
        file(REAL_PATH "${file}" file BASE_DIRECTORY "${_root}" )
        list(APPEND res ${file})
    endforeach(file ${ARGN})
    set(${_output} ${res} PARENT_SCOPE)
endfunction(to_real_path _root)
 
 
