# Benchmark Results

* **Run Date**: `2026-08-07T22:36:30.336510Z`
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

| Dataset | Dart (AOT / JIT) | Rust (`serde_json`) | Node.js (V8) | Go (`encoding/json`) |
| :--- | :---: | :---: | :---: | :---: |
| **`small.json`** (~1 KB) | 🥇 **203.4 MB/s** (`convert_utf8`) | 🥈 **158.7 MB/s** | 🥉 **110.8 MB/s** | 65.6 MB/s |
| ↳ *% of Winner* | **100.0%** | 78.0% | 54.5% | 32.2% |
| **`twitter.json`** (~617 KB) | 🥈 **239.2 MB/s** (`convert_utf8`) | 🥉 **192.0 MB/s** | 🥇 **415.6 MB/s** | 80.4 MB/s |
| ↳ *% of Winner* | 57.6% | 46.2% | **100.0%** | 19.3% |
| **`citm_catalog.json`** (~1.6 MB) | 🥈 **361.6 MB/s** (`convert_utf8`) | 🥉 **359.5 MB/s** | 🥇 **461.9 MB/s** | 87.3 MB/s |
| ↳ *% of Winner* | 78.3% | 77.8% | **100.0%** | 18.9% |
| **`canada.json`** (~2.1 MB) | 🥉 **87.0 MB/s** (`convert_utf8`) | 🥈 **153.5 MB/s** | 🥇 **225.6 MB/s** | 57.8 MB/s |
| ↳ *% of Winner* | 38.5% | 68.1% | **100.0%** | 25.6% |

## ENCODE Throughput Matrix

Higher throughput (MB/s) is better. Medals (🥇, 🥈, 🥉) indicate top 3 performance per dataset.

| Dataset | Dart (AOT / JIT) | Rust (`serde_json`) | Node.js (V8) | Go (`encoding/json`) |
| :--- | :---: | :---: | :---: | :---: |
| **`small.json`** (~1 KB) | 🥉 **150.1 MB/s** (`json_rw_utf8`) | 🥇 **729.3 MB/s** | 🥈 **284.2 MB/s** | 110.3 MB/s |
| ↳ *% of Winner* | 20.6% | **100.0%** | 39.0% | 15.1% |
| **`twitter.json`** (~617 KB) | 🥉 **216.5 MB/s** (`json_rw_utf8`) | 🥇 **1110.8 MB/s** | 🥈 **332.6 MB/s** | 126.2 MB/s |
| ↳ *% of Winner* | 19.5% | **100.0%** | 29.9% | 11.4% |
| **`citm_catalog.json`** (~1.6 MB) | 🥈 **506.7 MB/s** (`json_rw_utf8`) | 🥇 **2231.8 MB/s** | 🥉 **433.7 MB/s** | 192.0 MB/s |
| ↳ *% of Winner* | 22.7% | **100.0%** | 19.4% | 8.6% |
| **`canada.json`** (~2.1 MB) | 60.0 MB/s (`json_rw_utf8`) | 🥇 **506.9 MB/s** | 🥈 **152.1 MB/s** | 🥉 **124.4 MB/s** |
| ↳ *% of Winner* | 11.8% | **100.0%** | 30.0% | 24.5% |

