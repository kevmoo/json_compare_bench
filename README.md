# json_compare_bench

[![CI](https://github.com/kevmoo/json_compare_bench/actions/workflows/ci.yml/badge.svg)](https://github.com/kevmoo/json_compare_bench/actions/workflows/ci.yml)

A reproducible, cross-language JSON serialization and deserialization benchmark
suite comparing **Dart**, **Rust**, **Go**, and **Node.js** under identical
hardware and payload conditions.

---

## Latest Results

See the full, machine-harvested benchmark report with toolchain versions and
hardware configuration in [RESULTS.md](RESULTS.md).

Canonical benchmark runs are tracked in machine-readable format in
[results.json](results.json).

---

## Standard Datasets

All benchmarks run against the canonical, industry-standard JSON datasets
located in `data/`:

* `data/small.json` (~1 KB): Baseline user profile and metadata object.
* `data/twitter.json` (~617 KB): Real-world UTF-8 social timeline payload with
  nested objects and arrays.
* `data/citm_catalog.json` (~1.7 MB): Complex ticketing and event catalog schema
  with dense string dictionary keys and repeated identifiers.
* `data/canada.json` (~2.2 MB): Deeply nested GeoJSON floating-point coordinate
  arrays.

---

## Evaluated Runtimes & Implementations

All native compiled binaries evaluate direct **UTF-8 Byte Buffer I/O**
(`Uint8List` / `&[u8]` / `[]byte`), matching real-world production network
sockets, disk files, and database caches.

* **Dart (AOT)**:
  * `Dart AOT (std)`: Standard SDK fused JSON decoder and encoder
    (`utf8.decoder.fuse(json.decoder)` and `json.encoder.fuse(utf8.encoder)`)
    compiled to native machine code with `dart compile exe`.
  * `Dart AOT (json_rw)`: Streaming byte pull-reader and byte-builder
    push-writer prototype from
    [kevmoo/json_serializable.dart@c73ec8e](https://github.com/kevmoo/json_serializable.dart/tree/c73ec8e9a1e813a00b903205a39ec2c24a01b94b/json_rw).
* **Rust**:
  * `serde_json`: Release binary (`cargo build --release`) configured with
    `mimalloc` as the `#[global_allocator]` (industry standard for
    high-performance production Rust services), parsing `&[u8]` slices via
    `serde_json::from_slice` and emitting `Vec<u8>` via `serde_json::to_vec`.
* **Go**:
  * `encoding/json`: Native binary parsing `[]byte` via `json.Unmarshal`
    and emitting `[]byte` via `json.Marshal`.
* **Node.js**:
  * `JSON.parse` / `JSON.stringify`: V8 C++ built-in parser executing on
    Node.js v24.

---

## Running Benchmarks

### Prerequisites

Ensure the following tools are available on your system `PATH`:
* **Dart SDK** (>= 3.9)
* **Rust / Cargo** (>= 1.80)
* **Go** (>= 1.22)
* **Node.js** (>= 22)

### Default Run

To build all native binaries, execute all benchmark suites across all datasets,
and regenerate [results.json](results.json) and [RESULTS.md](RESULTS.md):

```bash
dart run tool/run_benchmarks.dart
```

### Filtered Runs

Run a specific dataset or subset of languages:

```bash
# Benchmark only twitter.json on Dart and Rust in decode mode
dart run tool/run_benchmarks.dart -d twitter.json -l dart,rust -m decode

# Custom iteration and warmup counts
dart run tool/run_benchmarks.dart -d small.json -n 50000 -w 5000
```

### Reporting From JSON

Regenerate [RESULTS.md](RESULTS.md) from an existing
[results.json](results.json) without re-running benchmarks:

```bash
dart run tool/run_benchmarks.dart --from-json results.json
```

---

## Methodology & Metrics

* **Native Byte Buffer Contract**: Native binaries (Dart AOT, Rust, Go)
  benchmark direct UTF-8 byte serialization/deserialization (`Uint8List`,
  `&[u8]`, `[]byte`), eliminating intermediate UTF-16 string allocations.
* **Pre-loaded Payload**: Datasets are loaded into memory prior to timing to
  isolate JSON parsing/serialization from disk I/O.
* **Warmup Cycles**: Every runner executes un-timed warmup passes to ensure
  CPU cache warming and branch prediction readiness.
* **Throughput (MB/s)**:
  $$\text{Throughput} = \frac{\text{Dataset Size (MB)} \times \text{Iterations}}{\text{Elapsed Seconds}}$$
* **Relative Performance (% of Winner)**: Each dataset compares contenders
  against the fastest runtime on that payload ($100.0\%$).

