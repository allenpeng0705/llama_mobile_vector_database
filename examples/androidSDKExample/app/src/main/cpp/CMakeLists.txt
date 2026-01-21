cmake_minimum_required(VERSION 3.18.1)

project("androidsdkexample")

add_library(
        native-lib
        SHARED
        native-lib.cpp
)

# Set linker flags for 16KB alignment
set_target_properties(native-lib PROPERTIES
    LINK_FLAGS "-Wl,-z,max-page-size=0x4000"
)

find_library(
        log-lib
        log
)

target_link_libraries(
        native-lib
        ${log-lib}
)
