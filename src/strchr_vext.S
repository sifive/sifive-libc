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

// Contributed by: Nick Knight <nick.knight@sifive.com> and
//                 Hau Hsu <hau.hsu@sifive.com>

// Prototype:
// char *strchr(const char *str, int ch)

#include <sys/asm.h>

#define pStr a0
#define iCh a1
#define iEndOffset a2
#define iChOffset a3
#define iTemp1 a4
#define iTemp2 a5
#define iCurrentVL a6
#define iVL t0

#define ELEM_LMUL_SETTING m1
#define vStr v0
#define vMaskEnd v8
#define vMaskCh v9

ENTRY(strchr)

L(strchr_loop):
    vsetvli iVL, zero, e8, ELEM_LMUL_SETTING, ta, ma
    vle8ff.v vStr, (pStr)
    vmseq.vi vMaskEnd, vStr, 0
    vmseq.vx vMaskCh, vStr, iCh
    vfirst.m iEndOffset, vMaskEnd /* first occurrence of \0 */
    vfirst.m iChOffset, vMaskCh /* first occurrence of ch */
    sltz iTemp1, iChOffset
    sltu iTemp2, iEndOffset, iChOffset
    or iTemp1, iTemp1, iTemp2
    beqz iTemp1, L(found_ch) /* Found ch, not preceded by \0? */
    csrr iCurrentVL, vl
    add pStr, pStr, iCurrentVL
    bltz iEndOffset, L(strchr_loop) /* Didn't find \0? */
    li pStr, 0
    ret
L(found_ch):
    add pStr, pStr, iChOffset
    ret

END(strchr)
