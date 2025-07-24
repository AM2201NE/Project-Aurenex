cmake_minimum_required(VERSION 3.10)
project(llama_wrapper)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)

# Set absolute path to llama.cpp
get_filename_component(LLAMA_CPP_PATH "../llama.cpp" ABSOLUTE)
set(LLAMA_LIB_PATH "${LLAMA_CPP_PATH}/build/src/Release/llama.lib")
set(GGML_LIB_PATH "${LLAMA_CPP_PATH}/build/ggml/src/Release/ggml.lib")
set(GGML_BASE_LIB_PATH "${LLAMA_CPP_PATH}/build/ggml/src/Release/ggml-base.lib")
set(GGML_CPU_LIB_PATH "${LLAMA_CPP_PATH}/build/ggml/src/Release/ggml-cpu.lib")
set(COMMON_LIB_PATH "${LLAMA_CPP_PATH}/build/common/Release/common.lib")

add_library(llama_wrapper SHARED llama_wrapper.cpp)
# Add llama.cpp root, include, and ggml/include for all headers
# This ensures llama.h and ggml.h are found
# (llama.cpp/include and llama.cpp/ggml/include are both needed)
target_include_directories(llama_wrapper PRIVATE 
    ${LLAMA_CPP_PATH} 
    ${LLAMA_CPP_PATH}/include 
    ${LLAMA_CPP_PATH}/ggml/include 
    ${LLAMA_CPP_PATH}/ggml 
    ${LLAMA_CPP_PATH}/common 
    ${LLAMA_CPP_PATH}/vendor 
    ${LLAMA_CPP_PATH}/src 
)
target_link_libraries(llama_wrapper PRIVATE 
    ${LLAMA_LIB_PATH}
    ${GGML_LIB_PATH}
    ${GGML_BASE_LIB_PATH}
    ${GGML_CPU_LIB_PATH}
    ${COMMON_LIB_PATH}
)

# Set output directory for DLL and import library
set_target_properties(llama_wrapper PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin/Release
    ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin/Release
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin/Release
)

# Optionally, copy the DLL to bin/Release after build (for convenience)
add_custom_command(TARGET llama_wrapper POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        $<TARGET_FILE:llama_wrapper>
        ${CMAKE_BINARY_DIR}/bin/Release)
