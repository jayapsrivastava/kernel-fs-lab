#!/bin/sh

# ── Pseudo-filesystems ─────────────────────────────────────────
mount -t proc  proc /proc           # /proc → kernel + process info
mount -t sysfs sys  /sys            # /sys  → devices, net stats
# Verify mounts inside UML with:   cat /proc/mounts

# ── Bring up networking for TAP ↔ vec0 link ───────────────────
ip addr add 192.168.0.253/24 dev vec0
ip link set vec0 up

uname -a                            # show UML kernel version
echo "\nWelcome to KDEV-UML\n"

# ── Interactive console shell ─────────────────────────────────
# We want an interactive Bash on the UML console (tty0) *with* job control
# without killing PID 1 when we exit. Here’s the magic in one line:
#   setsid  → create a new session so the shell has its own controlling tty
#   sh -c   → run the following tiny command string under /bin/sh
#   exec    → replace that sh with Bash, so Bash ends up as the session leader
#   /bin/bash → the interactive shell we want
#   </dev/tty0 → stdin comes from the UML console
#   >/dev/tty0 2>&1 → stdout & stderr go to the same console
setsid sh -c 'exec /bin/bash </dev/tty0 >/dev/tty0 2>&1'
