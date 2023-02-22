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

// Contributed by: Nick Knight <nick.knight@sifive.com>

// Prototype:
// size_t strnlen(const char *s, size_t maxlen)

#include <sys/asm.h>

#define pStr a0
#define pCopyStr a2
#define iRetValue a0
#define iMaxlen a1
#define iCurrentVL a3
#define iEndOffset a4

#define ELEM_LMUL_SETTING m1
#define vStr v0
#define vMaskEnd v8

ENTRY(strnlen)

    mv pCopyStr, pStr
    mv iRetValue, iMaxlen
L(strnlen_loop):
    beqz iMaxlen, L(end_strnlen_loop)
    vsetvli zero, iMaxlen, e8, ELEM_LMUL_SETTING, ta, ma
    vle8ff.v vStr, (pCopyStr)
    vmseq.vi vMaskEnd, vStr, 0
    vfirst.m iEndOffset, vMaskEnd /* first occurence of \0 */
    csrr iCurrentVL, vl
    add pCopyStr, pCopyStr, iCurrentVL
    sub iMaxlen, iMaxlen, iCurrentVL
    bltz iEndOffset, L(strnlen_loop)
    add iMaxlen, iMaxlen, iCurrentVL
    sub iRetValue, iRetValue, iMaxlen
    add iRetValue, iRetValue, iEndOffset
L(end_strnlen_loop):
    ret

END(strnlen)
