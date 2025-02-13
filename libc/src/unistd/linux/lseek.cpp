//===-- Linux implementation of lseek -------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "src/unistd/lseek.h"
#include "src/errno/libc_errno.h"

#include "src/__support/OSUtil/syscall.h" // For internal syscall function.
#include "src/__support/common.h"

#include <stdint.h>
#include <sys/syscall.h> // For syscall numbers.
#include <unistd.h>

namespace __llvm_libc {

LLVM_LIBC_FUNCTION(off_t, lseek, (int fd, off_t offset, int whence)) {
  off_t result;
#ifdef SYS_lseek
  long ret = __llvm_libc::syscall_impl(SYS_lseek, fd, offset, whence);
  result = ret;
#elif defined(SYS_llseek)
  long ret = __llvm_libc::syscall_impl(SYS_llseek, fd,
                                       (long)(((uint64_t)(offset)) >> 32),
                                       (long)offset, &result, whence);
  result = ret;
#elif defined(SYS__llseek)
  long ret = __llvm_libc::syscall_impl(SYS__llseek, fd, offset >> 32, offset,
                                       &result, whence);
#else
#error "lseek, llseek and _llseek syscalls not available."
#endif

  if (ret < 0) {
    libc_errno = -ret;
    return -1;
  }
  return result;
}

} // namespace __llvm_libc
