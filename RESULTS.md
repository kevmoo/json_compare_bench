# Benchmark Results

* **Run Date**: `2026-08-07T23:48:11.292212Z`
* **System**: linux (Linux 6.18.14-1rodete4-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.18.14-1rodete4 (2026-06-15)) | x86_64
* **Hardware**: AMD EPYC 7B13 (64 logical cores) | RAM: 117.9 GB
* **Toolchains & Packages**:
  * **Dart**: `3.14.0-89.0.dev (dev) (Tue Aug 4 01:07:45 2026 -0700) on "linux_x64"`
    * `json_rw`: [kevmoo/json_serializable.dart@c73ec8e](https://github.com/kevmoo/json_serializable.dart/tree/c73ec8e9a1e813a00b903205a39ec2c24a01b94b/json_rw)
    * `json_annotation`: `4.12.0`
  * **Rust**: `rustc 1.97.1 (8bab26f4f 2026-07-14)`
    * `serde_json`: `1.0.151`
    * `serde`: `1.0.229`
    * `mimalloc`: `0.1.52 (global allocator)`
  * **Go**: `go version go1.26.5 linux/amd64`
    * `encoding/json`: `Standard Library`
  * **Node.js**: `v24.19.0 (V8 13.6.233.17-node.51)`
    * `v8_builtin`: `V8 C++ Built-in`

> [!NOTE]
> **Native Byte Buffer Contract**: Native binaries (Dart AOT, Rust, Go) benchmark direct UTF-8 byte serialization/deserialization (`Uint8List` / `&[u8]` / `[]byte`), which represents real-world production I/O (sockets, files, cache). Node.js executes via V8 C++ built-ins.

## DECODE Throughput Matrix

Higher throughput (MB/s) is better. Medals (🥇, 🥈, 🥉) indicate top 3 performance per dataset.

| Dataset | Dart AOT (std) | Dart AOT (json_rw) | Rust (`serde_json`) | Node.js (V8) | Go (`encoding/json`) |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **`small.json`** (~1 KB) | 🥉 **229.2 MB/s** | 64.8 MB/s | 🥇 **280.8 MB/s** | 🥈 **263.6 MB/s** | 52.9 MB/s |
| ↳ *% of Winner* | 81.6% | 23.1% | **100.0%** | 93.9% | 18.9% |
| **`twitter.json`** (~617 KB) | 🥉 **233.5 MB/s** | 80.8 MB/s | 🥈 **279.7 MB/s** | 🥇 **415.3 MB/s** | 80.9 MB/s |
| ↳ *% of Winner* | 56.2% | 19.5% | 67.3% | **100.0%** | 19.5% |
| **`citm_catalog.json`** (~1.6 MB) | 🥉 **324.9 MB/s** | 114.4 MB/s | 🥈 **482.2 MB/s** | 🥇 **487.4 MB/s** | 89.4 MB/s |
| ↳ *% of Winner* | 66.7% | 23.5% | 98.9% | **100.0%** | 18.3% |
| **`canada.json`** (~2.1 MB) | 🥉 **83.8 MB/s** | 36.6 MB/s | 🥇 **285.6 MB/s** | 🥈 **241.9 MB/s** | 57.8 MB/s |
| ↳ *% of Winner* | 29.4% | 12.8% | **100.0%** | 84.7% | 20.3% |

## ENCODE Throughput Matrix

Higher throughput (MB/s) is better. Medals (🥇, 🥈, 🥉) indicate top 3 performance per dataset.

| Dataset | Dart AOT (std) | Dart AOT (json_rw) | Rust (`serde_json`) | Node.js (V8) | Go (`encoding/json`) |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **`small.json`** (~1 KB) | 🥉 **149.0 MB/s** | 142.7 MB/s | 🥇 **897.2 MB/s** | 🥈 **358.7 MB/s** | 98.8 MB/s |
| ↳ *% of Winner* | 16.6% | 15.9% | **100.0%** | 40.0% | 11.0% |
| **`twitter.json`** (~617 KB) | 134.5 MB/s | 🥉 **172.1 MB/s** | 🥇 **1224.9 MB/s** | 🥈 **329.0 MB/s** | 127.0 MB/s |
| ↳ *% of Winner* | 11.0% | 14.0% | **100.0%** | 26.9% | 10.4% |
| **`citm_catalog.json`** (~1.6 MB) | 267.5 MB/s | 🥉 **269.6 MB/s** | 🥇 **2456.9 MB/s** | 🥈 **457.9 MB/s** | 200.8 MB/s |
| ↳ *% of Winner* | 10.9% | 11.0% | **100.0%** | 18.6% | 8.2% |
| **`canada.json`** (~2.1 MB) | 49.3 MB/s | 45.8 MB/s | 🥇 **578.5 MB/s** | 🥈 **142.0 MB/s** | 🥉 **131.4 MB/s** |
| ↳ *% of Winner* | 8.5% | 7.9% | **100.0%** | 24.5% | 22.7% |

