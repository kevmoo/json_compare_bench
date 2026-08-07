# Benchmark Results

* **Run Date**: `2026-08-07T22:45:30.782032Z`
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

## DECODE Throughput Matrix

Higher throughput (MB/s) is better. Medals (🥇, 🥈, 🥉) indicate top 3 performance per dataset.

| Dataset | Dart (convert) | Dart (json_rw) | Rust (`serde_json`) | Node.js (V8) | Go (`encoding/json`) |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **`small.json`** (~1 KB) | 🥇 **198.1 MB/s** (`convert_utf8` dart_aot) | 130.9 MB/s (`json_rw_string` dart_aot) | 🥈 **196.1 MB/s** | 🥉 **134.8 MB/s** | 60.5 MB/s |
| ↳ *% of Winner* | **100.0%** | 66.1% | 98.9% | 68.0% | 30.5% |
| **`twitter.json`** (~617 KB) | 🥈 **231.5 MB/s** (`convert_utf8` dart_aot) | 121.7 MB/s (`json_rw_utf8` dart_jit) | 🥉 **192.4 MB/s** | 🥇 **406.4 MB/s** | 80.5 MB/s |
| ↳ *% of Winner* | 57.0% | 30.0% | 47.4% | **100.0%** | 19.8% |
| **`citm_catalog.json`** (~1.6 MB) | 🥉 **344.7 MB/s** (`convert_utf8` dart_aot) | 185.2 MB/s (`json_rw_utf8` dart_jit) | 🥈 **384.3 MB/s** | 🥇 **440.5 MB/s** | 88.9 MB/s |
| ↳ *% of Winner* | 78.2% | 42.0% | 87.2% | **100.0%** | 20.2% |
| **`canada.json`** (~2.1 MB) | 🥉 **92.0 MB/s** (`convert` dart_jit) | 50.6 MB/s (`json_rw_string` dart_jit) | 🥈 **150.8 MB/s** | 🥇 **231.4 MB/s** | 57.9 MB/s |
| ↳ *% of Winner* | 39.8% | 21.9% | 65.2% | **100.0%** | 25.0% |

## ENCODE Throughput Matrix

Higher throughput (MB/s) is better. Medals (🥇, 🥈, 🥉) indicate top 3 performance per dataset.

| Dataset | Dart (convert) | Dart (json_rw) | Rust (`serde_json`) | Node.js (V8) | Go (`encoding/json`) |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **`small.json`** (~1 KB) | 🥉 **142.7 MB/s** (`convert_utf8` dart_aot) | 138.6 MB/s (`json_rw_utf8` dart_aot) | 🥇 **676.2 MB/s** | 🥈 **264.4 MB/s** | 110.7 MB/s |
| ↳ *% of Winner* | 21.1% | 20.5% | **100.0%** | 39.1% | 16.4% |
| **`twitter.json`** (~617 KB) | 148.6 MB/s (`convert` dart_jit) | 🥉 **195.3 MB/s** (`json_rw_utf8` dart_jit) | 🥇 **1115.2 MB/s** | 🥈 **287.5 MB/s** | 125.9 MB/s |
| ↳ *% of Winner* | 13.3% | 17.5% | **100.0%** | 25.8% | 11.3% |
| **`citm_catalog.json`** (~1.6 MB) | 274.8 MB/s (`convert_utf8` dart_aot) | 🥈 **439.6 MB/s** (`json_rw_utf8` dart_jit) | 🥇 **1961.2 MB/s** | 🥉 **428.4 MB/s** | 199.5 MB/s |
| ↳ *% of Winner* | 14.0% | 22.4% | **100.0%** | 21.8% | 10.2% |
| **`canada.json`** (~2.1 MB) | 60.3 MB/s (`convert` dart_jit) | 61.4 MB/s (`json_rw_utf8` dart_jit) | 🥇 **570.4 MB/s** | 🥈 **151.0 MB/s** | 🥉 **129.4 MB/s** |
| ↳ *% of Winner* | 10.6% | 10.8% | **100.0%** | 26.5% | 22.7% |

