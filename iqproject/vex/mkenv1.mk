# VEXcode mkenv.mk 2019_03_26_01

# macros to help with windows paths that include spaces
sp :=
sp +=
qs = $(subst ?,$(sp),$1)
sq = $(subst $(sp),?,$1)

# default platform and build location
PLATFORM  = vexiq
BUILD     = build

# Project name passed from app
ifeq ("$(origin P)", "command line")
PROJECT   = $(P)
else
PROJECT   = $(notdir $(call sq,$(abspath ${CURDIR})))
endif

# Toolchain path passed from app
ifeq ("$(origin T)", "command line")
TOOLCHAIN = $(T)
endif
ifndef TOOLCHAIN
TOOLCHAIN = ${HOME}/sdk
endif

# Verbose flag passed from app
ifeq ("$(origin V)", "command line")
BUILD_VERBOSE=$(V)
endif

# allow verbose to be set by makefile if not set by app
ifndef BUILD_VERBOSE
ifndef VERBOSE
BUILD_VERBOSE = 0
else
BUILD_VERBOSE = $(VERBOSE)
endif
endif

# use verbose flag
ifeq ($(BUILD_VERBOSE),0)
Q = @
else
Q =
endif

# IQ specific arguments, slot and radio use
ifeq ("$(origin S)", "command line")
ifeq ($(S),1)
IQ_SLOT=0x1301
IQ_ADDR=0x20000
endif
ifeq ($(S),2)
IQ_SLOT=0x1302
IQ_ADDR=0x28000
endif
ifeq ($(S),3)
IQ_SLOT=0x1303
IQ_ADDR=0x30000
endif
ifeq ($(S),4)
IQ_SLOT=0x1304
IQ_ADDR=0x38000
endif
endif

# default slot 1
ifndef IQ_SLOT
IQ_SLOT=0x1301
IQ_ADDR=0x20000
endif

# radio enabled, no slot selection yet
ifeq ("$(origin R)", "command line")
ifeq ($(R),0)
IQ_RADIO=0001
else
IQ_RADIO=0101
endif
endif

# default to no radio
ifndef IQ_RADIO
IQ_RADIO=0001
endif

# and concat them
IQ_CONFIG=$(IQ_SLOT)$(IQ_RADIO)

# compile and link tools
CC      = clang
CXX     = clang
OBJCOPY = arm-none-eabi-objcopy
SIZE    = arm-none-eabi-size
LINK    = arm-none-eabi-ld
ARCH    = arm-none-eabi-ar
ECHO    = @echo
DEFINES = -DVexIQ -DIQNAME="${PROJECT}"

# platform specific macros
ifeq ($(OS),Windows_NT)
$(info windows build for platform $(PLATFORM))
SHELL = cmd.exe
MKDIR = md "$(@D)" 2> nul || :
RMDIR = rmdir /S /Q
CLEAN = $(RMDIR) $(BUILD) 2> nul || :
else
$(info unix build for platform $(PLATFORM))
MKDIR = mkdir -p "$(@D)" 2> /dev/null || :
RMDIR = rm -rf
CLEAN = $(RMDIR) $(BUILD) 2> /dev/null || :
endif

# toolchain include and lib locations
TOOL_INC  = -I"$(TOOLCHAIN)/$(PLATFORM)/clang/7.0.0/include" -I"$(TOOLCHAIN)/$(PLATFORM)/gcc/include"  -I"$(TOOLCHAIN)/$(PLATFORM)/gcc/include/c++/4.9.3"  -I"$(TOOLCHAIN)/$(PLATFORM)/gcc/include/c++/4.9.3/arm-none-eabi/armv7e-m"
TOOL_LIB  = -L"$(TOOLCHAIN)/$(PLATFORM)/gcc/libs"

# compiler flags
CFLAGS_CL = -target thumbv7-none-eabi -fshort-enums -Wno-unknown-attributes -U__INT32_TYPE__ -U__UINT32_TYPE__ -D__INT32_TYPE__=long -D__UINT32_TYPE__='unsigned long' 
CFLAGS_V7 = -mthumb -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard
CFLAGS    = ${CFLAGS_CL} ${CFLAGS_V7} -Os -Wall -Werror=return-type -ansi -std=gnu99 $(DEFINES)
CXX_FLAGS = ${CFLAGS_CL} ${CFLAGS_V7} -Os -Wall -Werror=return-type -fno-rtti -fno-threadsafe-statics -fno-exceptions  -std=gnu++11 -ffunction-sections -fdata-sections $(DEFINES)

# linker flags
LNK_FLAGS = -nostdlib  --defsym _iqProgramConfig=${IQ_CONFIG} --defsym _iqProgramAddress=${IQ_ADDR} -T "$(TOOLCHAIN)/$(PLATFORM)/lscript.ld" -Map="$(BUILD)/$(PROJECT).map" --gc-section -L"$(TOOLCHAIN)/$(PLATFORM)" ${TOOL_LIB}

# future statuc library
PROJECTLIB = lib$(PROJECT)
ARCH_FLAGS = rcs

# libraries
LIBS =  --start-group -lviqrt -lc_nano -lm -lgcc --end-group

# include file paths
INC += $(addprefix -I, ${INC_F})
INC += -I"$(TOOLCHAIN)/$(PLATFORM)/include"
INC += -I"$(TOOLCHAIN)/$(PLATFORM)/include/vex_include"
INC += ${TOOL_INC}
