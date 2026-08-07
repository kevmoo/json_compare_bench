import 'dart:convert';
import 'dart:io';

final rootDir = File(Platform.script.toFilePath()).parent.parent.path;
final nodeBin = _findNode();
final dartBin = Platform.resolvedExecutable;

String _findNode() {
  final miseNode =
      '${Platform.environment['HOME']}/.local/share/mise/installs/node/24/bin/node';
  if (File(miseNode).existsSync()) return miseNode;
  final whichRes = Process.runSync('which', ['node']);
  if (whichRes.exitCode == 0) return whichRes.stdout.toString().trim();
  return 'node';
}

void main(List<String> args) async {
  print('===============================================================');
  print('        JSON COMPARE BENCH: Cross-Language Benchmark           ');
  print('===============================================================');
  print('Root: $rootDir');
  print('Dart: $dartBin');
  print('Node: $nodeBin');
  print('');

  await _buildBinaries();

  final datasets = [
    'small.json',
    'twitter.json',
    'citm_catalog.json',
    'canada.json',
  ];

  final allResults = <Map<String, dynamic>>[];

  for (final dataset in datasets) {
    final datasetPath = '$rootDir/data/$dataset';
    if (!File(datasetPath).existsSync()) {
      print('Warning: Dataset $dataset not found, skipping.');
      continue;
    }

    final fileBytes = File(datasetPath).lengthSync();
    // Dynamic iteration counts based on dataset size for stable measurements
    final iterations = fileBytes < 10000
        ? 500
        : (fileBytes < 1000000 ? 50 : 20);
    final warmup = fileBytes < 10000 ? 50 : 5;

    for (final mode in ['decode', 'encode']) {
      print(
        'Running [$dataset] - Mode: $mode (Iterations: $iterations, Warmup: $warmup)...',
      );

      // 1. Rust (serde_json)
      allResults.addAll(
        await _runProcess(
          '$rootDir/rust/target/release/json_compare_bench_rust',
          [
            '--dataset',
            datasetPath,
            '--mode',
            mode,
            '--iterations',
            '$iterations',
            '--warmup',
            '$warmup',
          ],
        ),
      );

      // 2. Go (encoding/json)
      allResults.addAll(
        await _runProcess('$rootDir/go/json_compare_bench_go', [
          '--dataset',
          datasetPath,
          '--mode',
          mode,
          '--iterations',
          '$iterations',
          '--warmup',
          '$warmup',
        ]),
      );

      // 3. Node.js (V8 built-in)
      allResults.addAll(
        await _runProcess(nodeBin, [
          '$rootDir/node/index.mjs',
          '--dataset',
          datasetPath,
          '--mode',
          mode,
          '--iterations',
          '$iterations',
          '--warmup',
          '$warmup',
        ]),
      );

      // 4. Dart AOT
      allResults.addAll(
        await _runProcess('$rootDir/dart/bin/bench_aot.exe', [
          '--dataset',
          datasetPath,
          '--mode',
          mode,
          '--impl',
          'all',
          '--iterations',
          '$iterations',
          '--warmup',
          '$warmup',
        ], labelPrefix: 'dart_aot'),
      );

      // 5. Dart JIT
      allResults.addAll(
        await _runProcess(dartBin, [
          '$rootDir/dart/bin/bench.dart',
          '--dataset',
          datasetPath,
          '--mode',
          mode,
          '--impl',
          'all',
          '--iterations',
          '$iterations',
          '--warmup',
          '$warmup',
        ], labelPrefix: 'dart_jit'),
      );
    }
  }

  print('\n');
  _printMarkdownSummary(allResults);
}

Future<void> _buildBinaries() async {
  print('>> Compiling benchmark binaries...');

  // Dart AOT
  print('   Compiling Dart AOT binary...');
  final dartCompile = Process.runSync(dartBin, [
    'compile',
    'exe',
    '$rootDir/dart/bin/bench.dart',
    '-o',
    '$rootDir/dart/bin/bench_aot.exe',
  ], workingDirectory: '$rootDir/dart');
  if (dartCompile.exitCode != 0) {
    stderr.writeln('Dart AOT compile error: ${dartCompile.stderr}');
  }

  // Rust
  print('   Compiling Rust release binary...');
  final rustCompile = Process.runSync(
    'cargo',
    ['build', '--release'],
    workingDirectory: '$rootDir/rust',
    environment: {
      'PATH':
          '${Platform.environment['HOME']}/.cargo/bin:${Platform.environment['PATH']}',
    },
  );
  if (rustCompile.exitCode != 0) {
    stderr.writeln('Rust compile error: ${rustCompile.stderr}');
  }

  // Go
  print('   Compiling Go binary...');
  final goCompile = Process.runSync('go', [
    'build',
    '-o',
    'json_compare_bench_go',
    'main.go',
  ], workingDirectory: '$rootDir/go');
  if (goCompile.exitCode != 0) {
    stderr.writeln('Go compile error: ${goCompile.stderr}');
  }

  print('>> All binaries ready!\n');
}

Future<List<Map<String, dynamic>>> _runProcess(
  String executable,
  List<String> args, {
  String? labelPrefix,
}) async {
  final results = <Map<String, dynamic>>[];
  try {
    final res = await Process.run(executable, args);
    if (res.exitCode != 0) {
      stderr.writeln('Error running $executable: ${res.stderr}');
      return results;
    }

    final lines = res.stdout.toString().trim().split('\n');
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      try {
        final data = jsonDecode(line.trim()) as Map<String, dynamic>;
        if (labelPrefix != null) {
          data['runtime'] = labelPrefix;
        }
        results.add(data);
      } catch (e) {
        stderr.writeln('Failed to parse line: $line ($e)');
      }
    }
  } catch (e) {
    stderr.writeln('Process execution error for $executable: $e');
  }
  return results;
}

void _printMarkdownSummary(List<Map<String, dynamic>> results) {
  print('# Benchmark Results Summary\n');

  final datasets = results.map((r) => r['dataset'] as String).toSet().toList();

  for (final dataset in datasets) {
    for (final mode in ['decode', 'encode']) {
      final filtered = results
          .where((r) => r['dataset'] == dataset && r['mode'] == mode)
          .toList();
      if (filtered.isEmpty) continue;

      // Sort by throughput descending (fastest first)
      filtered.sort(
        (a, b) => (b['throughput_mb_s'] as num).compareTo(
          a['throughput_mb_s'] as num,
        ),
      );

      print('### Dataset: `$dataset` | Mode: `${mode.toUpperCase()}`\n');
      print(
        '| Rank | Language / Runtime | Implementation | Throughput (MB/s) | Latency (ns/op) | Rel. vs Rust |',
      );
      print('| :--- | :--- | :--- | :---: | :---: | :---: |');

      final rustResult = filtered.firstWhere(
        (r) => r['language'] == 'rust',
        orElse: () => filtered.first,
      );
      final rustThroughput = (rustResult['throughput_mb_s'] as num).toDouble();

      for (var i = 0; i < filtered.length; i++) {
        final row = filtered[i];
        final lang = row['language'];
        final runtime = row['runtime'] ?? lang;
        final impl = row['implementation'];
        final throughput = (row['throughput_mb_s'] as num).toDouble();
        final nsPerOp = row['ns_per_op'];
        final relVsRust =
            (throughput / rustThroughput).toStringAsFixed(2) + 'x';

        final label = runtime == lang ? '$lang' : '$lang ($runtime)';
        print(
          '| ${i + 1} | **$label** | `$impl` | **$throughput** | $nsPerOp | $relVsRust |',
        );
      }
      print('');
    }
  }
}
