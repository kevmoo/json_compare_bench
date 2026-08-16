# Benchmark Results

* **Run Date**: `2026-08-16T14:38:40.887858Z`
* **System**: linux (Linux 6.18.14-1rodete4-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.18.14-1rodete4 (2026-06-15)) | x86_64
* **Hardware**: AMD EPYC 7B13 (64 logical cores) | RAM: 117.9 GB
* **Toolchains & Packages**:
  * **Dart (Custom SDK)**: `Dart SDK version: 3.14.0-edge.a607b20defb73507130146a45984a1a7985c738e (main) (Sat Aug 15 20:01:47 2026 +0000) on "linux_x64"`
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

<!-- mdformat off -->
| Dataset | Dart AOT (std) | Dart AOT (package:codable) |
| :--- | :---: | :---: |
| **`small.json`** (~1 KB) | 🥇 **234.7 MB/s** | 🥈 **117.1 MB/s** |
| ↳ *% of Winner* | **100.0%** | 49.9% |
| **`twitter.json`** (~617 KB) | 🥇 **232.9 MB/s** | 🥈 **118.1 MB/s** |
| ↳ *% of Winner* | **100.0%** | 50.7% |
| **`citm_catalog.json`** (~1.6 MB) | 🥇 **341.6 MB/s** | 🥈 **216.4 MB/s** |
| ↳ *% of Winner* | **100.0%** | 63.4% |
| **`canada.json`** (~2.1 MB) | 🥈 **140.7 MB/s** | 🥇 **152.2 MB/s** |
| ↳ *% of Winner* | 92.4% | **100.0%** |
<!-- mdformat on -->

## ENCODE Throughput Matrix

Higher throughput (MB/s) is better. Medals (🥇, 🥈, 🥉) indicate top 3 performance per dataset.

<!-- mdformat off -->
| Dataset | Dart AOT (std) | Dart AOT (package:codable) |
| :--- | :---: | :---: |
| **`small.json`** (~1 KB) | 🥈 **139.3 MB/s** | 🥇 **275.8 MB/s** |
| ↳ *% of Winner* | 50.5% | **100.0%** |
| **`twitter.json`** (~617 KB) | 🥈 **247.8 MB/s** | 🥇 **348.5 MB/s** |
| ↳ *% of Winner* | 71.1% | **100.0%** |
| **`citm_catalog.json`** (~1.6 MB) | 🥈 **408.8 MB/s** | 🥇 **542.7 MB/s** |
| ↳ *% of Winner* | 75.3% | **100.0%** |
| **`canada.json`** (~2.1 MB) | 🥈 **68.4 MB/s** | 🥇 **73.1 MB/s** |
| ↳ *% of Winner* | 93.5% | **100.0%** |
<!-- mdformat on -->

