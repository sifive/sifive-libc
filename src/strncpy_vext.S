// Copyright (c) 2023 SiFive, Inc. -- Proprietary and Confidential All Rights
// Reserved.
//
// NOTICE: All information contained herein is, and remains the property of
// SiFive, Inc. The intellectual and technical concepts contained herein are
// proprietary to SiFive, Inc. and may be covered by U.S. and Foreign Patents,
// patents in process, and are protected by trade secret or copyright law.
//
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from SiFive, Inc.
//
// The copyright notice above does not evidence any actual or intended
// publication or disclosure of this source code, which includes information
// that is confidential and/or proprietary, and is a trade secret, of SiFive,
// Inc.
//===----------------------------------------------------------------------===//

// Contributed by: Jerry Shih <jerry.shih@sifive.com>

// Prototype:
// char *strncpy(char *dest, const char *src, size_t count)

#include <sys/asm.h>

#define pDst a0
#define pSrc a1
#define iLength a2
#define pDstPtr a3

#define iVL a4
#define iCurrentVL a5
#define iActiveElemPos a6
#define iTemp a7

#define ELEM_LMUL_SETTING m1
#define vMask1 v0
#define vMask2 v1
#define ZERO_FILL_ELEM_LMUL_SETTING m8
#define vStr1 v8
#define vStr2 v16

ENTRY(strncpy)

    mv pDstPtr, pDst

    // Copy pSrc to pDstPtr.
L(strcpy_loop):
    vsetvli zero, iLength, e8, ELEM_LMUL_SETTING, ta, ma
    vle8ff.v vStr1, (pSrc)
    vmseq.vx vMask2, vStr1, zero
    csrr iCurrentVL, vl
    vfirst.m iActiveElemPos, vMask2
    vmsif.m vMask1, vMask2
    add pSrc, pSrc, iCurrentVL
    sub iLength, iLength, iCurrentVL
    vse8.v vStr1, (pDstPtr), vMask1.t
    add pDstPtr, pDstPtr, iCurrentVL
    bgez iActiveElemPos, L(fill_zero)
    bnez iLength, L(strcpy_loop)
    ret

    // Fill the tail zero.
L(fill_zero):
    // We already copy the `\0` to dst. But we use `vfirst.m` to
    // get the `index` of `\0` position. We need to adjust `-1`
    // to get the correct remaining iLength for zero filling.
    sub iTemp, iCurrentVL, iActiveElemPos
    addi iTemp, iTemp, -1
    add iLength, iLength, iTemp
    // Have an earily return for `strlen(src) + 1 == count` case.
    bnez iLength, 1f
    ret
1:
    sub pDstPtr, pDstPtr, iTemp
    vsetvli zero, iLength, e8, ZERO_FILL_ELEM_LMUL_SETTING, ta, ma
    vmv.v.x vStr2, zero

L(fill_zero_loop):
    vsetvli iVL, iLength, e8, ZERO_FILL_ELEM_LMUL_SETTING, ta, ma
    vse8.v vStr2, (pDstPtr)
    sub iLength, iLength, iVL
    add pDstPtr, pDstPtr, iVL
    bnez iLength, L(fill_zero_loop)

    ret

END(strncpy)
