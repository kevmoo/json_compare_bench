# Cross-Language JSON Serialization Benchmark Results

* **Run Date**: `2026-09-20T03:33:23.138268Z`
* **System**: linux (Linux 7.0.11-200.fc44.x86_64 #1 SMP PREEMPT_DYNAMIC Mon Jun  1 22:50:37 UTC 2026) | x86_64
* **Hardware**: AMD Ryzen 9 PRO 8945HS w/ Radeon 780M Graphics (16 logical cores) | RAM: 30.1 GB
* **Toolchains & Packages**:
  * **New Dart (Custom SDK)**: `Dart SDK version: 3.14.0-json-next.e676935b72bd801c2fdec5188d1e4d8e69dcbf61 (main) (Sat Sep 19 16:14:26 2026 -0700) on "linux_x64"`
    * `codable`: `package:codable (SDK Layer 1 native substrate)`
    * `json_serializable`: `package:json_serializable (Typed fromJson/toJson)`
    * `convert`: `dart:convert (Untyped Map/DOM)`
  * **Stock Dart (Baseline SDK)**: `Dart SDK version: 3.14.0-248.0.dev (dev) (Sat Sep 19 01:09:06 2026 -0700) on "linux_x64"`
    * `json_serializable`: `package:json_serializable (Typed fromJson/toJson)`
    * `convert`: `Standard Library (Untyped Map/DOM)`
  * **Rust**: `rustc 1.98.1 (48a229cea 2026-09-01)`
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
| **`small.json`** (546 B) | 🥇 **773.2 MB/s (673 ns)** | 128.9 MB/s (4.04 µs) | 🥈 **331.5 MB/s (1.57 µs)** | 🥉 **330.2 MB/s (1.58 µs)** | 322.4 MB/s (1.61 µs) | **0.97x** [ 0.97x - 0.98x ] | **2.50x** [ 2.48x - 2.51x ] |
| **`twitter.json`** (616.7 KB) | 🥇 **1023.6 MB/s (588.36 µs)** | 171.3 MB/s (3.52 ms) | 🥈 **402.4 MB/s (1.50 ms)** | 🥉 **401.4 MB/s (1.50 ms)** | 331.5 MB/s (1.82 ms) | **0.82x** [ 0.82x - 0.82x ] | **1.94x** [ 1.92x - 1.94x ] |
| **`citm_catalog.json`** (1.65 MB) | 🥇 **1396.6 MB/s (1.18 ms)** | 150.4 MB/s (10.95 ms) | 464.4 MB/s (3.55 ms) | 🥉 **464.7 MB/s (3.54 ms)** | 🥈 **592.7 MB/s (2.78 ms)** | **1.28x** [ 1.27x - 1.28x ] | **3.94x** [ 3.89x - 4.03x ] |
| **`canada.json`** (2.15 MB) | 🥇 **804.8 MB/s (2.67 ms)** | 🥉 **98.1 MB/s (21.89 ms)** | 69.7 MB/s (30.78 ms) | 73.0 MB/s (29.40 ms) | 🥈 **267.0 MB/s (8.04 ms)** | **3.83x** [ 3.81x - 3.88x ] | **2.72x** [ 2.71x - 2.73x ] |
<!-- mdformat on -->

## 1.2 ENCODE — Apples-to-Apples Typed Struct Matrix

Strongly-typed domain model serialization (Typed Structs -> UTF-8 bytes). Each cell displays **Throughput (`MiB/s`)** and **Single-Pass Latency (`ms`/`µs`)**. Medals (🥇, 🥈, 🥉) rank the top 3 typed struct contenders per dataset.

<!-- mdformat off -->
| Dataset | Rust (`serde_json` Typed) | Go (`encoding/json` Typed) | Stock Dart + `json_serializable` (Typed) | New Dart + `json_serializable` (Typed) | New Dart + `package:codable` (Typed) | `codable` vs Stock `json_serializable` | `codable` vs Go `encoding/json` |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **`small.json`** (546 B) | 🥇 **1768.4 MB/s (294 ns)** | 🥈 **736.7 MB/s (707 ns)** | 180.2 MB/s (2.89 µs) | 320.2 MB/s (1.63 µs) | 🥉 **556.7 MB/s (935 ns)** | **3.09x** [ 3.05x - 3.11x ] | **0.76x** [ 0.75x - 0.76x ] |
| **`twitter.json`** (616.7 KB) | 🥇 **2888.1 MB/s (208.53 µs)** | 🥈 **1447.6 MB/s (416.05 µs)** | 201.3 MB/s (2.99 ms) | 385.7 MB/s (1.56 ms) | 🥉 **708.8 MB/s (849.74 µs)** | **3.52x** [ 3.49x - 3.55x ] | **0.49x** [ 0.49x - 0.49x ] |
| **`citm_catalog.json`** (1.65 MB) | 🥇 **5894.5 MB/s (279.44 µs)** | 🥈 **2374.9 MB/s (693.59 µs)** | 358.4 MB/s (4.60 ms) | 551.3 MB/s (2.99 ms) | 🥉 **1024.7 MB/s (1.61 ms)** | **2.86x** [ 2.81x - 2.88x ] | **0.43x** [ 0.42x - 0.43x ] |
| **`canada.json`** (2.15 MB) | 🥇 **1094.7 MB/s (1.96 ms)** | 🥈 **278.5 MB/s (7.71 ms)** | 76.3 MB/s (28.13 ms) | 🥉 **196.2 MB/s (10.94 ms)** | 161.2 MB/s (13.32 ms) | **2.11x** [ 2.07x - 2.11x ] | **0.58x** [ 0.58x - 0.58x ] |
<!-- mdformat on -->

## 2.1 DECODE — Complete Cross-Language Matrix (Typed Structs + Untyped DOM)

Includes both **Typed Struct** contenders (`Rust`, `Go`, `Dart json_serializable`, `Dart package:codable`) and **Untyped DOM** parsers (`Node.js V8 [Untyped JS Object]`, `Stock/New Dart std_convert [Untyped Map/DOM]`). Medals (🥇, 🥈, 🥉) indicate top 3 raw throughput across all 8 columns.

<!-- mdformat off -->
| Dataset | Rust (`serde_json` Typed) | Go (`encoding/json` Typed) | Node.js V8 (`Untyped JS Object`) | Stock Dart + `json_serializable` (`Typed`) | New Dart + `json_serializable` (`Typed`) | New Dart + `package:codable` (`Typed`) | Stock Dart `std_convert` (`Untyped Map/DOM`) | New Dart `std_convert` (`Untyped Map/DOM`) |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **`small.json`** (546 B) | 🥇 **773.2 MB/s (673 ns)** | 128.9 MB/s (4.04 µs) | 369.2 MB/s (1.41 µs) | 331.5 MB/s (1.57 µs) | 330.2 MB/s (1.58 µs) | 322.4 MB/s (1.61 µs) | 🥉 **406.6 MB/s (1.28 µs)** | 🥈 **408.6 MB/s (1.27 µs)** |
| ↳ *% of Winner* | **100.0%** | 16.7% | 47.7% | 42.9% | 42.7% | 41.7% | 52.6% | 52.8% |
| **`twitter.json`** (616.7 KB) | 🥇 **1023.6 MB/s (588.36 µs)** | 171.3 MB/s (3.52 ms) | 373.2 MB/s (1.61 ms) | 402.4 MB/s (1.50 ms) | 401.4 MB/s (1.50 ms) | 331.5 MB/s (1.82 ms) | 🥈 **459.8 MB/s (1.31 ms)** | 🥉 **456.3 MB/s (1.32 ms)** |
| ↳ *% of Winner* | **100.0%** | 16.7% | 36.5% | 39.3% | 39.2% | 32.4% | 44.9% | 44.6% |
| **`citm_catalog.json`** (1.65 MB) | 🥇 **1396.6 MB/s (1.18 ms)** | 150.4 MB/s (10.95 ms) | 471.1 MB/s (3.50 ms) | 464.4 MB/s (3.55 ms) | 464.7 MB/s (3.54 ms) | 🥈 **592.7 MB/s (2.78 ms)** | 513.5 MB/s (3.21 ms) | 🥉 **520.1 MB/s (3.17 ms)** |
| ↳ *% of Winner* | **100.0%** | 10.8% | 33.7% | 33.2% | 33.3% | 42.4% | 36.8% | 37.2% |
| **`canada.json`** (2.15 MB) | 🥇 **804.8 MB/s (2.67 ms)** | 98.1 MB/s (21.89 ms) | 🥈 **329.3 MB/s (6.52 ms)** | 69.7 MB/s (30.78 ms) | 73.0 MB/s (29.40 ms) | 🥉 **267.0 MB/s (8.04 ms)** | 104.7 MB/s (20.50 ms) | 193.1 MB/s (11.12 ms) |
| ↳ *% of Winner* | **100.0%** | 12.2% | 40.9% | 8.7% | 9.1% | 33.2% | 13.0% | 24.0% |
<!-- mdformat on -->

## 2.2 ENCODE — Complete Cross-Language Matrix (Typed Structs + Untyped DOM)

Includes both **Typed Struct** contenders (`Rust`, `Go`, `Dart json_serializable`, `Dart package:codable`) and **Untyped DOM** parsers (`Node.js V8 [Untyped JS Object]`, `Stock/New Dart std_convert [Untyped Map/DOM]`). Medals (🥇, 🥈, 🥉) indicate top 3 raw throughput across all 8 columns.

<!-- mdformat off -->
| Dataset | Rust (`serde_json` Typed) | Go (`encoding/json` Typed) | Node.js V8 (`Untyped JS Object`) | Stock Dart + `json_serializable` (`Typed`) | New Dart + `json_serializable` (`Typed`) | New Dart + `package:codable` (`Typed`) | Stock Dart `std_convert` (`Untyped Map/DOM`) | New Dart `std_convert` (`Untyped Map/DOM`) |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **`small.json`** (546 B) | 🥇 **1768.4 MB/s (294 ns)** | 🥈 **736.7 MB/s (707 ns)** | 476.7 MB/s (1.09 µs) | 180.2 MB/s (2.89 µs) | 320.2 MB/s (1.63 µs) | 🥉 **556.7 MB/s (935 ns)** | 231.9 MB/s (2.25 µs) | 486.0 MB/s (1.07 µs) |
| ↳ *% of Winner* | **100.0%** | 41.7% | 27.0% | 10.2% | 18.1% | 31.5% | 13.1% | 27.5% |
| **`twitter.json`** (616.7 KB) | 🥇 **2888.1 MB/s (208.53 µs)** | 🥈 **1447.6 MB/s (416.05 µs)** | 363.6 MB/s (1.66 ms) | 201.3 MB/s (2.99 ms) | 385.7 MB/s (1.56 ms) | 🥉 **708.8 MB/s (849.74 µs)** | 220.6 MB/s (2.73 ms) | 496.8 MB/s (1.21 ms) |
| ↳ *% of Winner* | **100.0%** | 50.1% | 12.6% | 7.0% | 13.4% | 24.5% | 7.6% | 17.2% |
| **`citm_catalog.json`** (1.65 MB) | 🥇 **5894.5 MB/s (279.44 µs)** | 🥈 **2374.9 MB/s (693.59 µs)** | 750.1 MB/s (2.20 ms) | 358.4 MB/s (4.60 ms) | 551.3 MB/s (2.99 ms) | 🥉 **1024.7 MB/s (1.61 ms)** | 446.2 MB/s (3.69 ms) | 782.2 MB/s (2.11 ms) |
| ↳ *% of Winner* | **100.0%** | 40.3% | 12.7% | 6.1% | 9.4% | 17.4% | 7.6% | 13.3% |
| **`canada.json`** (2.15 MB) | 🥇 **1094.7 MB/s (1.96 ms)** | 🥈 **278.5 MB/s (7.71 ms)** | 🥉 **245.8 MB/s (8.73 ms)** | 76.3 MB/s (28.13 ms) | 196.2 MB/s (10.94 ms) | 161.2 MB/s (13.32 ms) | 77.9 MB/s (27.57 ms) | 199.6 MB/s (10.76 ms) |
| ↳ *% of Winner* | **100.0%** | 25.4% | 22.5% | 7.0% | 17.9% | 14.7% | 7.1% | 18.2% |
<!-- mdformat on -->

