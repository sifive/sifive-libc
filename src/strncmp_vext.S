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
// int strncmp(const char *lhs, const char *rhs, size_t count)

#include <sys/asm.h>

#define iResult a0

#define pStr1 a0
#define pStr2 a1
#define iLength a2

#define iVL a3
#define iTemp1 a4
#define iTemp2 a5

#define ELEM_LMUL_SETTING m1
#define vStr1 v0
#define vStr2 v4
#define vMask1 v8
#define vMask2 v9

ENTRY(strncmp)

    beqz iLength, L(zero_length)

L(loop):
    vsetvli zero, iLength, e8, ELEM_LMUL_SETTING, ta, ma

    vle8ff.v vStr1, (pStr1)
    // vStr1[i] == 0
    vmseq.vx vMask1, vStr1, zero

    vle8ff.v vStr2, (pStr2)
    // vStr1[i] != vStr2[i]
    vmsne.vv vMask2, vStr1, vStr2

    csrr iVL, vl

    // r = mask1 | mask2
    // We could use vfirst.m to get the first zero char or the
    // first different char between str1 and str2.
    vmor.mm vMask1, vMask1, vMask2

    sub iLength, iLength, iVL

    vfirst.m iTemp1, vMask1

    bgez iTemp1, L(end_loop)

    add pStr1, pStr1, iVL
    add pStr2, pStr2, iVL
    bnez iLength, L(loop)
L(end_loop):

    add pStr1, pStr1, iTemp1
    add pStr2, pStr2, iTemp1
    lbu iTemp1, 0(pStr1)
    lbu iTemp2, 0(pStr2)

    sub iResult, iTemp1, iTemp2
    ret

L(zero_length):
    li iResult, 0
    ret

END(strncmp)
