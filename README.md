# JSON Compare Bench (`json_compare_bench`)

A reproducible, multi-language JSON serialization and deserialization benchmark suite comparing **Dart**, **Rust**, **Go**, and **Node.js** under identical hardware and payload conditions.

## Standard Datasets

- `data/small.json` (~1 KB): Baseline user profile & metadata object.
- `data/twitter.json` (~617 KB): Real-world UTF-8 social timeline payload with nested objects and arrays.
- `data/citm_catalog.json` (~1.7 MB): Complex catalog schema with dense dictionary keys and repeated identifiers.
- `data/canada.json` (~2.2 MB): Deeply nested GeoJSON floating-point coordinate arrays.

## Target Implementations

- **Dart**:
  - `dart:convert` (JIT and AOT Native)
  - `package:json_serializable` (Typed Part File Code-gen)
  - `json_rw` (Streaming Pull Reader & Push Writer Prototype)
- **Rust**:
  - `serde_json` (Standard typed and value parsing)
  - `simd-json` (SIMD-accelerated parser)
- **Go**:
  - `encoding/json` (Standard library reflection)
  - `easyjson` (Fast code-generated lexer/parser)
- **Node.js**:
  - `JSON.parse` / `JSON.stringify` (V8 C++ built-ins on Node 24)
  - `fast-json-stringify` (Schema-compiled serializer)

## Running Benchmarks

```bash
~/github/flutter/bin/dart run tool/run_benchmarks.dart
```
