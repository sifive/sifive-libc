# libcrvv: RVV optimized baremetal C library


## Building the library

Before building the library, please make sure you have a RISC-V baremetal toolchain
installed somewhere.  
We use cmake to build the library:
```
$ mkdir build/ && cd build/
$ cmake \
	-DCMAKE_TOOLCHAIN_FILE=../cmake/toolchains/SiFive-Metal-Toolsuite.cmake \
	-DRISCV_TOOLCHAIN=/path/to/riscv/toolchain \
	../
$ cmake --build .
[  6%] Building ASM object src/CMakeFiles/crvv.dir/memchr_vext.S.obj
[ 13%] Building ASM object src/CMakeFiles/crvv.dir/memcmp_vext.S.obj
...
[100%] Linking ASM static library libcrvv.a
[100%] Built target crvv
```

This would generate a static library: `src/libcrvv`.


## Using the library

The generated `libcrvv` might be put into the toolchain's <SYSROOT>/lib/ directory.  
(<SYSROOT> can be found with gcc command: `riscv64-unknown-elf-gcc -print-sysroot`.)  

When linking executables, add link flag: `-lcrvv`:

```
$ riscv64-unknown-elf-gcc test.c -lcrvv
```

> **Warning**  
> Link order matters. `-lcrvv` should be added at the end of the source list so that linker can use the optimized functions.  



### Example

Assume we have a test.c that uses `strlen`:

```
$ cat test.c
#include <string.h>
#include <stdio.h>

int main(void)
{
	const char str[] = "How many characters does this string contain?";
	printf("without null character: %zu\n", strlen(str));
	return 0;
}
```

Compile it with `libcrvv.a`:

```
$ riscv64-unknown-elf-gcc test.c -lcrvv -fno-builtin
```


> **Note**  
> We put `-fno-builtin` here becaue GCC use its builtin implementation and inline it directly.  
> 
> You can also disable specific builtin functions by using `-fno-builtin-xxxx`.
> In our example, you can use `-fno-builtin-strlen` to disable builtin `strlen` only.

Use `objdump` to check the optimized rvv version `strlen` is used:

```
$  riscv64-unknown-elf-objdump -d test |  awk -v RS= '/^[[:xdigit:]]+ <strlen>/'
0000000000010224 <strlen>:
   10224:       00050593                mv      a1,a0
   10228:       00107657                vsetvli a2,zero,e8,m2,tu,mu
   1022c:       03058007                vle8ff.v        v0,(a1)
   10230:       c2002673                csrr    a2,vl
   10234:       62003157                vmseq.vi        v2,v0,0
   10238:       4228a6d7                vfirst.m        a3,v2
   1023c:       00c585b3                add     a1,a1,a2
   10240:       fe06c4e3                bltz    a3,10228 <strlen+0x4>
   10244:       00c50533                add     a0,a0,a2
   10248:       00d585b3                add     a1,a1,a3
   1024c:       40a58533                sub     a0,a1,a0
   10250:       00008067                ret
```
