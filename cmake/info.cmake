include_guard(GLOBAL)
include(CMakeParseArguments)

# Muestra información siempre que _key esté en la lista INFO_KEYWORDS
# 
function(info _key _msg)

    # set(options VAR)
    # set(singles)
    # set(multiples)

    # cmake_parse_arguments(ARG "${options}" "${singles}" "${multiples}" ${ARGN} )

    list(FIND INFO_KEYWORDS ${_key} index)
    if(NOT ${index} EQUAL -1 OR "${_key}" STREQUAL ALL)
        if("${_key}" STREQUAL ALL)
            set(_key ${PROJECT_NAME})
        endif()
        if("${_msg}" STREQUAL VAR)
            # show variable if exists(_msg = var_name)
            foreach(it ${ARGN})
                if(DEFINED ${it})
                    message("${_key}> ${it}: ${${it}}")            
                endif()
            endforeach()
        elseif("${_msg}" STREQUAL ATTRIBUTES)
            # Show attributes list ARGN or all
            if(ARGC GREATER 2)
                set(tmp ${ARGN})
            else()
                set(tmp ${_ATTRIBS})
            endif()
            foreach(it ${tmp})
                if(DEFINED ${_key}_${it})
                    message("${_key}> ${it}: ${${_key}_${it}}")
                endif()
            endforeach()
        else()
            # show message
            message("${_key}> ${_msg} ${ARGN}")
        endif()
    endif()
endfunction()
