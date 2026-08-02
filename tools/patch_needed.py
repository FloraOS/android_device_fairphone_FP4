#!/usr/bin/env python3
"""Rewrite DT_NEEDED / DT_SONAME strings in place in an ELF shared object.

In-place only: the replacement must be no longer than the original, because the
string is patched where it already sits in .dynstr. Same length is ideal (no
truncation at all); shorter is written NUL-terminated.

Used to point the FP4's QCOM vendor blobs at their own tinyxml2 instead of the
tree's v11 one, whose XMLDocument layout they were never compiled against.
"""
import struct
import sys

DT_NEEDED, DT_SONAME, DT_STRTAB, DT_NULL = 1, 14, 5, 0


def patch(path, old, new, tags=(DT_NEEDED, DT_SONAME)):
    if len(new) > len(old):
        raise SystemExit(f"{path}: '{new}' longer than '{old}' - cannot patch in place")

    with open(path, "rb") as f:
        b = bytearray(f.read())

    if b[:4] != b"\x7fELF":
        raise SystemExit(f"{path}: not an ELF")
    is64 = b[4] == 2
    little = b[5] == 1
    e = "<" if little else ">"

    # Program headers: needed both to find PT_DYNAMIC and to map vaddr->offset.
    if is64:
        e_phoff, e_phentsize, e_phnum = (
            struct.unpack_from(e + "Q", b, 32)[0],
            struct.unpack_from(e + "H", b, 54)[0],
            struct.unpack_from(e + "H", b, 56)[0],
        )
    else:
        e_phoff, e_phentsize, e_phnum = (
            struct.unpack_from(e + "I", b, 28)[0],
            struct.unpack_from(e + "H", b, 42)[0],
            struct.unpack_from(e + "H", b, 44)[0],
        )

    loads, dyn = [], None
    for i in range(e_phnum):
        off = e_phoff + i * e_phentsize
        p_type = struct.unpack_from(e + "I", b, off)[0]
        if is64:
            p_offset, p_vaddr = struct.unpack_from(e + "QQ", b, off + 8)
            p_filesz = struct.unpack_from(e + "Q", b, off + 32)[0]
        else:
            p_offset, p_vaddr = struct.unpack_from(e + "II", b, off + 4)
            p_filesz = struct.unpack_from(e + "I", b, off + 16)[0]
        if p_type == 1:  # PT_LOAD
            loads.append((p_vaddr, p_offset, p_filesz))
        elif p_type == 2:  # PT_DYNAMIC
            dyn = (p_offset, p_filesz)

    if dyn is None:
        raise SystemExit(f"{path}: no PT_DYNAMIC")

    def v2o(vaddr):
        for p_vaddr, p_offset, p_filesz in loads:
            if p_vaddr <= vaddr < p_vaddr + p_filesz:
                return p_offset + (vaddr - p_vaddr)
        raise SystemExit(f"{path}: vaddr {vaddr:#x} outside any PT_LOAD")

    esz = 16 if is64 else 8
    fmt = e + ("Qq" if is64 else "Ii")

    # First pass: locate .dynstr.
    strtab = None
    d_off, d_size = dyn
    for off in range(d_off, d_off + d_size, esz):
        tag, val = struct.unpack_from(fmt, b, off)
        if tag == DT_NULL:
            break
        if tag == DT_STRTAB:
            strtab = v2o(val)
    if strtab is None:
        raise SystemExit(f"{path}: no DT_STRTAB")

    # Second pass: patch matching entries, addressing .dynstr by the exact
    # offset the dynamic entry names, so nothing outside it is touched.
    hits = []
    for off in range(d_off, d_off + d_size, esz):
        tag, val = struct.unpack_from(fmt, b, off)
        if tag == DT_NULL:
            break
        if tag not in tags:
            continue
        s = strtab + val
        end = b.index(b"\0", s)
        if bytes(b[s:end]) != old.encode():
            continue
        b[s:end] = new.encode().ljust(end - s, b"\0")
        hits.append("SONAME" if tag == DT_SONAME else "NEEDED")

    if not hits:
        return None
    with open(path, "wb") as f:
        f.write(b)
    return hits


if __name__ == "__main__":
    old, new, files = sys.argv[1], sys.argv[2], sys.argv[3:]
    for p in files:
        r = patch(p, old, new)
        print(f"  {'patched ' + ','.join(r) if r else 'no match'}  {p}")
