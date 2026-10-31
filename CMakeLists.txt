cmake_minimum_required(VERSION 3.20)

# Optional per-machine overrides (compiler paths, flags, etc.)
# Missing file must not break configure on other devices.
include(${CMAKE_CURRENT_SOURCE_DIR}/local.require.cmake OPTIONAL)

project(ousia LANGUAGES C)

set(CMAKE_C_STANDARD 23)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

# clangd / IDE resolve headers from build/compile_commands.json
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

option(UNIT_TEST "Build with unit test sources under project/test" ON)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/output/bin)

set(_OUSA_SRC_DIR ${CMAKE_SOURCE_DIR}/project/src)
set(_OUSA_INC_DIR ${CMAKE_SOURCE_DIR}/project/inc)
set(_OUSA_TEST_DIR ${CMAKE_SOURCE_DIR}/project/test)

file(GLOB_RECURSE OUSA_PRODUCTION_SOURCES CONFIGURE_DEPENDS
  ${_OUSA_SRC_DIR}/*.c
)

set(OUSA_SOURCES ${OUSA_PRODUCTION_SOURCES})

if(UNIT_TEST)
  file(GLOB_RECURSE OUSA_TEST_SOURCES CONFIGURE_DEPENDS
    ${_OUSA_TEST_DIR}/src/*.c
    ${_OUSA_TEST_DIR}/ife/*.c
    ${_OUSA_TEST_DIR}/api/*.c
  )
  list(APPEND OUSA_SOURCES ${OUSA_TEST_SOURCES})
endif()

add_executable(ousia ${OUSA_SOURCES})

set_target_properties(ousia PROPERTIES
  OUTPUT_NAME ousia
  RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/output/bin
)

# Register every directory that contains a header so #include "..." always resolves.
function(ousia_collect_header_dirs out_var)
  set(_dirs "")
  set(_roots ${_OUSA_INC_DIR} ${_OUSA_SRC_DIR})
  if(UNIT_TEST)
    list(APPEND _roots
      ${_OUSA_TEST_DIR}/inc
      ${_OUSA_TEST_DIR}/api
      ${_OUSA_TEST_DIR}/ife
      ${_OUSA_TEST_DIR}/src
    )
  endif()
  foreach(_root IN LISTS _roots)
    if(IS_DIRECTORY "${_root}")
      list(APPEND _dirs "${_root}")
      file(GLOB_RECURSE _headers CONFIGURE_DEPENDS "${_root}/*.h")
      foreach(_h IN LISTS _headers)
        get_filename_component(_d "${_h}" DIRECTORY)
        list(APPEND _dirs "${_d}")
      endforeach()
    endif()
  endforeach()
  if(_dirs)
    list(REMOVE_DUPLICATES _dirs)
  endif()
  set(${out_var} "${_dirs}" PARENT_SCOPE)
endfunction()

ousia_collect_header_dirs(OUSA_HEADER_INCLUDE_DIRS)
target_include_directories(ousia PRIVATE ${OUSA_HEADER_INCLUDE_DIRS})

if(UNIT_TEST)
  target_compile_definitions(ousia PRIVATE UNIT_TEST=1)
endif()
