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
// void* memmove(void* dest, const void* src, size_t count)

#include <sys/asm.h>

#define pDst a0
#define pSrc a1
#define iNum a2

#define iVL a3
#define pDstPtr a4
#define pSrcBackwardPtr a5
#define pDstBackwardPtr a6

#define ELEM_LMUL_SETTING m8
#define vData v0

ENTRY(memmove)

    mv pDstPtr, pDst

    // If pSrc is equal or after pDst, all data in pSrc will be loaded before
    // overwrited for the overlapping case. We could use faster `forward-copy`.
    bgeu pSrc, pDst, L(forward_copy_loop)
    add pSrcBackwardPtr, pSrc, iNum
    add pDstBackwardPtr, pDst, iNum
    // If pDst inside source data range, we need to use `backward_copy_loop` to
    // handle the overlapping issue.
    bltu pDst, pSrcBackwardPtr, L(backward_copy_loop)

L(forward_copy_loop):
    vsetvli iVL, iNum, e8, ELEM_LMUL_SETTING, ta, ma

    vle8.v vData, (pSrc)
    sub iNum, iNum, iVL
    add pSrc, pSrc, iVL
    vse8.v vData, (pDstPtr)
    add pDstPtr, pDstPtr, iVL

    bnez iNum, L(forward_copy_loop)
    ret

L(backward_copy_loop):
    vsetvli iVL, iNum, e8, ELEM_LMUL_SETTING, ta, ma

    sub pSrcBackwardPtr, pSrcBackwardPtr, iVL
    vle8.v vData, (pSrcBackwardPtr)
    sub iNum, iNum, iVL
    sub pDstBackwardPtr, pDstBackwardPtr, iVL
    vse8.v vData, (pDstBackwardPtr)
    bnez iNum, L(backward_copy_loop)
    ret

END(memmove)
