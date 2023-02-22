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
// int memcmp(const void* lhs, const void* rhs, size_t count)

#include <sys/asm.h>

#define iResult a0

#define pSrc1 a0
#define pSrc2 a1
#define iNum a2

#define iVL a3
#define iTemp a4
#define iTemp1 a5
#define iTemp2 a6

#define ELEM_LMUL_SETTING m8
#define vData1 v0
#define vData2 v8
#define vMask v16

ENTRY(memcmp)

L(loop):
    vsetvli iVL, iNum, e8, ELEM_LMUL_SETTING, ta, ma

    vle8.v vData1, (pSrc1)
    vle8.v vData2, (pSrc2)

    vmsne.vv vMask, vData1, vData2
    sub iNum, iNum, iVL
    vfirst.m iTemp, vMask

    // Skip the loop if we find the different value between pSrc1 and pSrc2.
    bgez iTemp, L(found)

    add pSrc1, pSrc1, iVL
    add pSrc2, pSrc2, iVL

    bnez iNum, L(loop)

    li iResult, 0
    ret

L(found):
    add pSrc1, pSrc1, iTemp
    add pSrc2, pSrc2, iTemp
    lbu iTemp1, 0(pSrc1)
    lbu iTemp2, 0(pSrc2)
    sub iResult, iTemp1, iTemp2
    ret

END(memcmp)
