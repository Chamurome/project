function(load_test _test)
    if("${CMAKE_PROJECT_NAME}" STREQUAL "${PROJECT_NAME}")
        status("Configurando test")
        # Asegura la creacion de DartConfiguration
        include(CTest)
        if(BUILD_TESTING)
            include(FetchContent)
            FetchContent_Declare(
                googletest
                GIT_REPOSITORY https://github.com/google/googletest.git
                GIT_TAG        release-1.11.0
            )
            FetchContent_MakeAvailable(googletest)
            include(GoogleTest)
            add_subdirectory(${_test})
        endif(BUILD_TESTING)
    endif()
endfunction(load_test)