// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:args/args.dart';

import 'package:json_compare_bench_dart/src/models/json_serializable/canada.dart';
import 'package:json_compare_bench_dart/src/models/json_serializable/citm_catalog.dart';
import 'package:json_compare_bench_dart/src/models/json_serializable/small.dart';
import 'package:json_compare_bench_dart/src/models/json_serializable/twitter.dart';

final utf8JsonDecoder = utf8.decoder.fuse(json.decoder);
final utf8JsonEncoder = json.encoder.fuse(utf8.encoder);

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
      defaultsTo: 'json_serializable',
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
        final ast = utf8JsonDecoder.convert(bytes) as Map<String, dynamic>;
        consumeBlackBox(SmallDocument.fromJson(ast));
      };
    } else if (datasetName.contains('twitter')) {
      runPass = () {
        final ast = utf8JsonDecoder.convert(bytes) as Map<String, dynamic>;
        consumeBlackBox(TwitterResponse.fromJson(ast));
      };
    } else if (datasetName.contains('citm')) {
      runPass = () {
        final ast = utf8JsonDecoder.convert(bytes) as Map<String, dynamic>;
        consumeBlackBox(CitmCatalog.fromJson(ast));
      };
    } else if (datasetName.contains('canada')) {
      runPass = () {
        final ast = utf8JsonDecoder.convert(bytes) as Map<String, dynamic>;
        consumeBlackBox(CanadaFeatureCollection.fromJson(ast));
      };
    } else {
      throw UnsupportedError('Unsupported dataset: $datasetName');
    }
  } else {
    final jsonAst = utf8JsonDecoder.convert(bytes) as Map<String, dynamic>;
    if (datasetName.contains('small')) {
      final m = SmallDocument.fromJson(jsonAst);
      runPass = () {
        consumeBlackBox(utf8JsonEncoder.convert(m.toJson()));
      };
    } else if (datasetName.contains('twitter')) {
      final m = TwitterResponse.fromJson(jsonAst);
      runPass = () {
        consumeBlackBox(utf8JsonEncoder.convert(m.toJson()));
      };
    } else if (datasetName.contains('citm')) {
      final m = CitmCatalog.fromJson(jsonAst);
      runPass = () {
        consumeBlackBox(utf8JsonEncoder.convert(m.toJson()));
      };
    } else if (datasetName.contains('canada')) {
      final m = CanadaFeatureCollection.fromJson(jsonAst);
      runPass = () {
        consumeBlackBox(utf8JsonEncoder.convert(m.toJson()));
      };
    } else {
      throw UnsupportedError('Unsupported dataset: $datasetName');
    }
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
