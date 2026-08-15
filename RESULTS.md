# Benchmark Results

* **Run Date**: `2026-08-15T19:14:56.014711Z`
* **System**: linux (Linux 6.18.14-1rodete4-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.18.14-1rodete4 (2026-06-15)) | x86_64
* **Hardware**: AMD EPYC 7B13 (64 logical cores) | RAM: 117.9 GB
* **Toolchains & Packages**:
  * **Dart (Custom SDK)**: `3.14.0-edge.74870c4af39697fde442b41e321219f092b4ab27 (main) (Sat Aug 15 18:45:11 2026 +0000) on "linux_x64"`
    * `codable`: `package:codable (SDK integration)`
  * **Dart (Stock SDK)**: `Dart SDK version: 3.14.0-111.0.dev (dev) (Mon Aug 10 13:05:33 2026 -0700) on "linux_x64"`
    * `convert`: `Standard Library (stock out-of-the-box)`
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

<!-- mdformat off -->
| Dataset | Dart AOT (Stock std) | Dart AOT (std) | Dart AOT (package:codable) | Rust (`serde_json`) | Node.js (V8) | Go (`encoding/json`) |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **`small.json`** (~1 KB) | 🥉 **237.5 MB/s** | 201.3 MB/s | 116.0 MB/s | 🥇 **422.7 MB/s** | 🥈 **259.5 MB/s** | 65.7 MB/s |
| ↳ *% of Winner* | 56.2% | 47.6% | 27.4% | **100.0%** | 61.4% | 15.5% |
| **`twitter.json`** (~617 KB) | 🥉 **236.6 MB/s** | 227.5 MB/s | 120.4 MB/s | 🥇 **491.7 MB/s** | 🥈 **430.5 MB/s** | 94.4 MB/s |
| ↳ *% of Winner* | 48.1% | 46.3% | 24.5% | **100.0%** | 87.6% | 19.2% |
| **`citm_catalog.json`** (~1.6 MB) | 315.2 MB/s | 🥉 **326.9 MB/s** | 196.6 MB/s | 🥇 **672.9 MB/s** | 🥈 **485.1 MB/s** | 84.8 MB/s |
| ↳ *% of Winner* | 46.8% | 48.6% | 29.2% | **100.0%** | 72.1% | 12.6% |
| **`canada.json`** (~2.1 MB) | 86.2 MB/s | 138.7 MB/s | 🥉 **154.1 MB/s** | 🥇 **417.3 MB/s** | 🥈 **248.1 MB/s** | 54.5 MB/s |
| ↳ *% of Winner* | 20.7% | 33.2% | 36.9% | **100.0%** | 59.5% | 13.1% |
<!-- mdformat on -->

## ENCODE Throughput Matrix

Higher throughput (MB/s) is better. Medals (🥇, 🥈, 🥉) indicate top 3 performance per dataset.

<!-- mdformat off -->
| Dataset | Dart AOT (Stock std) | Dart AOT (std) | Dart AOT (package:codable) | Rust (`serde_json`) | Node.js (V8) | Go (`encoding/json`) |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **`small.json`** (~1 KB) | 146.3 MB/s | 130.8 MB/s | 262.0 MB/s | 🥇 **845.1 MB/s** | 🥉 **356.8 MB/s** | 🥈 **377.6 MB/s** |
| ↳ *% of Winner* | 17.3% | 15.5% | 31.0% | **100.0%** | 42.2% | 44.7% |
| **`twitter.json`** (~617 KB) | 134.7 MB/s | 239.3 MB/s | 🥉 **334.3 MB/s** | 🥇 **1223.6 MB/s** | 329.5 MB/s | 🥈 **656.1 MB/s** |
| ↳ *% of Winner* | 11.0% | 19.6% | 27.3% | **100.0%** | 26.9% | 53.6% |
| **`citm_catalog.json`** (~1.6 MB) | 272.5 MB/s | 425.5 MB/s | 🥉 **545.3 MB/s** | 🥇 **3031.3 MB/s** | 412.4 MB/s | 🥈 **1257.2 MB/s** |
| ↳ *% of Winner* | 9.0% | 14.0% | 18.0% | **100.0%** | 13.6% | 41.5% |
| **`canada.json`** (~2.1 MB) | 49.1 MB/s | 69.0 MB/s | 72.8 MB/s | 🥇 **690.0 MB/s** | 🥉 **138.4 MB/s** | 🥈 **162.0 MB/s** |
| ↳ *% of Winner* | 7.1% | 10.0% | 10.5% | **100.0%** | 20.1% | 23.5% |
<!-- mdformat on -->

