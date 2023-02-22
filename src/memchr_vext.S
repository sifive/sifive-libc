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
// void *memchr(const void *ptr, int ch, size_t count)

#include <sys/asm.h>

#define iResult a0

#define pSrc a0
#define iValue a1
#define iNum a2

#define iVL a3
#define iTemp a4

#define ELEM_LMUL_SETTING m8
#define vData v0
#define vMask v8

ENTRY(memchr)

L(loop):
    vsetvli zero, iNum, e8, ELEM_LMUL_SETTING, ta, ma

    vle8ff.v vData, (pSrc)
    // Find the iValue inside the loaded data.
    vmseq.vx vMask, vData, iValue
    vfirst.m iTemp, vMask

    // Skip the loop if we find the matched value.
    bgez iTemp, L(found)

    csrr iVL, vl
    sub iNum, iNum, iVL
    add pSrc, pSrc, iVL

    bnez iNum, L(loop)

    li iResult, 0
    ret

L(found):
    add iResult, pSrc, iTemp
    ret

END(memchr)
