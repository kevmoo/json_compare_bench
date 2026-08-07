# Benchmark Results

* **Run Date**: `2026-08-07T22:41:46.924679Z`
* **System**: linux (Linux 6.18.14-1rodete4-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.18.14-1rodete4 (2026-06-15)) | x86_64
* **Hardware**: AMD EPYC 7B13 (64 logical cores) | RAM: 117.9 GB
* **Toolchains**:
  * **Dart**: `3.14.0-89.0.dev (dev) (Tue Aug 4 01:07:45 2026 -0700) on "linux_x64"`
  * **Rust**: `rustc 1.97.1 (8bab26f4f 2026-07-14)`
  * **Go**: `go version go1.26.5 linux/amd64`
  * **Node.js**: `v24.19.0 (V8 13.6.233.17-node.51)`
  * **Key Packages**: `serde_json 1.0.151`, `json_annotation 4.12.0`

## DECODE Throughput Matrix

Higher throughput (MB/s) is better. Medals (🥇, 🥈, 🥉) indicate top 3 performance per dataset.

| Dataset | Dart (convert) | Dart (json_rw) | Rust (`serde_json`) | Node.js (V8) | Go (`encoding/json`) |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **`small.json`** (~1 KB) | 🥇 **197.8 MB/s** (`convert_utf8` dart_aot) | 130.6 MB/s (`json_rw_string` dart_aot) | 🥈 **191.7 MB/s** | 🥉 **133.0 MB/s** | 67.7 MB/s |
| ↳ *% of Winner* | **100.0%** | 66.0% | 96.9% | 67.2% | 34.2% |
| **`twitter.json`** (~617 KB) | 🥈 **234.4 MB/s** (`convert_utf8` dart_aot) | 125.9 MB/s (`json_rw_utf8` dart_jit) | 🥉 **204.7 MB/s** | 🥇 **419.1 MB/s** | 81.1 MB/s |
| ↳ *% of Winner* | 55.9% | 30.1% | 48.8% | **100.0%** | 19.4% |
| **`citm_catalog.json`** (~1.6 MB) | 🥉 **342.0 MB/s** (`convert_utf8` dart_aot) | 194.6 MB/s (`json_rw_utf8` dart_jit) | 🥈 **381.6 MB/s** | 🥇 **452.2 MB/s** | 89.4 MB/s |
| ↳ *% of Winner* | 75.6% | 43.0% | 84.4% | **100.0%** | 19.8% |
| **`canada.json`** (~2.1 MB) | 🥉 **91.7 MB/s** (`convert` dart_jit) | 52.9 MB/s (`json_rw_string` dart_jit) | 🥈 **153.0 MB/s** | 🥇 **230.1 MB/s** | 58.0 MB/s |
| ↳ *% of Winner* | 39.9% | 23.0% | 66.5% | **100.0%** | 25.2% |

## ENCODE Throughput Matrix

Higher throughput (MB/s) is better. Medals (🥇, 🥈, 🥉) indicate top 3 performance per dataset.

| Dataset | Dart (convert) | Dart (json_rw) | Rust (`serde_json`) | Node.js (V8) | Go (`encoding/json`) |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **`small.json`** (~1 KB) | 🥉 **144.9 MB/s** (`convert_utf8` dart_aot) | 138.3 MB/s (`json_rw_utf8` dart_aot) | 🥇 **763.5 MB/s** | 🥈 **248.7 MB/s** | 110.8 MB/s |
| ↳ *% of Winner* | 19.0% | 18.1% | **100.0%** | 32.6% | 14.5% |
| **`twitter.json`** (~617 KB) | 150.6 MB/s (`convert` dart_jit) | 🥉 **182.9 MB/s** (`json_rw_utf8` dart_jit) | 🥇 **1086.1 MB/s** | 🥈 **328.8 MB/s** | 128.7 MB/s |
| ↳ *% of Winner* | 13.9% | 16.8% | **100.0%** | 30.3% | 11.9% |
| **`citm_catalog.json`** (~1.6 MB) | 266.7 MB/s (`convert_utf8` dart_aot) | 🥈 **508.0 MB/s** (`json_rw_utf8` dart_jit) | 🥇 **2198.0 MB/s** | 🥉 **442.2 MB/s** | 205.4 MB/s |
| ↳ *% of Winner* | 12.1% | 23.1% | **100.0%** | 20.1% | 9.3% |
| **`canada.json`** (~2.1 MB) | 57.9 MB/s (`convert` dart_jit) | 60.7 MB/s (`json_rw_utf8` dart_jit) | 🥇 **574.5 MB/s** | 🥈 **131.8 MB/s** | 🥉 **129.5 MB/s** |
| ↳ *% of Winner* | 10.1% | 10.6% | **100.0%** | 23.0% | 22.5% |

