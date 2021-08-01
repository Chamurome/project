# -----------------------------------------------------------------------------
#   module:     target_attributes.cmake 
#   version:    2.0.0
#   brief:      determina las propiedades de objetivos simples a partir de ciertos parámetros.
# -----------------------------------------------------------------------------

include_guard(GLOBAL)
include(tools)


# -----------------------------------------------------------------------------
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
# -----------------------------------------------------------------------------
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
    
    if(NOT DEFINED _ATTRIBS)
        set(_ATTRIBS "${options};${singles};${multiples}" CACHE INTERNAL "Attribute names" FORCE)
    endif()
    
    string(TOUPPER ${_name} ID)
    cmake_parse_arguments(${ID} "${options}" "${singles}" "${multiples}" ${ARGN} )

    ensure("${ID}_TYPE" "exe")
    cond(${ID}_ROOT "${PROJECT_SOURCE_DIR}/${${ID}_ROOT}" "${PROJECT_SOURCE_DIR}")
    
    string(TOUPPER "${${ID}_TYPE}" "${ID}_TYPE")
    
    #get sources info
    if(DEFINED ${ID}_SRC_DIR)
        file(REAL_PATH "${${ID}_SRC_DIR}" ${ID}_SRC_DIR BASE_DIRECTORY "${${ID}_ROOT}" )
        
        if(NOT DEFINED ${ID}_SRC_FILES)
            paths(SOURCES ${ID}_SRC_FILES ROOT "${${ID}_SRC_DIR}" RECURSIVE)
            push_up(${ID}_SRC_FILES)
        endif()
        paths(ABSOLUTE ${ID}_SRC_FILES 
            ROOT "${${ID}_SRC_DIR}" 
            PATHS ${${ID}_SRC_FILES}
        )       
        set(${ID}_SRC_DIR ${${ID}_SRC_DIR} PARENT_SCOPE)

    endif(DEFINED ${ID}_SRC_DIR)
    push_up(${ID}_SRC_FILES)

    #get headers info
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
            paths(HEADERS ${ID}_INC_FILES ROOT "${real_path}" RECURSIVE)
            # to_real_path("${real_path}" ${ID}_INC_FILES ${${ID}_INC_FILES})
        endif()
        paths(ABSOLUTE ${ID}_INC_FILES 
            ROOT "${real_path}" 
            PATHS ${${ID}_INC_FILES}
        )

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

macro(push_up_attribs _id)
    foreach(it ${_ATTRIBS})
        push_up(${_id}_${it})
    endforeach()    
endmacro()

# Muestra los atributos del objetivo ${ID}
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
