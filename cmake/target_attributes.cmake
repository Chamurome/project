#   module:     target_attributes.cmake 
#   version:    0.1.0
#   brief:      determina las propiedades de objetivos simples a partir de ciertos parámetros.

include_guard(GLOBAL)
include(tools)


#
# Determina atributos para un objetivo dado
#
# ROOT Directorio raiz del objetivo(p.o. el del projecto)
# TYPE APP, STATIC, SHARED o INTERFACE (tipo de objetivo)
# INC_DIR           directorio de cabeceras relativo a ROOT(p.o. ROOT)
# SCR_DIR           directorio de fuentes relativo a ROOT(p.o. ROOT)
# SUBS_DIR          directorio donde se alojan los projectos externos(SUBPROJECTS)
# TEST_DIR          directorio con las pruebas(Si se indica se asignan TEST_FRAMEWORK, TEST_GIT, TEST_GIT_TAG).
# INC_FILES         ficheros de cabecera(p.o. los .h .hpp .hxx contenidos en INC_DIR o INC_DIR/INC_SUFFIX)
# SRC_FILES         ficheros de cabecera(p.o. los .c .cpp .cxx contenidos en SRC_DIR)
# INC_SUFFIX        Indica la carpeta dentro de INC_DIR donde estan las cabeceras esto hace que
#                   los objetivos que se vinculen deban usar #include "INC_SUFFIX/traget-name" mientras que en el propio
#                   projecto se puede usar #include "target-name"
# ALIAS             Alias para los objetivos de biblioteca
# LIBRARIES         Librerias a que vincular el objetivo
# INCLUDES          Cabeceras extras a adjuntar privadamente.
# SUBPROJECTS       Lista de subprojectos(subdirectorios externos)
# TEST_FRAMEWORK    Nombre del framework para testear(googletest)
# TEST_GIT          Dirección repositorio Git
# TEST_GIT_TAG      Tag del repositorio a descargar.
# INSTALLABLE       Prepara el objetivo para la instalación.
function(target_attributes _name)
    set(options INSTALLABLE)
    set(singles 
        ROOT TYPE 
        TEST_DIR INC_DIR SRC_DIR 
        INC_FILES SRC_FILES 
        INC_SUFFIX ALIAS 
        SUBS_DIR
        TEST_FRAMEWORK TEST_GIT TEST_GIT_TAG
    )
    set(multiples LIBRARIES INCLUDES SUBPROJECTS)

    message("*** ${NAME} ${ARGN}") 
    string(TOUPPER ${_name} ID)
    cmake_parse_arguments(${ID} "${options}" "${singles}" "${multiples}" ${ARGN} )

    ensure("${ID}_TYPE" "exe")
    cond(${ID}_ROOT "${PROJECT_SOURCE_DIR}/${${ID}_ROOT}" "${PROJECT_SOURCE_DIR}")
    
    string(TOUPPER "${${ID}_TYPE}" "${ID}_TYPE")
    
    if(DEFINED ${ID}_SRC_DIR)
        file(REAL_PATH "${${ID}_SRC_DIR}" ${ID}_SRC_DIR BASE_DIRECTORY "${${ID}_ROOT}" )
        
        if(NOT DEFINED ${ID}_SRC_FILES)
            get_sources("${${ID}_SRC_DIR}" "${ID}_SRC_FILES")
            push_up(${ID}_SRC_FILES)
        endif()
        to_real_path(${${ID}_SRC_DIR} ${ID}_SRC_FILES ${${ID}_SRC_FILES})
       
        set(${ID}_SRC_DIR ${${ID}_SRC_DIR} PARENT_SCOPE)

    endif(DEFINED ${ID}_SRC_DIR)
    push_up(${ID}_SRC_FILES)

    if(DEFINED ${ID}_INC_DIR)
        file(REAL_PATH "${${ID}_INC_DIR}" ${ID}_INC_DIR BASE_DIRECTORY "${${ID}_ROOT}" )

        if(DEFINED ${ID}_INC_SUFFIX)
            set(real_path "${${ID}_INC_DIR}/${${ID}_INC_SUFFIX}")
            set(${ID}_LOC_INC_DIR ${real_path} PARENT_SCOPE)  
            set(${ID}_INC_SUFFIX ${${ID}_INC_SUFFIX} PARENT_SCOPE)  
        else(DEFINED ${ID}_INC_SUFFIX)
            set(real_path "${${ID}_INC_DIR}")
        endif(DEFINED ${ID}_INC_SUFFIX)

        if(NOT DEFINED ${ID}_INC_FILES)
            get_headers("${real_path}" ${ID}_INC_FILES)
            to_real_path("${real_path}" ${ID}_INC_FILES ${${ID}_INC_FILES})
        endif()
        to_real_path("${real_path}" ${ID}_INC_FILES ${${ID}_INC_FILES})

        set(${ID}_INC_DIR ${${ID}_INC_DIR} PARENT_SCOPE)

    endif(DEFINED ${ID}_INC_DIR)
    push_up(${ID}_INC_FILES)
    
    if(DEFINED ${ID}_TEST_DIR)
        _prepare_tests()
    endif(DEFINED ${ID}_TEST_DIR)
    

    if(NOT "${${ID}_TYPE}" STREQUAL "APP" AND NOT "${${ID}_TYPE}" STREQUAL "EXE")
        push_up(${ID}_ALIAS)
    endif(NOT "${${ID}_TYPE}" STREQUAL "APP" AND NOT "${${ID}_TYPE}" STREQUAL "EXE")
    
    set(ID                      ${ID}                   PARENT_SCOPE)
    set(${ID}_TYPE              ${${ID}_TYPE}           PARENT_SCOPE)
    set(${ID}_SUBS_DIR          ${${ID}_SUBS_DIR}       PARENT_SCOPE)

    push_up(${ID}_INCLUDES)
    push_up(${ID}_SUBPROJECTS)
    push_up(${ID}_LIBRARIES)
    push_up(${ID}_INSTALLABLE)
    
endfunction(target_attributes)


# Muestra los atributos del objetivo ${ID}
macro(show_attributes)
    var_info("${ID}_TYPE")
    var_info("${ID}_ALIAS")
    var_info("${ID}_SRC_DIR")
    var_info("${ID}_INC_DIR")
    var_info("${ID}_SUBS_DIR")
    var_info("${ID}_TEST_DIR")
    var_info("${ID}_SRC_FILES")
    var_info("${ID}_INC_FILES")
    var_info("${ID}_INC_SUFFIX")
    var_info("${ID}_LIBRARIES")
    var_info("${ID}_LOC_INC_DIR")
    var_info("${ID}_INCLUDES")
    var_info("${ID}_SUBPROJECTS")
    var_info("${ID}_INSTALLABLE")
    var_info("${ID}_TEST_FRAMEWORK")
    var_info("${ID}_TEST_GIT")
    var_info("${ID}_TEST_GIT_TAG")
endmacro(show_attributes)

macro(_prepare_tests)
    if(DEFINED ${ID}_TEST_FRAMEWORK)
    if(${${ID}_TEST_FRAMEWORK} STREQUAL "googletest")
        cond(${ID}_TEST_GIT "${${ID}_TEST_GIT}" "https://github.com/google/googletest.git")
        cond(${ID}_TEST_GIT_TAG "${${ID}_TEST_GIT_TAG}" "release-1.11.0")
    else()
        message(WRANING "Unknown test framework")
    endif()
    set(${ID}_TEST_FRAMEWORK "${${ID}_TEST_FRAMEWORK}" PARENT_SCOPE)
    set(${ID}_TEST_GIT "${${ID}_TEST_GIT}" PARENT_SCOPE)
    set(${ID}_TEST_GIT_TAG "${${ID}_TEST_GIT_TAG}" PARENT_SCOPE)        
    endif()
    set(${ID}_TEST_DIR "${${ID}_TEST_DIR}" PARENT_SCOPE)    
endmacro(_prepare_tests)
