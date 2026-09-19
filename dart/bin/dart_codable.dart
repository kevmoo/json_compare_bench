// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:codable/codable_json.dart';

import 'package:json_compare_bench_dart/src/models/canada.dart';
import 'package:json_compare_bench_dart/src/models/citm_catalog.dart';
import 'package:json_compare_bench_dart/src/models/small.dart';
import 'package:json_compare_bench_dart/src/models/twitter.dart';

@pragma('vm:entry-point')
Object? blackholeSink;

@pragma('vm:never-inline')
void consumeBlackBox(Object? value) {
  blackholeSink = value;
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
  late final void Function() runPass;

  if (mode == 'decode') {
    if (datasetName.contains('small')) {
      runPass = () {
        consumeBlackBox(
          SmallDocument.decode(JsonCodableDecoder.fromBytes(bytes)),
        );
      };
    } else if (datasetName.contains('twitter')) {
      runPass = () {
        consumeBlackBox(
          TwitterResponse.decode(JsonCodableDecoder.fromBytes(bytes)),
        );
      };
    } else if (datasetName.contains('citm')) {
      runPass = () {
        consumeBlackBox(
          CitmCatalog.decode(JsonCodableDecoder.fromBytes(bytes)),
        );
      };
    } else if (datasetName.contains('canada')) {
      runPass = () {
        consumeBlackBox(
          CanadaFeatureCollection.decode(JsonCodableDecoder.fromBytes(bytes)),
        );
      };
    } else {
      throw UnsupportedError('Unsupported dataset: $datasetName');
    }
  } else {
    late final void Function(Encoder) encodeFn;
    if (datasetName.contains('small')) {
      final m = SmallDocument.decode(JsonCodableDecoder.fromBytes(bytes));
      encodeFn = m.encode;
    } else if (datasetName.contains('twitter')) {
      final m = TwitterResponse.decode(JsonCodableDecoder.fromBytes(bytes));
      encodeFn = m.encode;
    } else if (datasetName.contains('citm')) {
      final m = CitmCatalog.decode(JsonCodableDecoder.fromBytes(bytes));
      encodeFn = m.encode;
    } else if (datasetName.contains('canada')) {
      final m = CanadaFeatureCollection.decode(
        JsonCodableDecoder.fromBytes(bytes),
      );
      encodeFn = m.encode;
    } else {
      throw UnsupportedError('Unsupported dataset: $datasetName');
    }
    runPass = () {
      consumeBlackBox(JsonCodableEncoder.toBytes(encodeFn));
    };
  }

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

  if (identical(blackholeSink, Object())) {
    stderr.writeln(blackholeSink);
  }

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
