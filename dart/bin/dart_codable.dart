// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:codable/codable.dart';

import 'package:json_compare_bench_dart/src/models/canada.dart';
import 'package:json_compare_bench_dart/src/models/citm_catalog.dart';
import 'package:json_compare_bench_dart/src/models/small.dart';
import 'package:json_compare_bench_dart/src/models/twitter.dart';

int blackholeSink = 0;

@pragma('vm:never-inline')
void consumeBlackBox(Object? value) {
  blackholeSink ^= value.hashCode;
}

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addOption(
      'dataset',
      abbr: 'd',
      mandatory: true,
      help: 'Path to JSON dataset file',
    )
    ..addOption(
      'mode',
      abbr: 'm',
      defaultsTo: 'decode',
      allowed: ['decode', 'encode'],
      help: 'Benchmark mode',
    )
    ..addOption(
      'impl',
      abbr: 'i',
      defaultsTo: 'codable',
      help: 'Implementation name in output',
    )
    ..addOption(
      'iterations',
      abbr: 'n',
      defaultsTo: '100',
      help: 'Number of measured iterations',
    )
    ..addOption(
      'warmup',
      abbr: 'w',
      defaultsTo: '10',
      help: 'Number of warmup iterations',
    );

  final results = parser.parse(arguments);
  final datasetPath = results['dataset'] as String;
  final mode = results['mode'] as String;
  final implName = results['impl'] as String;
  final iterations = int.parse(results['iterations'] as String);
  final warmup = int.parse(results['warmup'] as String);

  final file = File(datasetPath);
  if (!file.existsSync()) {
    stderr.writeln('Dataset file not found: $datasetPath');
    exit(1);
  }

  final bytes = file.readAsBytesSync();
  final datasetName = datasetPath.split('/').last;

  runBenchmark(
    datasetName: datasetName,
    bytes: bytes,
    mode: mode,
    impl: implName,
    iterations: iterations,
    warmup: warmup,
  );
}

void runBenchmark({
  required String datasetName,
  required Uint8List bytes,
  required String mode,
  required String impl,
  required int iterations,
  required int warmup,
}) {
  // Pre-decode model for encode benchmarks
  Object? predecodedModel;
  if (datasetName.contains('small')) {
    predecodedModel = SmallDocument.fromReader(
      JsonTokenReader.fromBytes(bytes),
    );
  } else if (datasetName.contains('twitter')) {
    predecodedModel = TwitterResponse.fromReader(
      JsonTokenReader.fromBytes(bytes),
    );
  } else if (datasetName.contains('citm')) {
    predecodedModel = CitmCatalog.fromReader(JsonTokenReader.fromBytes(bytes));
  } else if (datasetName.contains('canada')) {
    predecodedModel = CanadaFeatureCollection.fromReader(
      JsonTokenReader.fromBytes(bytes),
    );
  }

  void runDecodePass() {
    if (datasetName.contains('small')) {
      final reader = JsonTokenReader.fromBytes(bytes);
      final res = SmallDocument.fromReader(reader);
      consumeBlackBox(res);
    } else if (datasetName.contains('twitter')) {
      final reader = JsonTokenReader.fromBytes(bytes);
      final res = TwitterResponse.fromReader(reader);
      consumeBlackBox(res);
    } else if (datasetName.contains('citm')) {
      final reader = JsonTokenReader.fromBytes(bytes);
      final res = CitmCatalog.fromReader(reader);
      consumeBlackBox(res);
    } else if (datasetName.contains('canada')) {
      final reader = JsonTokenReader.fromBytes(bytes);
      final res = CanadaFeatureCollection.fromReader(reader);
      consumeBlackBox(res);
    } else {
      throw UnsupportedError('Unsupported dataset: $datasetName');
    }
  }

  void runEncodePass() {
    final builder = BytesBuilder();
    final writer = JsonTokenWriter.toSink(builder);
    if (predecodedModel is SmallDocument) {
      predecodedModel.toWriter(writer);
    } else if (predecodedModel is TwitterResponse) {
      predecodedModel.toWriter(writer);
    } else if (predecodedModel is CitmCatalog) {
      predecodedModel.toWriter(writer);
    } else if (predecodedModel is CanadaFeatureCollection) {
      predecodedModel.toWriter(writer);
    } else {
      throw UnsupportedError('Unsupported dataset: $datasetName');
    }
    final out = builder.toBytes();
    consumeBlackBox(out);
  }

  final runPass = mode == 'decode' ? runDecodePass : runEncodePass;

  // Warmup
  for (var i = 0; i < warmup; i++) {
    runPass();
  }

  // Measured run
  final stopwatch = Stopwatch()..start();
  for (var i = 0; i < iterations; i++) {
    runPass();
  }
  stopwatch.stop();

  final elapsedMicros = stopwatch.elapsedMicroseconds;
  final elapsedNs = elapsedMicros * 1000;
  final totalBytes = bytes.length * iterations;
  final throughputMbPerSec =
      (totalBytes / (1024 * 1024)) / (elapsedMicros / 1000000.0);
  final nsPerOp = elapsedNs ~/ iterations;

  final output = {
    'language': 'dart',
    'implementation': impl,
    'dataset': datasetName,
    'mode': mode,
    'iterations': iterations,
    'file_bytes': bytes.length,
    'total_bytes': totalBytes,
    'elapsed_ns': elapsedNs,
    'throughput_mb_s': double.parse(throughputMbPerSec.toStringAsFixed(2)),
    'ns_per_op': nsPerOp,
  };

  print(jsonEncode(output));
}
