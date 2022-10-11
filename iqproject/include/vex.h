#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#if VEX_TOOLCHAIN_VERSION == 1
// Use V1 toolchain
#include "iq_cpp.h"
#elif VEX_TOOLCHAIN_VERSION == 2
// Use V2 toolchain
#include "iq2_cpp.h"
#else
// ERROR
#error INVALID_TOOLCHAIN_VERSION: VEX_TOOLCHAIN_VERSION must be 1 or 2.
#endif