#!/system/bin/sh
#
# First stage debug hook. init runs this from StartConsole() when the kernel
# command line carries androidboot.first_stage_console=1, and blocks in wait()
# until it exits. It runs after DoCreateDevices() - so the dm-linear mappings
# for the logical partitions already exist - but before DoFirstStageMount().
#
# Everything is written to the raw userdata partition and read back from
# recovery with dd. This device has no other log: pstore/ramoops does not
# survive a reset, the debug UART needs the phone opened, and although fbcon
# binds to fb0, cont_splash keeps owning the scanout so console text is painted
# into a buffer that is never displayed.
#
# This destroys the filesystem on userdata, which was explicitly sanctioned.
#
# Layout of the raw userdata partition on an eng build:
#
#     0 MiB    FP4DBG1   this script, one shot, pre-DoFirstStageMount
#    64 MiB    FP4DBG2   /vendor/bin/fp4_kmsglog.sh, second stage onwards,
#    ..88 MiB            rotating over a four slot ring
#
# The FP4DBG2 region is stamped NEVER-RAN here, so finding the stamp intact is
# itself a result: it means second stage init never reached "on early-init".
#
# Design notes, each of which cost a boot to learn:
#
#  - Do not look for the partitions under /dev/block/mapper. First stage init
#    creates the dm nodes but not those by-name symlinks, so mapper is empty
#    here even on a perfectly good mapping. Walk /sys/block/dm-*/dm/name.
#
#  - Use shell builtins. Forking toybox per process per pass was thousands of
#    fork/execs and made the script look like it had hung.
#
#  - Write with shell redirection onto the block device rather than dd. init
#    calls FreeRamdisk() right after SwitchRoot("/system"), which unlinks
#    /system/bin/toybox, so anything that shells out stops working at exactly
#    the moment we most want a sample. Redirection needs no helper binary.
#
#  - Nothing this script leaves running may be a descendant of init. StartConsole
#    installs a SIGCHLD handler with SA_NOCLDWAIT and then calls wait(NULL),
#    which under SA_NOCLDWAIT does not return until pid 1 has no children at
#    all. A backgrounded loop here is orphaned onto pid 1 and parks init inside
#    the hook forever, so every measurement taken that way describes the
#    instrumentation rather than the device. This hook is therefore strictly one
#    shot; everything past DoFirstStageMount() is second stage init's job, and
#    /vendor/bin/fp4_kmsglog.sh covers it from the top of "on early-init".
#
#    Starting a logger out of call_usermodehelper() - which reparents onto
#    kthreadd rather than init, and so is invisible to that wait() - was tried
#    and did not work: neither the /proc/sys/kernel/modprobe nor the
#    core_pattern route ever produced a live helper. Do not bring it back. It
#    also meant redirecting two sysctls that module autoloading depends on,
#    right next to the audio DLKM load this build is trying to observe.
#
# eng builds only.

MAGIC=FP4DBG1
TB=/system/bin/toybox

UD=
for cand in /dev/block/by-name/userdata /dev/block/sda11; do
    [ -e "$cand" ] && { UD=$cand; break; }
done
if [ -z "$UD" ] && [ -x "$TB" ]; then
    while read -r maj min blocks name; do
        if [ "$name" = "sda11" ]; then
            $TB mknod /dev/fp4_ud b "$maj" "$min" 2>/dev/null && UD=/dev/fp4_ud
        fi
    done < /proc/partitions
fi
[ -z "$UD" ] && exit 0

slot=
while read -r line; do
    for w in $line; do
        case "$w" in
            androidboot.slot_suffix=*) slot=${w#*=} ;;
        esac
    done
done < /proc/cmdline

# Stage a toybox on /dev, a tmpfs carried across SwitchRoot, so dmesg keeps
# working after the ramdisk is freed. Best effort; the rest is builtins.
if [ -x "$TB" ]; then
    # Must keep the basename "toybox": the multiplexer dispatches on argv[0],
    # and a copy called anything else answers "Unknown command".
    $TB dd if="$TB" of=/dev/toybox bs=64k 2>/dev/null
    $TB chmod 755 /dev/toybox 2>/dev/null
    [ -x /dev/toybox ] && TB=/dev/toybox
fi

# Stamp every slot of the ring the second stage logger owns, so an untouched
# slot is distinguishable from one written by an earlier boot.
if [ -x "$TB" ]; then
    for off in 64 72 80 88; do
        echo "FP4DBG2 NEVER-RAN" | $TB dd of="$UD" bs=1M seek="$off" \
            conv=notrunc,fsync 2>/dev/null
    done
fi

# StartConsole() runs /system/bin/sh after this script and then blocks in wait()
# forever, because its stdin is the console and nothing ever types on it. That
# would stop init reaching DoFirstStageMount() at all. Removing sh makes the
# spawn fail so init carries on and fails for real, with the logger watching.
rmres="toybox missing"
if [ -x "$TB" ]; then
    $TB rm -f /system/bin/sh 2>/dev/null
    if [ -e /system/bin/sh ]; then rmres="STILL PRESENT"; else rmres="removed ok"; fi
fi

# One-shot probing, kept as text so every later pass can reprint it.
static=$(
    echo "--- dm devices (name <- /sys/block/dm-N/dm/name)"
    for d in /sys/block/dm-*; do
        [ -e "$d/dm/name" ] || continue
        n=; sz=
        while read -r l; do n=$l; done < "$d/dm/name"
        [ -e "$d/size" ] && while read -r l; do sz=$l; done < "$d/size"
        echo "  ${d##*/}  name=$n  size=$sz sectors"
    done
    if [ -x "$TB" ]; then
        echo "--- mount attempts against the dm nodes"
        $TB mkdir -p /dev/fp4_mnt 2>/dev/null
        for d in /sys/block/dm-*; do
            [ -e "$d/dm/name" ] || continue
            n=
            while read -r l; do n=$l; done < "$d/dm/name"
            dev=/dev/block/${d##*/}
            [ -e "$dev" ] || $TB mknod "$dev" b 253 "${d##*/dm-}" 2>/dev/null
            err=$($TB mount -t ext4 -o ro "$dev" /dev/fp4_mnt 2>&1)
            if [ $? -eq 0 ]; then
                echo "  MOUNT OK   $n ($dev)"
                $TB umount /dev/fp4_mnt 2>/dev/null
            else
                echo "  MOUNT FAIL $n ($dev) err=$err"
            fi
        done
    fi
)

# Single pass, and nothing left running that init can see. See the SA_NOCLDWAIT
# note above.
{
    echo "$MAGIC"
    echo "slot_suffix   : [$slot]"
    echo "rm sh         : $rmres"
    echo "log device    : $UD (FP4DBG2 ring at 64/72/80/88 MiB)"
    echo ""
    echo "$static"
    echo ""
    echo "--- /dev/block entries"
    for f in /dev/block/*; do
        if [ -e "$f" ]; then echo -n "${f##*/} "; fi
    done
    echo ""
    echo ""
    echo "--- mounts"
    while read -r l; do echo "  $l"; done < /proc/mounts
    echo ""
    echo "--- dmesg"
    if [ -x "$TB" ]; then $TB dmesg 2>&1; fi
    echo "$MAGIC-END"
} > "$UD" 2>/dev/null

exit 0
