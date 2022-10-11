cmake_minimum_required(VERSION 3.0)

# FIX (https://stackoverflow.com/questions/54482519/avoid-cmake-to-add-the-flags-search-paths-first-and-headerpad-max-install-name)
set(HAVE_FLAG_SEARCH_PATHS_FIRST 0)

project(iqProject)

# compiler flags
#CFLAGS_CL = -target thumbv7-none-eabi -fshort-enums -Wno-unknown-attributes -U__INT32_TYPE__ -U__UINT32_TYPE__ -D__INT32_TYPE__=long -D__UINT32_TYPE__='unsigned long' 
#CFLAGS_V7 = -mthumb -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard
#CFLAGS    = ${CFLAGS_CL} ${CFLAGS_V7} -Os -Wall -Werror=return-type -ansi -std=gnu99 $(DEFINES)
#CXX_FLAGS = ${CFLAGS_CL} ${CFLAGS_V7} -Os -Wall -Werror=return-type -fno-rtti -fno-threadsafe-statics -fno-exceptions  -std=gnu++11 -ffunction-sections -fdata-sections $(DEFINES)

# compiler flags
#CFLAGS_CL = -target thumbv7-none-eabi -fshort-enums -Wno-unknown-attributes -U__INT32_TYPE__ -U__UINT32_TYPE__ -D__INT32_TYPE__=long -D__UINT32_TYPE__='unsigned long' 
#CFLAGS_V7 = -mthumb -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard
#CFLAGS    = ${CFLAGS_CL} ${CFLAGS_V7} -Os -Wall -Werror=return-type -ansi -std=gnu99 $(DEFINES)
#CXX_FLAGS = ${CFLAGS_CL} ${CFLAGS_V7} -Os -Wall -Werror=return-type -fno-rtti -fno-threadsafe-statics -fno-exceptions  -std=gnu++11 -ffunction-sections -fdata-sections $(DEFINES)

# Set toolchain version if not exist
if(NOT DEFINED VEX_TOOLCHAIN_VERSION)
	message(WARNING "VEX_TOOLCHAIN_VERSION should be set to 1 or 2. using 2 as default.")
	set(VEX_TOOLCHAIN_VERSION 2)
endif()

# If windows, add exe 🙄
if(WIN32)
    set(TOOLCHAIN_EXT ".exe")
else()
    set(TOOLCHAIN_EXT "")
endif(WIN32)

# Depending on OS use diffrent arm folder
if(CMAKE_HOST_SYSTEM_NAME STREQUAL Linux)
	set(TOOLCHAIN_PREFIX "/usr")
elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL Darwin)
	set(TOOLCHAIN_PREFIX "/Applications/ARM")
elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL Windows)
	message(STATUS "Please specify the TOOLCHAIN_PREFIX !\n For example: -DTOOLCHAIN_PREFIX=\"C:/Program Files/GNU Tools ARM Embedded\" ")
else()
	set(TOOLCHAIN_PREFIX "/usr")
	message(STATUS "No TOOLCHAIN_PREFIX specified, using default: " ${TOOLCHAIN_PREFIX})
endif()
set(TOOLCHAIN arm-none-eabi)
set(TOOLCHAIN_BIN_DIR ${TOOLCHAIN_PREFIX}/bin)
set(TOOLCHAIN_INC_DIR ${TOOLCHAIN_PREFIX}/${TOOLCHAIN}/include)
set(TOOLCHAIN_LIB_DIR ${TOOLCHAIN_PREFIX}/${TOOLCHAIN}/lib)
file(GLOB TOOLCHAIN_LIB_FILES ${TOOLCHAIN_LIB_DIR}/*)

# Definitions
set(VEX_SDK_PATH ${CMAKE_SOURCE_DIR}/iqSDK/V${VEX_TOOLCHAIN_VERSION})
set(VEX_SOURCE_DIR ${CMAKE_SOURCE_DIR}/src)

# Link this lib
# target_include_directories(iqProject PRIVATE ${CMAKE_SOURCE_DIR}/include)
# target_include_directories(iqProject PRIVATE ${VEX_SDK_PATH}/include)
# target_include_directories(iqProject PRIVATE ${TOOLCHAIN_LIB_DIR})
# target_include_directories(iqProject PRIVATE ${TOOLCHAIN_INC_DIR})
# target_include_directories(iqProject PRIVATE "${VEX_SDK_PATH}/libvex.a")

add_executable(iqProject ${VEX_SOURCE_DIR}/main.cpp)
target_include_directories(iqProject PRIVATE ${CMAKE_SOURCE_DIR}/include)
target_include_directories(iqProject PRIVATE ${VEX_SDK_PATH}/include)
target_include_directories(iqProject PRIVATE ${TOOLCHAIN_LIB_DIR})
target_include_directories(iqProject PRIVATE ${TOOLCHAIN_INC_DIR})
target_include_directories(iqProject PRIVATE "${VEX_SDK_PATH}/libvex.a")
# add_library(iqProject STATIC ${VEX_SDK_PATH}/libvex.a)
# target_link_libraries(iqProject LINK_PUBLIC ${VEX_SDK_PATH}/libvex.a)

# Get packages
find_program(GNU_CC_PATH arm-none-eabi-gpp${TOOLCHAIN_EXT})
find_program(GNU_CXX_PATH arm-none-eabi-g++${TOOLCHAIN_EXT})
find_program(GNU_OBJCOPY_PATH arm-none-eabi-objcopy${TOOLCHAIN_EXT})
find_program(GNU_OBJDUMP_PATH arm-none-eabi-objdump${TOOLCHAIN_EXT})
find_program(GNU_SIZE_PATH arm-none-eabi-size${TOOLCHAIN_EXT})

# Config
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_ASM_COMPILER ${GNU_CXX_PATH})
set(CMAKE_C_COMPILER ${GNU_CC_PATH})
set(CMAKE_CXX_COMPILER ${GNU_CXX_PATH})
set(CMAKE_OBJCOPY ${GNU_OBJCOPY_PATH})
set(CMAKE_OBJDUMP ${GNU_OBJDUMP_PATH})
SET(ELF2BIN ${GNU_OBJCOPY_PATH})
set(CMAKE_SIZE ${GNU_SIZE_PATH})
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)
set(CPU_ARGS "-mthumb -march=armv7e-m -mcpu=cortex-m4")
set(VFP_ARGS "-mfloat-abi=hard -mfpu=fpv4-sp-d16")
# CREDIT https://github.com/azure-rtos/getting-started/blob/master/cmake/arm-gcc-cortex-toolchain.cmake
set(VEX_GENERIC_ARGS "-Os -g3 -fno-builtin -fno-common -Wall -Wshadow -Wdouble-promotion -Wno-unused-parameter -mfloat-abi=hard -Wno-unknown-attributes -U__INT32_TYPE__ -U__UINT32_TYPE__ -D__INT32_TYPE__=long -D__UINT32_TYPE__='unsigned long'")
set(CMAKE_C_FLAGS "${CPU_ARGS} ${VFP_ARGS} ${VEX_GENERIC_ARGS} -std=gnu99")
set(CMAKE_CXX_FLAGS "${CPU_ARGS} ${VFP_ARGS} ${VEX_GENERIC_ARGS} -std=gnu++11  -ffunction-sections -fno-strict-aliasing")
set(CMAKE_ASM_FLAGS "${CPU_ARGS} ${VFP_ARGS} ${VEX_GENERIC_ARGS}")
set(CMAKE_EXE_LINKER_FLAGS "${CPU_ARGS} ${VFP_ARGS} -nostdlib --specs=nano.specs -T${VEX_SDK_PATH}/link.ld")
# Cmake linker custom


add_definitions(-DVEX_TOOLCHAIN_VERSION=${VEX_TOOLCHAIN_VERSION})
# Create bin file
add_custom_target(iqProject.bin ALL 
	COMMAND ${CMAKE_OBJCOPY} -O binary iqProject.elf iqProject.bin
)