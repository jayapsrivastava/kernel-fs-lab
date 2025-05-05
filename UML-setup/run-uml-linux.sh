#!/bin/sh

# ── Host‑side UML launcher ────────────────────────────────────
# Wrapper around the `linux-um` kernel binary that uml-setup.sh installs in
# /usr/bin.  Adjust memory, networking, or root‑fs flags below if needed.
#

# used when we have to perfrom bind‑mounted
export TMP=/chroot

# Unique ID for this UML instance (also names the ~/.uml/<UMID>/mconsole socket)
UMID=uml-kdev
rm -rf ~/.uml/$UMID 2>/dev/null || true  # clean any stale socket dir

# ── Launch the User‑Mode Linux kernel ─────────────────────────
#  vec0:transport=tap,ifname=tap0,depth=128,gro=1  - virtual NIC bridged to host tap0
#  rootflags=/umlroot rootfstype=hostfs rw         - mount host /umlroot as / (RW)
#  mem=512M                                        - allocate 512 MB RAM to the guest
#  verbose                                         - extra boot messages
#  init=/init.sh                                   - run our minimal init as PID 1
#  umid=$UMID                                      - tag instance for mconsole paths
linux-um \
	vec0:transport=tap,ifname=tap0,depth=128,gro=1 \
	rootflags=/umlroot rootfstype=hostfs rw \
	mem=512M verbose init=/init.sh umid=$UMID 

# Reset host terminal after UML exits (prevents broken line discipline)
reset
