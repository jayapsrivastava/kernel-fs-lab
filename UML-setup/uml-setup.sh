#!/usr/bin/env bash
# Simple UML bootstrap (safe to re-run)
set -euo pipefail

# ─── Tunables ─────────────────────────────────────────────────────
TAP_DEV=tap0
HOST_IP=192.168.0.1/24          # host address inside the /24
UML_USER=uml-net             # who will own the TAP device

KVER=6.12.10                    # kernel version to build
PATCHSET="v${KVER%%.*}.x"       # auto-derive v6.x / v5.x …
KDIR="$(pwd)/linux-${KVER}"     # kernel tree lives inside repo

ROOTFS=/umlroot                 # guest root-fs location
CONFIG="$(pwd)/uml.config"      # UML-enabled .config
# ──────────────────────────────────────────────────────────────────

info() { echo "[*] $*"; }

install_deps() {
    info "Installing minimal build dependencies"
    apt-get update -qq
    apt-get install --no-install-recommends -y \
        build-essential bc flex bison xz-utils wget ca-certificates \
        debootstrap uml-utilities git
}

build_kernel() {
    [[ -f $CONFIG ]] || { echo "[!] $CONFIG not found"; exit 1; }

    if [[ ! -d $KDIR ]]; then
        info "Fetching Linux $KVER sources (into repo)"
        wget -q -O linux-${KVER}.tar.xz \
             "https://cdn.kernel.org/pub/linux/kernel/${PATCHSET}/linux-${KVER}.tar.xz"
        tar -xf linux-${KVER}.tar.xz
        rm linux-${KVER}.tar.xz
    fi

    cd "$KDIR"
    cp "$CONFIG" .config
    info "Building UML kernel (this takes a few minutes…)"

    make ARCH=um olddefconfig
    make ARCH=um -j"$(nproc)"
    make ARCH=um modules
    make ARCH=um modules_install INSTALL_MOD_PATH="$ROOTFS"

    install -m755 linux /usr/bin/linux-um
    cp ../run-uml-linux.sh /usr/bin/run-uml-linux.sh
    cd ../
}

make_rootfs() {
    if [[ ! -d $ROOTFS ]]; then
        info "Bootstrapping Debian into $ROOTFS"
        debootstrap buster "$ROOTFS" http://deb.debian.org/debian
    else
        info "$ROOTFS already exists – skipping debootstrap"
    fi

    bash -c "chroot /umlroot apt-get update"

    ## copy custom init
    mkdir /chroot
    cp ./init.sh     "$ROOTFS"/init.sh
    cp ./uml.bashrc  "$ROOTFS"/.bashrc
    chmod +x "$ROOTFS"/init.sh
}

setup_tap() {
    if ip link show "$TAP_DEV" &>/dev/null; then
        info "$TAP_DEV already exists – skipping creation"
    else
        info "Creating TAP device $TAP_DEV"
        ip tuntap add dev "$TAP_DEV" mode tap user "$UML_USER"
    fi
    ip addr replace "$HOST_IP" dev "$TAP_DEV"
    ip link set "$TAP_DEV" up
    ip addr show dev "$TAP_DEV"
}

main() {
    [[ $EUID -eq 0 ]] || { echo "Run with sudo."; exit 1; }

    install_deps
    make_rootfs
    build_kernel
    setup_tap

    cat <<EOF

✓ All done.

Start UML with: /usr/bin/run-uml-linux.sh

EOF
}

main "$@"

