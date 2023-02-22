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
// char *strcpy(char *dest, const char *src)

#include <sys/asm.h>

#define pDst a0
#define pSrc a1
#define pDstPtr a2

#define iVL a3
#define iCurrentVL a4
#define iActiveElemPos a5

#define ELEM_LMUL_SETTING m1
#define vMask1 v0
#define vMask2 v1
#define vStr1 v8
#define vStr2 v16

ENTRY(strcpy)

    mv pDstPtr, pDst

L(strcpy_loop):
    vsetvli iVL, zero, e8, ELEM_LMUL_SETTING, ta, ma
    vle8ff.v vStr1, (pSrc)
    vmseq.vx vMask2, vStr1, zero
    csrr iCurrentVL, vl
    vfirst.m iActiveElemPos, vMask2
    vmsif.m vMask1, vMask2
    add pSrc, pSrc, iCurrentVL
    vse8.v vStr1, (pDstPtr), vMask1.t
    add pDstPtr, pDstPtr, iCurrentVL
    bltz iActiveElemPos, L(strcpy_loop)

    ret

END(strcpy)
