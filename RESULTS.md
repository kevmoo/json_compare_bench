# Benchmark Results

* **Run Date**: `2026-08-15T18:33:21.760439Z`
* **System**: linux (Linux 6.18.14-1rodete4-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.18.14-1rodete4 (2026-06-15)) | x86_64
* **Hardware**: AMD EPYC 7B13 (64 logical cores) | RAM: 117.9 GB
* **Toolchains & Packages**:
  * **Dart (Custom SDK)**: `3.14.0-edge.8bbcad750cbe188ab0f26a83c26388c351aba205 (main) (Sat Aug 15 07:56:30 2026 +0000) on "linux_x64"`
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
| Dataset | Dart AOT (Stock std) | Dart AOT (std) | Dart AOT (package:codable) |
| :--- | :---: | :---: | :---: |
| **`small.json`** (~1 KB) | 🥈 **227.6 MB/s** | 🥇 **231.4 MB/s** | 🥉 **112.4 MB/s** |
| ↳ *% of Winner* | 98.4% | **100.0%** | 48.6% |
| **`twitter.json`** (~617 KB) | 🥇 **241.6 MB/s** | 🥈 **228.6 MB/s** | 🥉 **127.4 MB/s** |
| ↳ *% of Winner* | **100.0%** | 94.6% | 52.7% |
| **`citm_catalog.json`** (~1.6 MB) | 🥈 **316.5 MB/s** | 🥇 **338.6 MB/s** | 🥉 **225.7 MB/s** |
| ↳ *% of Winner* | 93.5% | **100.0%** | 66.6% |
| **`canada.json`** (~2.1 MB) | 🥉 **86.2 MB/s** | 🥈 **140.1 MB/s** | 🥇 **151.3 MB/s** |
| ↳ *% of Winner* | 56.9% | 92.6% | **100.0%** |
<!-- mdformat on -->

## ENCODE Throughput Matrix

Higher throughput (MB/s) is better. Medals (🥇, 🥈, 🥉) indicate top 3 performance per dataset.

<!-- mdformat off -->
| Dataset | Dart AOT (Stock std) | Dart AOT (std) | Dart AOT (package:codable) |
| :--- | :---: | :---: | :---: |
| **`small.json`** (~1 KB) | 🥈 **146.9 MB/s** | 🥉 **134.9 MB/s** | 🥇 **161.8 MB/s** |
| ↳ *% of Winner* | 90.8% | 83.3% | **100.0%** |
| **`twitter.json`** (~617 KB) | 🥉 **135.7 MB/s** | 🥇 **237.8 MB/s** | 🥈 **175.4 MB/s** |
| ↳ *% of Winner* | 57.1% | **100.0%** | 73.8% |
| **`citm_catalog.json`** (~1.6 MB) | 🥉 **262.6 MB/s** | 🥇 **434.1 MB/s** | 🥈 **324.5 MB/s** |
| ↳ *% of Winner* | 60.5% | **100.0%** | 74.8% |
| **`canada.json`** (~2.1 MB) | 🥉 **48.3 MB/s** | 🥇 **69.3 MB/s** | 🥈 **59.2 MB/s** |
| ↳ *% of Winner* | 69.7% | **100.0%** | 85.5% |
<!-- mdformat on -->

