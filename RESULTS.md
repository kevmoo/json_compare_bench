# Benchmark Results

* **Run Date**: `2026-08-15T06:09:47.522505Z`
* **System**: linux (Linux 6.18.14-1rodete4-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.18.14-1rodete4 (2026-06-15)) | x86_64
* **Hardware**: AMD EPYC 7B13 (64 logical cores) | RAM: 117.9 GB
* **Toolchains & Packages**:
  * **Dart**: `3.14.0-111.0.dev (dev) (Mon Aug 10 13:05:33 2026 -0700) on "linux_x64"`
    * `codable`: `package:codable (SDK integration)`
  * **Rust**: `rustc 1.97.1 (8bab26f4f 2026-07-14)`
    * `serde_json`: `1.0.151`
    * `serde`: `1.0.229`
    * `mimalloc`: `0.1.52 (global allocator)`
  * **Go**: `go version go1.25.12 linux/amd64`
    * `encoding/json`: `Standard Library`
  * **Node.js**: `v24.19.0 (V8 13.6.233.17-node.51)`
    * `v8_builtin`: `V8 C++ Built-in`

> [!NOTE]
> **Native Byte Buffer Contract & Implementation Context**:
> * **Native Byte Buffer Contract**: Native binaries (Dart AOT, Rust, Go) benchmark direct UTF-8 byte serialization/deserialization (`Uint8List` / `&[u8]` / `[]byte`), which represents real-world production I/O (sockets, files, cache). Node.js executes via V8 C++ built-ins.
> * **`Dart AOT (std)`**: Uses standard library `dart:convert`. Decode is `utf8.decoder.fuse(json.decoder)` into dynamic `Map<String, dynamic>`. Encode is `json.encoder.fuse(utf8.encoder)`.
> * **`Dart AOT (package:codable)`**: Uses the next-generation streaming zero-allocation deserializer/serializer (`package:codable`) with delimiter-fused reads, SWAR 64-bit jump tables, and Eisel-Lemire float parsing operating directly over raw UTF-8 byte spans without intermediate DOM maps.

## DECODE Throughput Matrix

Higher throughput (MB/s) is better. Medals (🥇, 🥈, 🥉) indicate top 3 performance per dataset.

| Dataset | Dart AOT (std) | Dart AOT (package:codable) | Rust (`serde_json`) | Node.js (V8) | Go (`encoding/json`) |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **`small.json`** (~1 KB) | 🥉 **233.7 MB/s** | 183.9 MB/s | 🥇 **416.3 MB/s** | 🥈 **252.9 MB/s** | 66.9 MB/s |
| ↳ *% of Winner* | 56.1% | 44.2% | **100.0%** | 60.8% | 16.1% |
| **`twitter.json`** (~617 KB) | 🥉 **235.2 MB/s** | 129.3 MB/s | 🥇 **492.3 MB/s** | 🥈 **425.5 MB/s** | 97.5 MB/s |
| ↳ *% of Winner* | 47.8% | 26.3% | **100.0%** | 86.4% | 19.8% |
| **`citm_catalog.json`** (~1.6 MB) | 339.2 MB/s | 🥉 **420.8 MB/s** | 🥇 **749.3 MB/s** | 🥈 **478.0 MB/s** | 91.3 MB/s |
| ↳ *% of Winner* | 45.3% | 56.2% | **100.0%** | 63.8% | 12.2% |
| **`canada.json`** (~2.1 MB) | 87.1 MB/s | 🥉 **232.5 MB/s** | 🥇 **418.6 MB/s** | 🥈 **244.0 MB/s** | 56.1 MB/s |
| ↳ *% of Winner* | 20.8% | 55.5% | **100.0%** | 58.3% | 13.4% |

## ENCODE Throughput Matrix

Higher throughput (MB/s) is better. Medals (🥇, 🥈, 🥉) indicate top 3 performance per dataset.

| Dataset | Dart AOT (std) | Dart AOT (package:codable) | Rust (`serde_json`) | Node.js (V8) | Go (`encoding/json`) |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **`small.json`** (~1 KB) | 143.3 MB/s | 61.6 MB/s | 🥇 **942.7 MB/s** | 🥉 **372.8 MB/s** | 🥈 **373.5 MB/s** |
| ↳ *% of Winner* | 15.2% | 6.5% | **100.0%** | 39.5% | 39.6% |
| **`twitter.json`** (~617 KB) | 135.1 MB/s | 63.0 MB/s | 🥇 **1275.3 MB/s** | 🥉 **333.8 MB/s** | 🥈 **670.1 MB/s** |
| ↳ *% of Winner* | 10.6% | 4.9% | **100.0%** | 26.2% | 52.5% |
| **`citm_catalog.json`** (~1.6 MB) | 262.6 MB/s | 93.6 MB/s | 🥇 **2349.2 MB/s** | 🥉 **426.8 MB/s** | 🥈 **1134.8 MB/s** |
| ↳ *% of Winner* | 11.2% | 4.0% | **100.0%** | 18.2% | 48.3% |
| **`canada.json`** (~2.1 MB) | 49.1 MB/s | 27.8 MB/s | 🥇 **638.5 MB/s** | 🥉 **136.9 MB/s** | 🥈 **164.8 MB/s** |
| ↳ *% of Winner* | 7.7% | 4.4% | **100.0%** | 21.4% | 25.8% |

