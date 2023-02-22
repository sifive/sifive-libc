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
// size_t strlen(const char *str)

#include <sys/asm.h>

#define iResult a0
#define pStr a0
#define pCopyStr a1
#define iVL a2
#define iCurrentVL a2
#define iEndOffset a3

#define ELEM_LMUL_SETTING m2
#define vStr v0
#define vMaskEnd v2

ENTRY(strlen)

    mv pCopyStr, pStr
L(loop):
    vsetvli iVL, zero, e8, ELEM_LMUL_SETTING, ta, ma
    vle8ff.v vStr, (pCopyStr)
    csrr iCurrentVL, vl
    vmseq.vi vMaskEnd, vStr, 0
    vfirst.m iEndOffset, vMaskEnd
    add pCopyStr, pCopyStr, iCurrentVL
    bltz iEndOffset, L(loop)

    add pStr, pStr, iCurrentVL
    add pCopyStr, pCopyStr, iEndOffset
    sub iResult, pCopyStr, iResult

    ret

END(strlen)

