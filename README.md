# 🧠 kernel-fs-lab — Minimal Kernel Debugging Lab with UML

This repository provides a hands-on setup for Linux kernel exploration using **User-Mode Linux (UML)** — with modules, filesystems, networking, and tracing tools. Perfect for students, tinkerers, or developers debugging syscalls or writing kernel modules in a safe, userspace sandbox.

---

## 🚀 Quick Start: Explore Each Lab

Each subdirectory is a self-contained lab. Choose your focus:

| Folder                  | Description                                                              |
|-------------------------|--------------------------------------------------------------------------|
| 🧰 [`UML-setup/`](./UML-setup/)          | Boot a custom UML kernel with hostfs and a minimal Debian rootfs |
| 📂 `ext4-UML/` *(coming soon)*           | Trace and debug ext4 filesystems inside UML                      |
| 🌐 `NFS-UML/` *(coming soon)*            | Simulate and debug NFS client/server behavior                    |
| 🧬 `Parallel-filesystems/` *(coming soon)* | Work with BeeGFS, Lustre, and other distributed filesystems     |

> 📄 Each directory includes a `README.md` with detailed setup and usage instructions.

---

## 📄 License

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
This project is licensed under the [MIT License](./LICENSE) — feel free to use, learn from, or build upon it.

