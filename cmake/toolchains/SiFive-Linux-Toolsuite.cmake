# Build for Linux system
set(CMAKE_SYSTEM_NAME Linux)

# Users have to provide RISCV_TOOLCHAIN so that we know where to find the
# cross compiler.
SET(RISCV_TOOLCHAIN "" CACHE STRING "Set RISC-V toolchain path")
if(NOT DEFINED CACHE{RISCV_TOOLCHAIN})
    message(FATAL_ERROR "Please set -DRISCV_TOOLCHAIN=<PATH_TO_RISCV_TOOLCHAIN>.")
endif()

# Set compiler
set(RISCV_PREFIX riscv64-unknown-linux-gnu)
set(CMAKE_C_COMPILER "${RISCV_TOOLCHAIN}/bin/${RISCV_PREFIX}-gcc")
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

set(CMAKE_C_FLAGS_INIT "-march=rv64gcv")
set(CMAKE_ASM_FLAGS "-march=rv64gcv")
