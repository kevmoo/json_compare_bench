import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

final rootDir = File(Platform.script.toFilePath()).parent.parent.path;
final nodeBin = _findNode();
final dartBin = Platform.resolvedExecutable;

void main(List<String> rawArgs) async {
  final parser = ArgParser()
    ..addOption(
      'from-json',
      help:
          'Skip benchmarks; generate report directly from existing JSON file.',
    )
    ..addOption(
      'dataset',
      abbr: 'd',
      defaultsTo: 'all',
      allowed: [
        'small.json',
        'twitter.json',
        'citm_catalog.json',
        'canada.json',
        'all',
      ],
      help: 'Filter dataset to benchmark.',
    )
    ..addOption(
      'lang',
      abbr: 'l',
      defaultsTo: 'all',
      help:
          'Filter languages/runtimes (comma-separated: dart,rust,go,node or all).',
    )
    ..addOption(
      'mode',
      abbr: 'm',
      defaultsTo: 'both',
      allowed: ['decode', 'encode', 'both'],
      help: 'Filter benchmark mode.',
    )
    ..addFlag(
      'write-json',
      defaultsTo: true,
      help: 'Save benchmark results to JSON file.',
    )
    ..addFlag(
      'write-markdown',
      defaultsTo: true,
      help: 'Save formatted report to Markdown file.',
    )
    ..addOption(
      'json-output',
      defaultsTo: 'results.json',
      help: 'Path for output JSON file.',
    )
    ..addOption(
      'markdown-output',
      defaultsTo: 'RESULTS.md',
      help: 'Path for output Markdown report.',
    )
    ..addOption(
      'iterations',
      abbr: 'n',
      help: 'Override iteration count per dataset.',
    )
    ..addOption('warmup', abbr: 'w', help: 'Override warmup count per dataset.')
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Display usage instructions.',
    );

  ArgResults args;
  try {
    args = parser.parse(rawArgs);
  } on FormatException catch (e) {
    stderr.writeln('Error: ${e.message}\n');
    stderr.writeln(parser.usage);
    exit(64);
  }

  if (args['help'] as bool) {
    print('Usage: dart run tool/run_benchmarks.dart [options]\n');
    print(parser.usage);
    exit(0);
  }

  final fromJsonPath = args['from-json'] as String?;

  // Validate pseudo-command exclusivity for --from-json
  if (fromJsonPath != null) {
    final conflictingOptions = <String>[];
    if (args.wasParsed('dataset')) conflictingOptions.add('--dataset');
    if (args.wasParsed('lang')) conflictingOptions.add('--lang');
    if (args.wasParsed('mode')) conflictingOptions.add('--mode');
    if (args.wasParsed('iterations')) conflictingOptions.add('--iterations');
    if (args.wasParsed('warmup')) conflictingOptions.add('--warmup');

    if (conflictingOptions.isNotEmpty) {
      stderr.writeln(
        'Error: The \'--from-json\' pseudo-command cannot be combined with '
        'benchmark execution flags: ${conflictingOptions.join(', ')}.\n',
      );
      stderr.writeln(parser.usage);
      exit(64);
    }

    await _runFromJson(
      fromJsonPath: fromJsonPath,
      writeJson: args['write-json'] as bool,
      writeMarkdown: args['write-markdown'] as bool,
      jsonOutputPath: args['json-output'] as String,
      markdownOutputPath: args['markdown-output'] as String,
    );
    return;
  }

  // Full or filtered benchmark execution
  await _runBenchmarks(
    datasetChoice: args['dataset'] as String,
    langChoice: args['lang'] as String,
    modeChoice: args['mode'] as String,
    writeJson: args['write-json'] as bool,
    writeMarkdown: args['write-markdown'] as bool,
    jsonOutputPath: args['json-output'] as String,
    markdownOutputPath: args['markdown-output'] as String,
    customIterations: args['iterations'] != null
        ? int.tryParse(args['iterations'] as String)
        : null,
    customWarmup: args['warmup'] != null
        ? int.tryParse(args['warmup'] as String)
        : null,
  );
}

Future<void> _runFromJson({
  required String fromJsonPath,
  required bool writeJson,
  required bool writeMarkdown,
  required String jsonOutputPath,
  required String markdownOutputPath,
}) async {
  final resolvedPath = fromJsonPath.startsWith('/')
      ? fromJsonPath
      : '$rootDir/$fromJsonPath';
  final file = File(resolvedPath);
  if (!file.existsSync()) {
    stderr.writeln('Error: JSON file not found: $resolvedPath');
    exit(1);
  }

  print('>> Reading benchmark data from: $resolvedPath');
  final jsonContent =
      jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final markdown = _generateMarkdownReport(jsonContent);

  print('\n$markdown');

  if (writeMarkdown) {
    final mdFile = File(
      markdownOutputPath.startsWith('/')
          ? markdownOutputPath
          : '$rootDir/$markdownOutputPath',
    );
    mdFile.writeAsStringSync(markdown);
    print('>> Wrote Markdown report to: ${mdFile.path}');
  }

  if (writeJson && jsonOutputPath != fromJsonPath) {
    final jFile = File(
      jsonOutputPath.startsWith('/')
          ? jsonOutputPath
          : '$rootDir/$jsonOutputPath',
    );
    jFile.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(jsonContent),
    );
    print('>> Wrote JSON output to: ${jFile.path}');
  }
}

Future<void> _runBenchmarks({
  required String datasetChoice,
  required String langChoice,
  required String modeChoice,
  required bool writeJson,
  required bool writeMarkdown,
  required String jsonOutputPath,
  required String markdownOutputPath,
  int? customIterations,
  int? customWarmup,
}) async {
  print('===============================================================');
  print('        JSON COMPARE BENCH: Cross-Language Benchmark           ');
  print('===============================================================');

  final systemInfo = _harvestSystemInfo();
  final toolchains = _harvestToolchainInfo();

  print(
    'System: ${systemInfo['os']} | ${systemInfo['cpu_model']} (${systemInfo['logical_cores']} cores) | RAM: ${systemInfo['total_ram']}',
  );
  print('Dart:   ${toolchains['dart']}');
  print('Rust:   ${toolchains['rust']}');
  print('Go:     ${toolchains['go']}');
  print('Node:   ${toolchains['node']}');
  print('');

  await _buildBinaries();

  final allDatasets = [
    'small.json',
    'twitter.json',
    'citm_catalog.json',
    'canada.json',
  ];
  final datasets = datasetChoice == 'all' ? allDatasets : [datasetChoice];

  final allLanguages = ['rust', 'go', 'node', 'dart'];
  final targetLanguages = langChoice == 'all'
      ? allLanguages
      : langChoice.split(',').map((s) => s.trim().toLowerCase()).toList();

  final modes = modeChoice == 'both' ? ['decode', 'encode'] : [modeChoice];

  final benchmarkRecords = <Map<String, dynamic>>[];

  for (final dataset in datasets) {
    final datasetPath = '$rootDir/data/$dataset';
    if (!File(datasetPath).existsSync()) {
      stderr.writeln('Warning: Dataset $dataset not found, skipping.');
      continue;
    }

    final fileBytes = File(datasetPath).lengthSync();
    final iterations =
        customIterations ??
        (fileBytes < 10000 ? 500 : (fileBytes < 1000000 ? 50 : 20));
    final warmup = customWarmup ?? (fileBytes < 10000 ? 50 : 5);

    for (final mode in modes) {
      print(
        'Running [$dataset] - Mode: $mode (Iterations: $iterations, Warmup: $warmup)...',
      );

      if (targetLanguages.contains('rust')) {
        benchmarkRecords.addAll(
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
      }

      if (targetLanguages.contains('go')) {
        benchmarkRecords.addAll(
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
      }

      if (targetLanguages.contains('node')) {
        benchmarkRecords.addAll(
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
      }

      if (targetLanguages.contains('dart')) {
        // Dart AOT
        benchmarkRecords.addAll(
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

        // Dart JIT
        benchmarkRecords.addAll(
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
  }

  final fullResultPayload = {
    'timestamp': DateTime.now().toUtc().toIso8601String(),
    'system': systemInfo,
    'toolchains': toolchains,
    'benchmarks': benchmarkRecords,
  };

  print('\n');
  final markdown = _generateMarkdownReport(fullResultPayload);
  print(markdown);

  if (writeJson) {
    final jFile = File(
      jsonOutputPath.startsWith('/')
          ? jsonOutputPath
          : '$rootDir/$jsonOutputPath',
    );
    jFile.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(fullResultPayload),
    );
    print('>> Saved JSON results to: ${jFile.path}');
  }

  if (writeMarkdown) {
    final mdFile = File(
      markdownOutputPath.startsWith('/')
          ? markdownOutputPath
          : '$rootDir/$markdownOutputPath',
    );
    mdFile.writeAsStringSync(markdown);
    print('>> Saved Markdown report to: ${mdFile.path}');
  }
}

Future<void> _buildBinaries() async {
  print('>> Compiling benchmark binaries...');

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

Map<String, dynamic> _harvestSystemInfo() {
  String osName = Platform.operatingSystem;
  String osVersion = Platform.operatingSystemVersion;
  String arch = Platform.localeName.contains('64') ? 'x86_64' : 'unknown';
  String cpuModel = 'Unknown CPU';
  int logicalCores = Platform.numberOfProcessors;
  String totalRam = 'Unknown';

  try {
    if (Platform.isLinux) {
      final cpuInfoFile = File('/proc/cpuinfo');
      if (cpuInfoFile.existsSync()) {
        for (final line in cpuInfoFile.readAsLinesSync()) {
          if (line.startsWith('model name')) {
            cpuModel = line.split(':').last.trim();
            break;
          }
        }
      }
      final memInfoFile = File('/proc/meminfo');
      if (memInfoFile.existsSync()) {
        for (final line in memInfoFile.readAsLinesSync()) {
          if (line.startsWith('MemTotal:')) {
            final kb = int.tryParse(line.replaceAll(RegExp(r'[^0-9]'), ''));
            if (kb != null) {
              totalRam = '${(kb / (1024 * 1024)).toStringAsFixed(1)} GB';
            }
            break;
          }
        }
      }
      final unameRes = Process.runSync('uname', ['-m']);
      if (unameRes.exitCode == 0) arch = unameRes.stdout.toString().trim();
    } else if (Platform.isMacOS) {
      final cpuRes = Process.runSync('sysctl', [
        '-n',
        'machdep.cpu.brand_string',
      ]);
      if (cpuRes.exitCode == 0) cpuModel = cpuRes.stdout.toString().trim();
      final memRes = Process.runSync('sysctl', ['-n', 'hw.memsize']);
      if (memRes.exitCode == 0) {
        final bytes = int.tryParse(memRes.stdout.toString().trim());
        if (bytes != null)
          totalRam = '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
      }
      final unameRes = Process.runSync('uname', ['-m']);
      if (unameRes.exitCode == 0) arch = unameRes.stdout.toString().trim();
    } else if (Platform.isWindows) {
      final cpuRes = Process.runSync('wmic', ['cpu', 'get', 'name']);
      if (cpuRes.exitCode == 0) {
        final lines = cpuRes.stdout.toString().trim().split('\n');
        if (lines.length > 1) cpuModel = lines[1].trim();
      }
      final memRes = Process.runSync('wmic', [
        'computersystem',
        'get',
        'TotalPhysicalMemory',
      ]);
      if (memRes.exitCode == 0) {
        final lines = memRes.stdout.toString().trim().split('\n');
        if (lines.length > 1) {
          final bytes = int.tryParse(lines[1].trim());
          if (bytes != null)
            totalRam =
                '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
        }
      }
    }
  } catch (_) {
    // Resilient fallback: never crash on system info extraction
  }

  return {
    'os': '$osName ($osVersion)',
    'architecture': arch,
    'cpu_model': cpuModel,
    'logical_cores': logicalCores,
    'total_ram': totalRam,
  };
}

Map<String, dynamic> _harvestToolchainInfo() {
  String dartVersion = Platform.version;
  String rustVersion = 'Unknown';
  String goVersion = 'Unknown';
  String nodeVersion = 'Unknown';
  final libraries = <String, String>{};

  try {
    final rustRes = Process.runSync(
      'rustc',
      ['--version'],
      environment: {
        'PATH':
            '${Platform.environment['HOME']}/.cargo/bin:${Platform.environment['PATH']}',
      },
    );
    if (rustRes.exitCode == 0) rustVersion = rustRes.stdout.toString().trim();
  } catch (_) {}

  try {
    final goRes = Process.runSync('go', ['version']);
    if (goRes.exitCode == 0) goVersion = goRes.stdout.toString().trim();
  } catch (_) {}

  try {
    final nodeRes = Process.runSync(nodeBin, ['--version']);
    final v8Res = Process.runSync(nodeBin, ['-p', 'process.versions.v8']);
    if (nodeRes.exitCode == 0) {
      final nVer = nodeRes.stdout.toString().trim();
      final v8Ver = v8Res.exitCode == 0
          ? ' (V8 ${v8Res.stdout.toString().trim()})'
          : '';
      nodeVersion = '$nVer$v8Ver';
    }
  } catch (_) {}

  try {
    final cargoLock = File('$rootDir/rust/Cargo.lock');
    if (cargoLock.existsSync()) {
      final content = cargoLock.readAsStringSync();
      final match = RegExp(
        r'name\s*=\s*"serde_json"\s*\nversion\s*=\s*"([^"]+)"',
      ).firstMatch(content);
      if (match != null) libraries['serde_json'] = match.group(1)!;
    }
    final dartLock = File('$rootDir/dart/pubspec.lock');
    if (dartLock.existsSync()) {
      final content = dartLock.readAsStringSync();
      final match = RegExp(
        r'json_annotation:\s*[\s\S]*?version:\s*"([^"]+)"',
      ).firstMatch(content);
      if (match != null) libraries['json_annotation'] = match.group(1)!;
    }
  } catch (_) {}

  return {
    'dart': dartVersion,
    'rust': rustVersion,
    'go': goVersion,
    'node': nodeVersion,
    'libraries': libraries,
  };
}

String _findNode() {
  final miseNode =
      '${Platform.environment['HOME']}/.local/share/mise/installs/node/24/bin/node';
  if (File(miseNode).existsSync()) return miseNode;
  try {
    final whichRes = Process.runSync('which', ['node']);
    if (whichRes.exitCode == 0) return whichRes.stdout.toString().trim();
  } catch (_) {}
  return 'node';
}

String _generateMarkdownReport(Map<String, dynamic> data) {
  final buffer = StringBuffer();
  final timestamp = data['timestamp'] ?? 'Unknown';
  final system = data['system'] as Map<String, dynamic>? ?? {};
  final toolchains = data['toolchains'] as Map<String, dynamic>? ?? {};
  final rawBenchmarks = (data['benchmarks'] as List<dynamic>? ?? [])
      .cast<Map<String, dynamic>>();

  buffer.writeln('# Benchmark Results\n');
  buffer.writeln('* **Run Date**: `$timestamp`');
  buffer.writeln('* **System**: ${system['os']} | ${system['architecture']}');
  buffer.writeln(
    '* **Hardware**: ${system['cpu_model']} (${system['logical_cores']} logical cores) | RAM: ${system['total_ram']}',
  );
  buffer.writeln('* **Toolchains**:');
  buffer.writeln('  * **Dart**: `${toolchains['dart']}`');
  buffer.writeln('  * **Rust**: `${toolchains['rust']}`');
  buffer.writeln('  * **Go**: `${toolchains['go']}`');
  buffer.writeln('  * **Node.js**: `${toolchains['node']}`');

  final libs = toolchains['libraries'] as Map<String, dynamic>?;
  if (libs != null && libs.isNotEmpty) {
    buffer.writeln(
      '  * **Key Packages**: ' +
          libs.entries.map((e) => '`${e.key} ${e.value}`').join(', '),
    );
  }
  buffer.writeln('');

  final datasets = rawBenchmarks
      .map((r) => r['dataset'] as String)
      .toSet()
      .toList();

  for (final mode in ['decode', 'encode']) {
    buffer.writeln('## ${mode.toUpperCase()} Throughput Matrix\n');
    buffer.writeln(
      'Higher throughput (MB/s) is better. Medals (🥇, 🥈, 🥉) indicate top 3 performance per dataset.\n',
    );
    buffer.writeln(
      '| Dataset | Dart (convert) | Dart (json_rw) | Rust (`serde_json`) | Node.js (V8) | Go (`encoding/json`) |',
    );
    buffer.writeln('| :--- | :---: | :---: | :---: | :---: | :---: |');

    for (final dataset in datasets) {
      final subset = rawBenchmarks
          .where((r) => r['dataset'] == dataset && r['mode'] == mode)
          .toList();
      if (subset.isEmpty) continue;

      // Extract best scores per track
      final dartConvertBest = subset
          .where(
            (r) =>
                r['language'] == 'dart' &&
                (r['implementation'] as String).startsWith('convert'),
          )
          .fold<Map<String, dynamic>?>(
            null,
            (prev, curr) =>
                prev == null ||
                    (curr['throughput_mb_s'] as num) >
                        (prev['throughput_mb_s'] as num)
                ? curr
                : prev,
          );

      final dartRwBest = subset
          .where(
            (r) =>
                r['language'] == 'dart' &&
                (r['implementation'] as String).startsWith('json_rw'),
          )
          .fold<Map<String, dynamic>?>(
            null,
            (prev, curr) =>
                prev == null ||
                    (curr['throughput_mb_s'] as num) >
                        (prev['throughput_mb_s'] as num)
                ? curr
                : prev,
          );

      final rustBest = subset.where((r) => r['language'] == 'rust').firstOrNull;
      final nodeBest = subset.where((r) => r['language'] == 'node').firstOrNull;
      final goBest = subset.where((r) => r['language'] == 'go').firstOrNull;

      final dartConvertMb =
          (dartConvertBest?['throughput_mb_s'] as num?)?.toDouble() ?? 0.0;
      final dartRwMb =
          (dartRwBest?['throughput_mb_s'] as num?)?.toDouble() ?? 0.0;
      final rustMb = (rustBest?['throughput_mb_s'] as num?)?.toDouble() ?? 0.0;
      final nodeMb = (nodeBest?['throughput_mb_s'] as num?)?.toDouble() ?? 0.0;
      final goMb = (goBest?['throughput_mb_s'] as num?)?.toDouble() ?? 0.0;

      // Determine top 3 medals across all 5 contenders
      final scores = [
        ('dart_convert', dartConvertMb),
        ('dart_json_rw', dartRwMb),
        ('rust', rustMb),
        ('node', nodeMb),
        ('go', goMb),
      ]..sort((a, b) => b.$2.compareTo(a.$2));

      final winnerMb = scores.first.$2 > 0 ? scores.first.$2 : 1.0;

      String medal(String key) {
        if (scores[0].$1 == key && scores[0].$2 > 0) return '🥇 ';
        if (scores[1].$1 == key && scores[1].$2 > 0) return '🥈 ';
        if (scores[2].$1 == key && scores[2].$2 > 0) return '🥉 ';
        return '';
      }

      String formatCell(Map<String, dynamic>? item, String key, double mb) {
        if (item == null || mb == 0) return 'N/A';
        final m = medal(key);
        final isBold = m.isNotEmpty;
        final mbStr = '${mb.toStringAsFixed(1)} MB/s';
        final impl = item['implementation'] ?? '';
        final runtime = item['runtime'] ?? '';
        final suffix = (key.startsWith('dart') && impl.isNotEmpty)
            ? ' (`$impl` $runtime)'
            : '';
        return isBold ? '$m**$mbStr**$suffix' : '$mbStr$suffix';
      }

      String formatPercent(double mb) {
        if (mb == 0) return 'N/A';
        final pct = (mb / winnerMb * 100.0).toStringAsFixed(1);
        final isWinner = (mb == winnerMb);
        return isWinner ? '**$pct%**' : '$pct%';
      }

      final fileBytes = subset.first['file_bytes'] ?? 0;
      final sizeStr = fileBytes > 1048576
          ? '${(fileBytes / 1048576).toStringAsFixed(1)} MB'
          : '${(fileBytes / 1024).toStringAsFixed(0)} KB';

      // Row 1: Throughput
      buffer.writeln(
        '| **`$dataset`** (~$sizeStr) | ${formatCell(dartConvertBest, 'dart_convert', dartConvertMb)} | ${formatCell(dartRwBest, 'dart_json_rw', dartRwMb)} | ${formatCell(rustBest, 'rust', rustMb)} | ${formatCell(nodeBest, 'node', nodeMb)} | ${formatCell(goBest, 'go', goMb)} |',
      );
      // Row 2: % of Winner
      buffer.writeln(
        '| ↳ *% of Winner* | ${formatPercent(dartConvertMb)} | ${formatPercent(dartRwMb)} | ${formatPercent(rustMb)} | ${formatPercent(nodeMb)} | ${formatPercent(goMb)} |',
      );
    }
    buffer.writeln('');
  }

  return buffer.toString();
}
