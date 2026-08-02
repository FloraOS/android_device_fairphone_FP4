#!/vendor/bin/sh
#
# Second stage boot logger, eng builds only.
#
# This device has no post-mortem log. pstore/ramoops is configured and the
# driver attaches, but the region does not survive a reset; the debug UART
# needs the phone opened; fbcon only takes the panel after the interesting
# part of boot is over; and /data never gets mounted, so there is no tombstone
# and no logcat to collect. The one channel that works is writing straight at
# the raw userdata partition and reading it back from recovery with dd, which
# is why userdata is treated as a scratch log area on this build.
#
# init.target.rc starts this from the top of its "on early-init" block, ahead
# of the blocking modprobe of the audio DLKMs, so that a hang in that modprobe
# is observed rather than merely inferred.
#
# Layout of the raw userdata partition on an eng build:
#
#     0 MiB   FP4DBG1   first_stage.sh, one shot, pre-DoFirstStageMount
#    64 MiB   FP4DBG2   context: properties, mounts, process list, init state.
#                       Written once, at startup. Expensive - getprop and ps
#                       together are most of a second - so it is not repeated.
#    72 MiB   FP4DBG2   dmesg-only samples, rotating over three slots
#    80 MiB
#    88 MiB
#
# Three lessons from the previous two boots, all folded in here:
#
#  - dd without conv=fsync only dirties the page cache, and every pass wrote to
#    the same offset. When the SoC wedged and the watchdog reset it the dirty
#    pages went with it, and the only sample that had aged out to flash was the
#    first one. Everything is fsync'd now.
#
#  - A reset landing mid-write leaves a torn sample and nothing else, so the
#    samples rotate over a ring. Read all of them and take the highest "pass".
#
#  - One sample a second was far too coarse: the SoC wedged inside the second
#    that followed pass 0, twice, so the interesting part was never sampled at
#    all. The sampling loop is now dmesg only, which is a couple of forks and a
#    ~300 kB write, and runs five times a second.
#
MAGIC=FP4DBG2
UD=/dev/block/by-name/userdata

[ -e "$UD" ] || UD=/dev/block/sda11
[ -e "$UD" ] || exit 0

# One-shot context sample. What pid 1 is doing matters most: init runs "exec"
# commands synchronously, so init parked with an exec child alive means the boot
# is blocked on that child rather than crashed.
{
    echo "$MAGIC"
    echo "pass          : context"
    echo "uptime        : $(cat /proc/uptime)"
    echo ""
    echo "--- init state"
    echo "  syscall : $(cat /proc/1/syscall 2>/dev/null)"
    echo "  wchan   : $(cat /proc/1/wchan 2>/dev/null)"
    echo "  stat    : $(cat /proc/1/stat 2>/dev/null)"
    echo ""
    echo "--- processes"
    ps -A -o pid,ppid,stat,wchan,comm 2>/dev/null || ps -A 2>/dev/null
    echo ""
    echo "--- services"
    getprop | grep init.svc
    echo ""
    echo "--- mounts"
    cat /proc/mounts
    echo ""
    echo "--- properties"
    getprop
    echo "$MAGIC-END"
} 2>&1 | dd of="$UD" bs=1M seek=64 conv=notrunc,fsync 2>/dev/null

# Fast sampling loop. Bounded, so a build that boots does not keep a shell
# spinning forever; five a second for 20 minutes is far longer than any boot
# that is going to succeed, and the watchdog gets there long before it runs out.
i=0
while [ $i -lt 6000 ]; do
    seek=$((72 + (i % 3) * 8))
    {
        echo "$MAGIC"
        echo "pass          : $i"
        echo "uptime        : $(cat /proc/uptime)"
        echo "init wchan    : $(cat /proc/1/wchan 2>/dev/null)"
        echo ""
        echo "--- dmesg"
        dmesg
        echo "$MAGIC-END"
    } 2>&1 | dd of="$UD" bs=1M seek=$seek conv=notrunc,fsync 2>/dev/null
    sleep 0.2
    i=$((i + 1))
done

exit 0
