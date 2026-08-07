import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:args/args.dart';
import 'package:json_compare_bench_dart/json_rw.dart';

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
      defaultsTo: 'all',
      allowed: [
        'convert',
        'convert_utf8',
        'json_rw_string',
        'json_rw_utf8',
        'all',
      ],
      help: 'Implementation to benchmark',
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
  final implChoice = results['impl'] as String;
  final iterations = int.parse(results['iterations'] as String);
  final warmup = int.parse(results['warmup'] as String);

  final file = File(datasetPath);
  if (!file.existsSync()) {
    stderr.writeln('Dataset file not found: $datasetPath');
    exit(1);
  }

  final bytes = file.readAsBytesSync();
  final stringSource = utf8.decode(bytes);
  final datasetName = datasetPath.split('/').last;

  final implementations = <String>[];
  if (implChoice == 'all') {
    implementations.addAll([
      'convert',
      'convert_utf8',
      'json_rw_string',
      'json_rw_utf8',
    ]);
  } else {
    implementations.add(implChoice);
  }

  for (final impl in implementations) {
    runBenchmark(
      datasetName: datasetName,
      bytes: bytes,
      stringSource: stringSource,
      mode: mode,
      impl: impl,
      iterations: iterations,
      warmup: warmup,
    );
  }
}

void runBenchmark({
  required String datasetName,
  required Uint8List bytes,
  required String stringSource,
  required String mode,
  required String impl,
  required int iterations,
  required int warmup,
}) {
  // Pre-decode object for encode benchmarks
  final dynamic parsedObject = jsonDecode(stringSource);

  void runDecodePass() {
    switch (impl) {
      case 'convert':
        final res = jsonDecode(stringSource);
        if (res == null) throw StateError('null');
        break;
      case 'convert_utf8':
        final res = utf8.decoder.fuse(json.decoder).convert(bytes);
        if (res == null) throw StateError('null');
        break;
      case 'json_rw_string':
        final reader = JsonReader.fromString(stringSource);
        reader.skipValue();
        break;
      case 'json_rw_utf8':
        final reader = JsonReader.fromUtf8(bytes);
        reader.skipValue();
        break;
      default:
        throw UnsupportedError('Unknown impl: $impl');
    }
  }

  void runEncodePass() {
    switch (impl) {
      case 'convert':
        final res = jsonEncode(parsedObject);
        if (res.isEmpty) throw StateError('empty');
        break;
      case 'convert_utf8':
        final res = json.encoder.fuse(utf8.encoder).convert(parsedObject);
        if (res.isEmpty) throw StateError('empty');
        break;
      case 'json_rw_string':
        final buffer = StringBuffer();
        final writer = JsonWriter(buffer);
        _writeDynamic(writer, parsedObject);
        final res = buffer.toString();
        if (res.isEmpty) throw StateError('empty');
        break;
      case 'json_rw_utf8':
        final builder = BytesBuilder(copy: false);
        final writer = JsonWriter.bytes(builder);
        _writeDynamic(writer, parsedObject);
        final res = builder.toBytes();
        if (res.isEmpty) throw StateError('empty');
        break;
      default:
        throw UnsupportedError('Unknown impl: $impl');
    }
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

void _writeDynamic(JsonWriter writer, dynamic value) {
  if (value == null) {
    writer.writeNull();
  } else if (value is bool) {
    writer.writeBool(value);
  } else if (value is num) {
    writer.writeNumber(value);
  } else if (value is String) {
    writer.writeString(value);
  } else if (value is List) {
    writer.beginArray();
    for (final item in value) {
      _writeDynamic(writer, item);
    }
    writer.endArray();
  } else if (value is Map) {
    writer.beginObject();
    for (final entry in value.entries) {
      writer.name(entry.key.toString());
      _writeDynamic(writer, entry.value);
    }
    writer.endObject();
  }
}
