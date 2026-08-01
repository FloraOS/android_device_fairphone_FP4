#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2026 FairPhone B.V.
"""Drop the libc-owned uapi headers from the kernel's headers_install output.

Several vendor HALs (display, media, ...) put $(KERNEL_OBJ)/usr/include on the
include path with -I so they can reach the Qualcomm specific uapi headers
(media/msm_media_info.h, display/..., vidc/..., linux/msm_*.h, ...).  Because
-I is searched before the -isystem entries that bring in bionic, that directory
also shadows every plain Linux uapi header with the raw, un-scrubbed kernel
copy.

bionic ships its own scrubbed copies under libc/kernel/uapi and its *public*
headers rely on them: bionic/libc/include/sched.h pulls in <linux/sched/types.h>
and defines struct sched_param itself, because the scrubbed copy deliberately
leaves it out.  Pick up the raw kernel header instead and the struct is defined
twice, which is exactly the "redefinition of 'sched_param'" /
"redefinition of 'sigaction'" breakage seen on Android 16.

The headers that can bite are precisely the ones reachable from bionic's public
headers, so compute that set and remove those files from the kernel's
headers_install output.  Everything the libc does not care about - including
uapi headers that Qualcomm has extended, such as linux/videodev2.h - is left
untouched and still resolves to the kernel copy.

Usage: prune_kernel_uapi_headers.py <kernel-headers-install-include-dir>
Run from the top of the Android tree.
"""

import os
import re
import sys

# bionic's public headers, i.e. the ones that end up on every -isystem line.
BIONIC_PUBLIC = "bionic/libc/include"

# Where bionic keeps its scrubbed uapi copies.  asm/ lives under a per-arch
# root (asm-arm64/asm/foo.h is what <asm/foo.h> resolves to), and a header only
# counts as "owned by bionic" when every architecture we build for has it, so a
# 32-bit build never loses a header the 64-bit one kept.
BIONIC_UAPI_COMMON = [
    "bionic/libc/kernel/uapi",
    "bionic/libc/kernel/android/uapi",
]
BIONIC_UAPI_ASM = [
    "bionic/libc/kernel/uapi/asm-arm64",
    "bionic/libc/kernel/uapi/asm-arm",
]

# Only these top level directories are uapi namespaces; a bare "stdio.h" or a
# "private/foo.h" is bionic's own and never comes from the kernel.
UAPI_PREFIXES = (
    "asm/",
    "asm-generic/",
    "linux/",
    "misc/",
    "mtd/",
    "rdma/",
    "scsi/",
    "sound/",
    "video/",
    "drm/",
    "xen/",
)

INCLUDE_RE = re.compile(r'^\s*#\s*include\s*[<"]([^>"]+)[>"]', re.MULTILINE)


def read(path):
    with open(path, "r", errors="ignore") as f:
        return f.read()


def bionic_provides(header):
    """True when bionic has a scrubbed copy of `header` for every architecture."""
    if header.startswith("asm/"):
        return all(os.path.isfile(os.path.join(root, header))
                   for root in BIONIC_UAPI_ASM)
    return any(os.path.isfile(os.path.join(root, header))
               for root in BIONIC_UAPI_COMMON)


def bionic_path(header):
    """Path of bionic's copy, for following its own #includes."""
    roots = BIONIC_UAPI_ASM if header.startswith("asm/") else BIONIC_UAPI_COMMON
    for root in roots:
        candidate = os.path.join(root, header)
        if os.path.isfile(candidate):
            return candidate
    return None


def uapi_headers_reachable_from_bionic(kernel_include):
    """Every uapi header bionic's public headers can drag in, transitively.

    Both copies of a header are followed: bionic's, which is what a translation
    unit ends up with once we are done, and the kernel's, which is what it sees
    today.  The kernel copy usually has the wider include list - the raw
    asm/signal.h pulls in asm-generic/signal.h where bionic's does not - and
    those extra edges are exactly the ones that leak a second definition in.
    """
    pending = []
    for dirpath, _, filenames in os.walk(BIONIC_PUBLIC):
        for name in filenames:
            if not name.endswith(".h"):
                continue
            for included in INCLUDE_RE.findall(read(os.path.join(dirpath, name))):
                if included.startswith(UAPI_PREFIXES):
                    pending.append(included)

    reachable = set()
    while pending:
        header = pending.pop()
        if header in reachable:
            continue
        reachable.add(header)
        for path in (bionic_path(header), os.path.join(kernel_include, header)):
            if path is None or not os.path.isfile(path):
                continue
            for included in INCLUDE_RE.findall(read(path)):
                if included.startswith(UAPI_PREFIXES):
                    pending.append(included)
    return reachable


def main():
    if len(sys.argv) != 2:
        sys.exit("usage: %s <kernel-headers-install-include-dir>" % sys.argv[0])
    kernel_include = sys.argv[1]

    if not os.path.isdir(kernel_include):
        sys.exit("%s: not a directory" % kernel_include)
    if not os.path.isdir(BIONIC_PUBLIC):
        sys.exit("%s: run me from the top of the Android tree" % BIONIC_PUBLIC)

    pruned = []
    for header in sorted(uapi_headers_reachable_from_bionic(kernel_include)):
        if not bionic_provides(header):
            # Kernel-only header bionic merely mentions; keep the kernel copy.
            continue
        victim = os.path.join(kernel_include, header)
        if os.path.isfile(victim):
            os.remove(victim)
            pruned.append(header)

    # headers_install lays out empty directories too; leaving them behind is
    # harmless but noisy, so tidy up the ones we emptied. Walk bottom-up and ask
    # the filesystem rather than trusting the walk's snapshot, so a directory
    # that only became empty once its children went also gets removed.
    for dirpath, _, _ in os.walk(kernel_include, topdown=False):
        if dirpath != kernel_include and not os.listdir(dirpath):
            os.rmdir(dirpath)

    print("prune_kernel_uapi_headers: dropped %d libc-owned headers from %s"
          % (len(pruned), kernel_include))


if __name__ == "__main__":
    main()
