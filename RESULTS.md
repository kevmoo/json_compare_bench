# Cross-Language JSON Serialization Benchmark Results

* **Run Date**: `2026-09-19T00:08:57.889191Z`
* **System**: linux (Linux 7.1.6-1rodete1-amd64 #1 SMP PREEMPT_DYNAMIC Debian 7.1.6-1rodete1 (2026-08-05)) | x86_64
* **Hardware**: AMD EPYC 7B13 (64 logical cores) | RAM: 117.9 GB
* **Toolchains & Packages**:
  * **New Dart (Custom SDK)**: `Dart SDK version: 3.14.0-edge.8045fcd2294b259f9a87e5abd1986c954a0ffbe0 (main) (Sat Sep 12 19:08:49 2026 -0700) on "linux_x64"`
    * `codable`: `package:codable (SDK Layer 1 native substrate)`
    * `json_serializable`: `package:json_serializable (Typed fromJson/toJson)`
    * `convert`: `dart:convert (Untyped Map/DOM)`
  * **Stock Dart (Baseline SDK)**: `Dart SDK version: 3.14.0-edge.5237faee608e57dd1d8481289e6683bd83700d73 (main) (Wed Sep 9 15:51:44 2026 -0700) on "linux_x64"`
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
| **`small.json`** (546 B) | 🥇 **419.1 MB/s (1.24 µs)** | 63.2 MB/s (8.24 µs) | 🥉 **178.0 MB/s (2.93 µs)** | 🥈 **179.4 MB/s (2.90 µs)** | 171.3 MB/s (3.04 µs) | **0.96x** | **2.71x** |
| **`twitter.json`** (616.7 KB) | 🥇 **455.7 MB/s (1.32 ms)** | 90.4 MB/s (6.67 ms) | 🥈 **202.5 MB/s (2.97 ms)** | 🥉 **194.9 MB/s (3.09 ms)** | 178.3 MB/s (3.38 ms) | **0.88x** | **1.97x** |
| **`citm_catalog.json`** (1.65 MB) | 🥇 **745.1 MB/s (2.21 ms)** | 81.8 MB/s (20.14 ms) | 🥉 **284.7 MB/s (5.79 ms)** | 281.9 MB/s (5.84 ms) | 🥈 **380.6 MB/s (4.33 ms)** | **1.34x** | **4.65x** |
| **`canada.json`** (2.15 MB) | 🥇 **416.1 MB/s (5.16 ms)** | 46.5 MB/s (46.12 ms) | 62.6 MB/s (34.29 ms) | 🥉 **81.3 MB/s (26.40 ms)** | 🥈 **193.6 MB/s (11.09 ms)** | **3.09x** | **4.16x** |
<!-- mdformat on -->

## 1.2 ENCODE — Apples-to-Apples Typed Struct Matrix

Strongly-typed domain model serialization (Typed Structs -> UTF-8 bytes). Each cell displays **Throughput (`MiB/s`)** and **Single-Pass Latency (`ms`/`µs`)**. Medals (🥇, 🥈, 🥉) rank the top 3 typed struct contenders per dataset.

<!-- mdformat off -->
| Dataset | Rust (`serde_json` Typed) | Go (`encoding/json` Typed) | Stock Dart + `json_serializable` (Typed) | New Dart + `json_serializable` (Typed) | New Dart + `package:codable` (Typed) | `codable` vs Stock `json_serializable` | `codable` vs Go `encoding/json` |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **`small.json`** (546 B) | 🥇 **927.8 MB/s (561 ns)** | 🥈 **392.9 MB/s (1.33 µs)** | 109.8 MB/s (4.74 µs) | 93.0 MB/s (5.60 µs) | 🥉 **313.0 MB/s (1.66 µs)** | **2.85x** | **0.80x** |
| **`twitter.json`** (616.7 KB) | 🥇 **1259.6 MB/s (478.13 µs)** | 🥈 **724.2 MB/s (831.63 µs)** | 113.5 MB/s (5.31 ms) | 201.5 MB/s (2.99 ms) | 🥉 **389.8 MB/s (1.54 ms)** | **3.44x** | **0.54x** |
| **`citm_catalog.json`** (1.65 MB) | 🥇 **2817.3 MB/s (584.66 µs)** | 🥈 **1290.4 MB/s (1.28 ms)** | 197.6 MB/s (8.34 ms) | 287.8 MB/s (5.72 ms) | 🥉 **579.9 MB/s (2.84 ms)** | **2.94x** | **0.45x** |
| **`canada.json`** (2.15 MB) | 🥇 **686.0 MB/s (3.13 ms)** | 🥈 **158.0 MB/s (13.59 ms)** | 47.0 MB/s (45.72 ms) | 🥉 **99.2 MB/s (21.64 ms)** | 89.6 MB/s (23.97 ms) | **1.91x** | **0.57x** |
<!-- mdformat on -->

## 2.1 DECODE — Complete Cross-Language Matrix (Typed Structs + Untyped DOM)

Includes both **Typed Struct** contenders (`Rust`, `Go`, `Dart json_serializable`, `Dart package:codable`) and **Untyped DOM** parsers (`Node.js V8 [Untyped JS Object]`, `Stock/New Dart std_convert [Untyped Map/DOM]`). Medals (🥇, 🥈, 🥉) indicate top 3 raw throughput across all 8 columns.

<!-- mdformat off -->
| Dataset | Rust (`serde_json` Typed) | Go (`encoding/json` Typed) | Node.js V8 (`Untyped JS Object`) | Stock Dart + `json_serializable` (`Typed`) | New Dart + `json_serializable` (`Typed`) | New Dart + `package:codable` (`Typed`) | Stock Dart `std_convert` (`Untyped Map/DOM`) | New Dart `std_convert` (`Untyped Map/DOM`) |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **`small.json`** (546 B) | 🥇 **419.1 MB/s (1.24 µs)** | 63.2 MB/s (8.24 µs) | 🥈 **253.8 MB/s (2.05 µs)** | 178.0 MB/s (2.93 µs) | 179.4 MB/s (2.90 µs) | 171.3 MB/s (3.04 µs) | 🥉 **210.8 MB/s (2.47 µs)** | 208.6 MB/s (2.50 µs) |
| ↳ *% of Winner* | **100.0%** | 15.1% | 60.6% | 42.5% | 42.8% | 40.9% | 50.3% | 49.8% |
| **`twitter.json`** (616.7 KB) | 🥇 **455.7 MB/s (1.32 ms)** | 90.4 MB/s (6.67 ms) | 🥈 **434.6 MB/s (1.39 ms)** | 202.5 MB/s (2.97 ms) | 194.9 MB/s (3.09 ms) | 178.3 MB/s (3.38 ms) | 217.5 MB/s (2.77 ms) | 🥉 **221.8 MB/s (2.72 ms)** |
| ↳ *% of Winner* | **100.0%** | 19.8% | 95.4% | 44.4% | 42.8% | 39.1% | 47.7% | 48.7% |
| **`citm_catalog.json`** (1.65 MB) | 🥇 **745.1 MB/s (2.21 ms)** | 81.8 MB/s (20.14 ms) | 🥈 **479.5 MB/s (3.43 ms)** | 284.7 MB/s (5.79 ms) | 281.9 MB/s (5.84 ms) | 🥉 **380.6 MB/s (4.33 ms)** | 309.8 MB/s (5.32 ms) | 332.4 MB/s (4.96 ms) |
| ↳ *% of Winner* | **100.0%** | 11.0% | 64.4% | 38.2% | 37.8% | 51.1% | 41.6% | 44.6% |
| **`canada.json`** (2.15 MB) | 🥇 **416.1 MB/s (5.16 ms)** | 46.5 MB/s (46.12 ms) | 🥈 **225.6 MB/s (9.51 ms)** | 62.6 MB/s (34.29 ms) | 81.3 MB/s (26.40 ms) | 🥉 **193.6 MB/s (11.09 ms)** | 84.6 MB/s (25.36 ms) | 136.8 MB/s (15.69 ms) |
| ↳ *% of Winner* | **100.0%** | 11.2% | 54.2% | 15.0% | 19.5% | 46.5% | 20.3% | 32.9% |
<!-- mdformat on -->

## 2.2 ENCODE — Complete Cross-Language Matrix (Typed Structs + Untyped DOM)

Includes both **Typed Struct** contenders (`Rust`, `Go`, `Dart json_serializable`, `Dart package:codable`) and **Untyped DOM** parsers (`Node.js V8 [Untyped JS Object]`, `Stock/New Dart std_convert [Untyped Map/DOM]`). Medals (🥇, 🥈, 🥉) indicate top 3 raw throughput across all 8 columns.

<!-- mdformat off -->
| Dataset | Rust (`serde_json` Typed) | Go (`encoding/json` Typed) | Node.js V8 (`Untyped JS Object`) | Stock Dart + `json_serializable` (`Typed`) | New Dart + `json_serializable` (`Typed`) | New Dart + `package:codable` (`Typed`) | Stock Dart `std_convert` (`Untyped Map/DOM`) | New Dart `std_convert` (`Untyped Map/DOM`) |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **`small.json`** (546 B) | 🥇 **927.8 MB/s (561 ns)** | 🥈 **392.9 MB/s (1.33 µs)** | 🥉 **352.7 MB/s (1.48 µs)** | 109.8 MB/s (4.74 µs) | 93.0 MB/s (5.60 µs) | 313.0 MB/s (1.66 µs) | 114.1 MB/s (4.57 µs) | 116.2 MB/s (4.48 µs) |
| ↳ *% of Winner* | **100.0%** | 42.3% | 38.0% | 11.8% | 10.0% | 33.7% | 12.3% | 12.5% |
| **`twitter.json`** (616.7 KB) | 🥇 **1259.6 MB/s (478.13 µs)** | 🥈 **724.2 MB/s (831.63 µs)** | 356.3 MB/s (1.69 ms) | 113.5 MB/s (5.31 ms) | 201.5 MB/s (2.99 ms) | 🥉 **389.8 MB/s (1.54 ms)** | 115.8 MB/s (5.20 ms) | 255.2 MB/s (2.36 ms) |
| ↳ *% of Winner* | **100.0%** | 57.5% | 28.3% | 9.0% | 16.0% | 30.9% | 9.2% | 20.3% |
| **`citm_catalog.json`** (1.65 MB) | 🥇 **2817.3 MB/s (584.66 µs)** | 🥈 **1290.4 MB/s (1.28 ms)** | 501.2 MB/s (3.29 ms) | 197.6 MB/s (8.34 ms) | 287.8 MB/s (5.72 ms) | 🥉 **579.9 MB/s (2.84 ms)** | 227.4 MB/s (7.24 ms) | 433.1 MB/s (3.80 ms) |
| ↳ *% of Winner* | **100.0%** | 45.8% | 17.8% | 7.0% | 10.2% | 20.6% | 8.1% | 15.4% |
| **`canada.json`** (2.15 MB) | 🥇 **686.0 MB/s (3.13 ms)** | 🥈 **158.0 MB/s (13.59 ms)** | 🥉 **131.2 MB/s (16.36 ms)** | 47.0 MB/s (45.72 ms) | 99.2 MB/s (21.64 ms) | 89.6 MB/s (23.97 ms) | 46.2 MB/s (46.48 ms) | 97.9 MB/s (21.92 ms) |
| ↳ *% of Winner* | **100.0%** | 23.0% | 19.1% | 6.8% | 14.5% | 13.1% | 6.7% | 14.3% |
<!-- mdformat on -->

