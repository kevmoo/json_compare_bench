# Cross-Language JSON Serialization Benchmark Results

* **Run Date**: `2026-09-18T21:06:38.118563Z`
* **System**: linux (Linux 7.1.6-1rodete1-amd64 #1 SMP PREEMPT_DYNAMIC Debian 7.1.6-1rodete1 (2026-08-05)) | x86_64
* **Hardware**: AMD EPYC 7B13 (64 logical cores) | RAM: 117.9 GB
* **Toolchains & Packages**:
  * **New Dart (Custom SDK)**: `Dart SDK version: 3.14.0-edge.8045fcd2294b259f9a87e5abd1986c954a0ffbe0 (main) (Sat Sep 12 19:08:49 2026 -0700) on "linux_x64"`
    * `codable`: `package:codable (SDK Layer 1 native substrate)`
    * `json_serializable`: `package:json_serializable (Typed fromJson/toJson)`
    * `convert`: `dart:convert (Untyped Map/DOM)`
  * **Stock Dart (Baseline SDK)**: `Dart SDK version: 3.14.0-241.0.dev (dev) (Thu Sep 17 17:06:19 2026 -0700) on "linux_x64"`
    * `json_serializable`: `package:json_serializable (Typed fromJson/toJson)`
    * `convert`: `Standard Library (Untyped Map/DOM)`
  * **Rust**: `rustc 1.97.1 (8bab26f4f 2026-07-14)`
    * `serde_json`: `1.0.151`
    * `serde`: `1.0.229`
    * `mimalloc`: `0.1.52 (global allocator)`
  * **Go**: `go version go1.25.14 linux/amd64`
    * `encoding/json`: `Standard Library`
  * **Node.js**: `v24.21.0 (V8 13.6.233.17-node.53)`
    * `v8_builtin`: `V8 C++ Built-in (Untyped JS Object)`

> [!IMPORTANT]
> **Typed Struct Serialization vs. Untyped DOM Parsing**:
> * **Typed Struct Serialization (`Rust serde_json`, `Go encoding/json`, `Stock Dart + json_serializable`, `New Dart + json_serializable`, `New Dart + package:codable`)**: Deserializes raw UTF-8 bytes (`Uint8List` / `&[u8]` / `[]byte`) into strongly-typed domain model objects (`SmallDocument`, `TwitterResponse`, `CitmCatalog`, `CanadaFeatureCollection`) and serializes those strongly-typed models back to UTF-8 bytes.
> * **Untyped DOM Parsing (`Node.js V8`, `Stock Dart std_convert`, `New Dart std_convert`)**: Only parses UTF-8 bytes into an untyped dynamic AST (`Map<String, dynamic>` in Dart or raw V8 JS `Object` in Node.js), completely skipping typed `.fromJson(...)` / `.toJson()` model hydration and validation.
> * **`New Dart + package:codable`**: Uses single-pass streaming pull/push readers/writers (`JsonCodableDecoder.fromBytes` / `JsonCodableEncoder.toBytes`) backed by the native `dart:convert` Layer 1 UTF-8 token substrate, bypassing intermediate `Map<String, dynamic>` AST allocation entirely.

## 1.1 DECODE — Apples-to-Apples Typed Struct Matrix

Strongly-typed domain model deserialization (UTF-8 bytes -> Typed Structs). Each cell displays **Throughput (`MiB/s`)** and **Single-Pass Latency (`ms`/`µs`)**. Medals (🥇, 🥈, 🥉) rank the top 3 typed struct contenders per dataset.

<!-- mdformat off -->
| Dataset | Rust (`serde_json` Typed) | Go (`encoding/json` Typed) | Stock Dart + `json_serializable` (Typed) | New Dart + `json_serializable` (Typed) | New Dart + `package:codable` (Typed) | `codable` vs Stock `json_serializable` | `codable` vs Go `encoding/json` |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **`small.json`** (546 B) | 🥇 **383.4 MB/s (1.36 µs)** | 63.9 MB/s (8.15 µs) | 🥉 **174.0 MB/s (2.99 µs)** | 🥈 **177.9 MB/s (2.93 µs)** | 173.6 MB/s (3.00 µs) | **1.00x** | **2.72x** |
| **`twitter.json`** (616.7 KB) | 🥇 **465.9 MB/s (1.29 ms)** | 87.5 MB/s (6.88 ms) | 🥉 **195.6 MB/s (3.08 ms)** | 🥈 **204.8 MB/s (2.94 ms)** | 175.3 MB/s (3.44 ms) | **0.90x** | **2.00x** |
| **`citm_catalog.json`** (1.65 MB) | 🥇 **736.5 MB/s (2.24 ms)** | 83.3 MB/s (19.78 ms) | 🥉 **286.3 MB/s (5.75 ms)** | 274.8 MB/s (5.99 ms) | 🥈 **375.7 MB/s (4.38 ms)** | **1.31x** | **4.51x** |
| **`canada.json`** (2.15 MB) | 🥇 **436.9 MB/s (4.91 ms)** | 49.5 MB/s (43.40 ms) | 60.1 MB/s (35.72 ms) | 🥉 **78.0 MB/s (27.51 ms)** | 🥈 **190.8 MB/s (11.25 ms)** | **3.17x** | **3.86x** |
<!-- mdformat on -->

## 1.2 ENCODE — Apples-to-Apples Typed Struct Matrix

Strongly-typed domain model serialization (Typed Structs -> UTF-8 bytes). Each cell displays **Throughput (`MiB/s`)** and **Single-Pass Latency (`ms`/`µs`)**. Medals (🥇, 🥈, 🥉) rank the top 3 typed struct contenders per dataset.

<!-- mdformat off -->
| Dataset | Rust (`serde_json` Typed) | Go (`encoding/json` Typed) | Stock Dart + `json_serializable` (Typed) | New Dart + `json_serializable` (Typed) | New Dart + `package:codable` (Typed) | `codable` vs Stock `json_serializable` | `codable` vs Go `encoding/json` |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **`small.json`** (546 B) | 🥇 **940.2 MB/s (554 ns)** | 🥈 **398.1 MB/s (1.31 µs)** | 106.4 MB/s (4.89 µs) | 92.7 MB/s (5.62 µs) | 🥉 **297.1 MB/s (1.75 µs)** | **2.79x** | **0.75x** |
| **`twitter.json`** (616.7 KB) | 🥇 **1261.7 MB/s (477.34 µs)** | 🥈 **732.7 MB/s (821.99 µs)** | 114.0 MB/s (5.28 ms) | 188.6 MB/s (3.19 ms) | 🥉 **377.3 MB/s (1.60 ms)** | **3.31x** | **0.52x** |
| **`citm_catalog.json`** (1.65 MB) | 🥇 **2994.5 MB/s (550.09 µs)** | 🥈 **1291.5 MB/s (1.28 ms)** | 196.4 MB/s (8.39 ms) | 277.2 MB/s (5.94 ms) | 🥉 **594.2 MB/s (2.77 ms)** | **3.03x** | **0.46x** |
| **`canada.json`** (2.15 MB) | 🥇 **658.1 MB/s (3.26 ms)** | 🥈 **156.1 MB/s (13.75 ms)** | 48.5 MB/s (44.25 ms) | 🥉 **101.5 MB/s (21.15 ms)** | 88.3 MB/s (24.32 ms) | **1.82x** | **0.57x** |
<!-- mdformat on -->

## 2.1 DECODE — Complete Cross-Language Matrix (Typed Structs + Untyped DOM)

Includes both **Typed Struct** contenders (`Rust`, `Go`, `Dart json_serializable`, `Dart package:codable`) and **Untyped DOM** parsers (`Node.js V8 [Untyped JS Object]`, `Stock/New Dart std_convert [Untyped Map/DOM]`). Medals (🥇, 🥈, 🥉) indicate top 3 raw throughput across all 8 columns.

<!-- mdformat off -->
| Dataset | Rust (`serde_json` Typed) | Go (`encoding/json` Typed) | Node.js V8 (`Untyped JS Object`) | Stock Dart + `json_serializable` (`Typed`) | New Dart + `json_serializable` (`Typed`) | New Dart + `package:codable` (`Typed`) | Stock Dart `std_convert` (`Untyped Map/DOM`) | New Dart `std_convert` (`Untyped Map/DOM`) |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **`small.json`** (546 B) | 🥇 **383.4 MB/s (1.36 µs)** | 63.9 MB/s (8.15 µs) | 🥈 **257.6 MB/s (2.02 µs)** | 174.0 MB/s (2.99 µs) | 177.9 MB/s (2.93 µs) | 173.6 MB/s (3.00 µs) | 204.5 MB/s (2.55 µs) | 🥉 **216.2 MB/s (2.41 µs)** |
| ↳ *% of Winner* | **100.0%** | 16.7% | 67.2% | 45.4% | 46.4% | 45.3% | 53.3% | 56.4% |
| **`twitter.json`** (616.7 KB) | 🥇 **465.9 MB/s (1.29 ms)** | 87.5 MB/s (6.88 ms) | 🥈 **421.1 MB/s (1.43 ms)** | 195.6 MB/s (3.08 ms) | 204.8 MB/s (2.94 ms) | 175.3 MB/s (3.44 ms) | 🥉 **235.8 MB/s (2.55 ms)** | 229.3 MB/s (2.63 ms) |
| ↳ *% of Winner* | **100.0%** | 18.8% | 90.4% | 42.0% | 44.0% | 37.6% | 50.6% | 49.2% |
| **`citm_catalog.json`** (1.65 MB) | 🥇 **736.5 MB/s (2.24 ms)** | 83.3 MB/s (19.78 ms) | 🥈 **476.3 MB/s (3.46 ms)** | 286.3 MB/s (5.75 ms) | 274.8 MB/s (5.99 ms) | 🥉 **375.7 MB/s (4.38 ms)** | 321.9 MB/s (5.12 ms) | 329.9 MB/s (4.99 ms) |
| ↳ *% of Winner* | **100.0%** | 11.3% | 64.7% | 38.9% | 37.3% | 51.0% | 43.7% | 44.8% |
| **`canada.json`** (2.15 MB) | 🥇 **436.9 MB/s (4.91 ms)** | 49.5 MB/s (43.40 ms) | 🥈 **227.8 MB/s (9.42 ms)** | 60.1 MB/s (35.72 ms) | 78.0 MB/s (27.51 ms) | 🥉 **190.8 MB/s (11.25 ms)** | 81.4 MB/s (26.37 ms) | 139.4 MB/s (15.40 ms) |
| ↳ *% of Winner* | **100.0%** | 11.3% | 52.1% | 13.8% | 17.9% | 43.7% | 18.6% | 31.9% |
<!-- mdformat on -->

## 2.2 ENCODE — Complete Cross-Language Matrix (Typed Structs + Untyped DOM)

Includes both **Typed Struct** contenders (`Rust`, `Go`, `Dart json_serializable`, `Dart package:codable`) and **Untyped DOM** parsers (`Node.js V8 [Untyped JS Object]`, `Stock/New Dart std_convert [Untyped Map/DOM]`). Medals (🥇, 🥈, 🥉) indicate top 3 raw throughput across all 8 columns.

<!-- mdformat off -->
| Dataset | Rust (`serde_json` Typed) | Go (`encoding/json` Typed) | Node.js V8 (`Untyped JS Object`) | Stock Dart + `json_serializable` (`Typed`) | New Dart + `json_serializable` (`Typed`) | New Dart + `package:codable` (`Typed`) | Stock Dart `std_convert` (`Untyped Map/DOM`) | New Dart `std_convert` (`Untyped Map/DOM`) |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **`small.json`** (546 B) | 🥇 **940.2 MB/s (554 ns)** | 🥈 **398.1 MB/s (1.31 µs)** | 🥉 **349.3 MB/s (1.49 µs)** | 106.4 MB/s (4.89 µs) | 92.7 MB/s (5.62 µs) | 297.1 MB/s (1.75 µs) | 141.6 MB/s (3.68 µs) | 117.1 MB/s (4.45 µs) |
| ↳ *% of Winner* | **100.0%** | 42.3% | 37.1% | 11.3% | 9.9% | 31.6% | 15.1% | 12.5% |
| **`twitter.json`** (616.7 KB) | 🥇 **1261.7 MB/s (477.34 µs)** | 🥈 **732.7 MB/s (821.99 µs)** | 353.1 MB/s (1.71 ms) | 114.0 MB/s (5.28 ms) | 188.6 MB/s (3.19 ms) | 🥉 **377.3 MB/s (1.60 ms)** | 129.5 MB/s (4.65 ms) | 249.8 MB/s (2.41 ms) |
| ↳ *% of Winner* | **100.0%** | 58.1% | 28.0% | 9.0% | 14.9% | 29.9% | 10.3% | 19.8% |
| **`citm_catalog.json`** (1.65 MB) | 🥇 **2994.5 MB/s (550.09 µs)** | 🥈 **1291.5 MB/s (1.28 ms)** | 502.8 MB/s (3.28 ms) | 196.4 MB/s (8.39 ms) | 277.2 MB/s (5.94 ms) | 🥉 **594.2 MB/s (2.77 ms)** | 262.3 MB/s (6.28 ms) | 421.7 MB/s (3.91 ms) |
| ↳ *% of Winner* | **100.0%** | 43.1% | 16.8% | 6.6% | 9.3% | 19.8% | 8.8% | 14.1% |
| **`canada.json`** (2.15 MB) | 🥇 **658.1 MB/s (3.26 ms)** | 🥈 **156.1 MB/s (13.75 ms)** | 🥉 **122.6 MB/s (17.51 ms)** | 48.5 MB/s (44.25 ms) | 101.5 MB/s (21.15 ms) | 88.3 MB/s (24.32 ms) | 47.7 MB/s (44.98 ms) | 97.8 MB/s (21.95 ms) |
| ↳ *% of Winner* | **100.0%** | 23.7% | 18.6% | 7.4% | 15.4% | 13.4% | 7.3% | 14.9% |
<!-- mdformat on -->

