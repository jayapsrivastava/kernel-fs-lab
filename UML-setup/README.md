# 🧠 UML-setup — Minimal Bootable Kernel Lab with User-Mode Linux

This subdirectory provides a ready-to-use setup to boot a custom Linux kernel inside **User-Mode Linux (UML)**, with:

- A minimal writable Debian root filesystem (`/umlroot`)
- Host-to-guest networking via TAP (`tap0 ↔ vec0`)
- A clean init flow via `init.sh`
- Support for kernel modules and GDB-based debugging

---

## 📁 Files in this Directory

| File                  | Purpose                                                              |
|-----------------------|----------------------------------------------------------------------|
| `uml-setup.sh`        | Main bootstrap script: builds kernel, rootfs, TAP networking         |
| `uml.config`          | Preconfigured `.config` with UML options for Linux kernel            |
| `init.sh`             | Minimal init script for guest; launches Bash on boot                 |
| `run-uml-linux.sh`    | Launch script for running the UML kernel with correct flags          |
| `uml.bashrc`          | Optional `.bashrc` copied into `/umlroot` to improve prompt          |
| `linux-<ver>/`        | Linux source tree (created during first run)                         |

> `linux-*` and `*.tar.xz` are ignored via `.gitignore` to keep the repo clean.

---

## 🚀 Quick Start

To boot a working UML lab in minutes:

```
chmod +x uml-setup.sh
sudo ./uml-setup.sh
sudo /usr/bin/run-uml-linux.sh
```

## 🌀 Change Kernel Version (Optional)

To use a different version:

```
sudo KVER=5.15.149 ./uml-setup.sh
```

The script will automatically fetch the matching kernel source and configure it accordingly.

## ⚙️ Customize with Environment Variables

You can tweak the build and network configuration using environment variables:

| Variable   | Default           | Description                              |
|------------|-------------------|------------------------------------------|
| `KVER`     | `6.12.10`         | Kernel version to fetch and build        |
| `TAP_DEV`  | `tap0`            | TAP interface name on host               |
| `HOST_IP`  | `192.168.0.1/24`  | IP address assigned to `tap0`            |
| `ROOTFS`   | `/umlroot`        | Guest root filesystem directory          |
| `KDIR`     | `./linux-<ver>`   | Where kernel source is unpacked          |

**Example:**

```
sudo HOST_IP=10.0.0.1/24 TAP_DEV=tap1 ./uml-setup.sh
```

## 📦 Add Packages Inside UML

Once booted, you can add tools like `vim`, `htop`, `strace`, etc. directly to your UML guest:

```
sudo chroot /umlroot
apt-get update
apt-get install vim strace htop
exit
```

✅ Changes persist — the /umlroot directory is your actual root filesystem.

## 🔚 Stopping UML Instances

When you're done experimenting, shut it down gracefully:

### Inside UML:

```
poweroff -f   # Immediately power off
reboot -f     # Reboot if needed
```

From the host (via mconsole):
```
uml_mconsole uml-kdev halt
# Or if using a custom UMID:
uml_mconsole "$UMID" halt
```
Check the control socket path:
```
ls -la ~/.uml/uml-kdev/mconsole
```

## 🧹 Cleanup

```
sudo ip link del tap0
sudo rm -rf /umlroot
rm -rf linux-*
```
## 🛠 Troubleshooting Tips

| Problem                  | Solution                                                                 |
|--------------------------|--------------------------------------------------------------------------|
| `tap0` missing           | Rerun `uml-setup.sh` — it recreates the device                          |
| Guest has no networking  | Ensure IPs match, and both `tap0` and `vec0` are UP                      |
| Kernel build fails       | Make sure required packages (`build-essential`, etc.) are installed      |
| UML exits immediately    | Check if `init.sh` is present and boot flags like `rootflags=/umlroot` are correct |

---

📄 This lab follows the [MIT License](../LICENSE) defined in the root of this repository.

