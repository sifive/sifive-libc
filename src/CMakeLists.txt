# Copyright (c) 2023 SiFive, Inc. -- Proprietary and Confidential All Rights Reserved.
#
# NOTICE: All information contained herein is, and remains the property of
# SiFive, Inc. The intellectual and technical concepts contained herein are
# proprietary to SiFive, Inc. and may be covered by U.S. and Foreign Patents,
# patents in process, and are protected by trade secret or copyright law.
#
# This work may not be copied, modified, re-published, uploaded, executed, or
# distributed in any way, in any medium, whether in whole or in part, without
# prior written permission from SiFive, Inc.
#
# The copyright notice above does not evidence any actual or intended publication
# or disclosure of this source code, which includes information that is
# confidential and/or proprietary, and is a trade secret, of SiFive, Inc.


add_library(crvv
    memchr_vext.S
    memcmp_vext.S
    memcpy_vext.S
    memmove_vext.S
    memset_vext.S
    strcat_vext.S
    strchr_vext.S
    strcmp_vext.S
    strcpy_vext.S
    strlen_vext.S
    strncat_vext.S
    strncmp_vext.S
    strncpy_vext.S
    strnlen_vext.S
    )

include_directories(${CMAKE_CURRENT_LIST_DIR})
install(TARGETS crvv
        LIBRARY DESTINATION lib
)
