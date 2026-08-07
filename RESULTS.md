# Benchmark Results

* **Run Date**: `2026-08-07T23:40:03.265828Z`
* **System**: linux (Linux 6.18.14-1rodete4-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.18.14-1rodete4 (2026-06-15)) | x86_64
* **Hardware**: AMD EPYC 7B13 (64 logical cores) | RAM: 117.9 GB
* **Toolchains & Packages**:
  * **Dart**: `3.14.0-89.0.dev (dev) (Tue Aug 4 01:07:45 2026 -0700) on "linux_x64"`
    * `json_rw`: [kevmoo/json_serializable.dart@c73ec8e](https://github.com/kevmoo/json_serializable.dart/tree/c73ec8e9a1e813a00b903205a39ec2c24a01b94b/json_rw)
    * `json_annotation`: `4.12.0`
  * **Rust**: `rustc 1.97.1 (8bab26f4f 2026-07-14)`
    * `serde_json`: `1.0.151`
    * `serde`: `1.0.229`
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
| **`small.json`** (~1 KB) | 🥈 **235.8 MB/s** | 59.1 MB/s | 🥉 **196.8 MB/s** | 🥇 **262.6 MB/s** | 57.5 MB/s |
| ↳ *% of Winner* | 89.8% | 22.5% | 74.9% | **100.0%** | 21.9% |
| **`twitter.json`** (~617 KB) | 🥈 **230.8 MB/s** | 80.5 MB/s | 🥉 **201.6 MB/s** | 🥇 **429.0 MB/s** | 80.0 MB/s |
| ↳ *% of Winner* | 53.8% | 18.8% | 47.0% | **100.0%** | 18.6% |
| **`citm_catalog.json`** (~1.6 MB) | 🥉 **324.8 MB/s** | 112.9 MB/s | 🥈 **365.5 MB/s** | 🥇 **476.4 MB/s** | 89.0 MB/s |
| ↳ *% of Winner* | 68.2% | 23.7% | 76.7% | **100.0%** | 18.7% |
| **`canada.json`** (~2.1 MB) | 🥉 **82.6 MB/s** | 36.6 MB/s | 🥈 **150.0 MB/s** | 🥇 **242.9 MB/s** | 57.4 MB/s |
| ↳ *% of Winner* | 34.0% | 15.1% | 61.7% | **100.0%** | 23.6% |

## ENCODE Throughput Matrix

Higher throughput (MB/s) is better. Medals (🥇, 🥈, 🥉) indicate top 3 performance per dataset.

| Dataset | Dart AOT (std) | Dart AOT (json_rw) | Rust (`serde_json`) | Node.js (V8) | Go (`encoding/json`) |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **`small.json`** (~1 KB) | 🥉 **145.7 MB/s** | 141.3 MB/s | 🥇 **821.7 MB/s** | 🥈 **361.0 MB/s** | 98.4 MB/s |
| ↳ *% of Winner* | 17.7% | 17.2% | **100.0%** | 43.9% | 12.0% |
| **`twitter.json`** (~617 KB) | 137.0 MB/s | 🥉 **150.4 MB/s** | 🥇 **940.7 MB/s** | 🥈 **334.0 MB/s** | 123.7 MB/s |
| ↳ *% of Winner* | 14.6% | 16.0% | **100.0%** | 35.5% | 13.1% |
| **`citm_catalog.json`** (~1.6 MB) | 275.3 MB/s | 🥉 **278.0 MB/s** | 🥇 **2164.6 MB/s** | 🥈 **419.4 MB/s** | 205.1 MB/s |
| ↳ *% of Winner* | 12.7% | 12.8% | **100.0%** | 19.4% | 9.5% |
| **`canada.json`** (~2.1 MB) | 48.6 MB/s | 46.4 MB/s | 🥇 **565.5 MB/s** | 🥈 **137.2 MB/s** | 🥉 **130.4 MB/s** |
| ↳ *% of Winner* | 8.6% | 8.2% | **100.0%** | 24.3% | 23.1% |

