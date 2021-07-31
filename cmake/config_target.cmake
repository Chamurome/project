#   module:     config_target.cmake 
#   version:    0.1.0
#   brief:      automatiza la creación de objetivos simples.

include_guard(GLOBAL)
include(target_attributes)

# establece los directorios de inclusion
macro(_set_includes)

    target_include_directories(${NAME}
        PUBLIC "${${ID}_INC_DIR}"
    )

    if(DEFINED ${ID}_LOC_INC_DIR)
        target_include_directories(${NAME}
            PRIVATE "${${ID}_LOC_INC_DIR}"
        )
    endif (DEFINED ${ID}_LOC_INC_DIR)

    if(DEFINED ${ID}_INCLUDES)
        target_include_directories(${NAME}
            PRIVATE "${${ID}_INCLUDES}"
        )
    endif(DEFINED ${ID}_INCLUDES)

endmacro(_set_includes)

macro(_set_libraries)
    if(DEFINED ${ID}_LIBRARIES)
        target_link_libraries(${NAME}
            "${${ID}_LIBRARIES}"
        )
    endif(DEFINED ${ID}_LIBRARIES)    
endmacro(_set_libraries)

macro(_set_install_dirs)
    if(DEFINED ${ID}_INSTALL_BIN_DIR)
        install(TARGETS ${NAME} DESTINATION ${${ID}_INSTALL_BIN_DIR})
    endif(DEFINED ${ID}_INSTALL_BIN_DIR)

    if(DEFINED ${ID}_INSTALL_INC_DIR)
        install(FILES ${${ID}_INC_FILES} DESTINATION ${${ID}_INSTALL_INC_DIR})
    endif(DEFINED ${ID}_INSTALL_INC_DIR)

endmacro(_set_install_dirs)

# configura una libreria con los parámetros determinados por target_attributes
function(_config_library NAME)
    target_attributes(${NAME} ${ARGN})
    show_attributes()

    cmake_language(CALL
        add_library
        "${NAME}"
        "${${ID}_TYPE}"
        "${${ID}_INC_FILES}" 
        "${${ID}_SRC_FILES}"
    )

    _set_includes()
    _set_libraries()   
    
    if(DEFINED ${ID}_ALIAS)
        add_library("${${ID}_ALIAS}" ALIAS ${NAME})
    endif(DEFINED ${ID}_ALIAS)
    
    _set_install_dirs()
endfunction(_config_library NAME)

# configura un executable con los parámetros determinados por target_attributes
function(_config_executable  NAME)
    target_attributes(${NAME} ${ARGN})
    show_attributes()

    add_executable(${NAME}
        "${${ID}_SRC_FILES}"
        "${${ID}_INC_FILES}"
    )

    if(DEFINED ${ID}_INC_FILES)
        _set_includes()
    endif(DEFINED ${ID}_INC_FILES)
    
    _set_libraries()

    _set_install_dirs()

endfunction(_config_executable NAME)

# configura una linreria de cabeceras con los parámetros determinados por target_attributes
function(_config_interface NAME)
    target_attributes(${NAME} ${ARGN})
    show_attributes()

    add_library(${NAME} INTERFACE)

    if(DEFINED ${ID}_ALIAS)
        add_library("${${ID}_ALIAS}" ALIAS ${NAME})
    endif(DEFINED ${ID}_ALIAS)
    
    target_include_directories(${NAME}
        INTERFACE 
            "${${ID}_INC_DIR}"
    )

    _set_install_dirs()

endfunction(_config_interface NAME)

 
function(config_target NAME)
    target_attributes(${NAME} ${ARGN})
    if(DEFINED ${ID}_SUBPROJECTS)
        foreach(SUB ${${ID}_SUBPROJECTS})
            add_subdirectory("${${ID}_SUBS_DIR}/${SUB}")
        endforeach()
    endif(DEFINED ${ID}_SUBPROJECTS)

    if("${${ID}_TYPE}" STREQUAL "EXE")
        _config_executable(${NAME} ${ARGN})
    elseif("${${ID}_TYPE}" STREQUAL "INTERFACE")
        _config_interface(${NAME} ${ARGN})
    else()
        _config_library(${NAME} ${ARGN})
    endif()

    if(DEFINED ${ID}_TEST_DIR AND "${CMAKE_PROJECT_NAME}" STREQUAL "${PROJECT_NAME}")
        status("Configurando test en ${${ID}_TEST_DIR}")
        # Asegura la creacion de DartConfiguration
        include(CTest) 
        if(DEFINED ${ID}_TEST_FRAMEWORK)
            include(FetchContent)
            FetchContent_Declare(
                ${${ID}_TEST_FRAMEWORK}
                GIT_REPOSITORY ${${ID}_TEST_GIT}
                GIT_TAG        ${${ID}_TEST_GIT_TAG}
            )
            FetchContent_MakeAvailable(${${ID}_TEST_FRAMEWORK})
        endif()
        add_subdirectory(${${ID}_TEST_DIR})
    endif(DEFINED ${ID}_TEST_DIR AND "${CMAKE_PROJECT_NAME}" STREQUAL "${PROJECT_NAME}")
    
endfunction(config_target NAME)
