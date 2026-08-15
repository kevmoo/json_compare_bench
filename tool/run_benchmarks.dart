import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

final rootDir = File(Platform.script.toFilePath()).parent.parent.path;
final nodeBin = _findNode();
final dartBin = Platform.resolvedExecutable;

Map<String, String> get _toolchainEnv => {
  'PATH':
      '${Platform.environment['HOME']}/.cargo/bin:'
      '${Platform.environment['HOME']}/.local/share/mise/shims:'
      '${Platform.environment['HOME']}/.local/share/mise/installs/node/24/bin:'
      '${Platform.environment['HOME']}/.local/share/dart-sdk-json-utf8-kernels/dart-sdk/bin:'
      '${Platform.environment['PATH']}',
};

void main(List<String> rawArgs) async {
  final parser = ArgParser()
    ..addOption(
      'from-json',
      help:
          'Skip benchmarks; generate report directly from existing '
          'JSON file.',
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
          'Filter languages/runtimes (comma-separated: dart,rust,go,node '
          'or all).',
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
        "Error: The '--from-json' pseudo-command cannot be combined with "
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

  final osStr = systemInfo['os'];
  final cpuStr = systemInfo['cpu_model'];
  final coresStr = systemInfo['logical_cores'];
  final ramStr = systemInfo['total_ram'];

  print('System: $osStr | $cpuStr ($coresStr cores) | RAM: $ramStr');
  final dartMap = toolchains['dart'] as Map<String, dynamic>;
  final rustMap = toolchains['rust'] as Map<String, dynamic>;
  final goMap = toolchains['go'] as Map<String, dynamic>;
  final nodeMap = toolchains['node'] as Map<String, dynamic>;

  print('Dart:   ${dartMap['version']}');
  print('Rust:   ${rustMap['version']}');
  print('Go:     ${goMap['version']}');
  print('Node:   ${nodeMap['version']}');
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
        (fileBytes < 10000 ? 20000 : (fileBytes < 1000000 ? 200 : 50));
    final warmup =
        customWarmup ??
        (fileBytes < 10000 ? 2000 : (fileBytes < 1000000 ? 20 : 5));

    for (final mode in modes) {
      print(
        'Running [$dataset] - Mode: $mode '
        '(Iterations: $iterations, Warmup: $warmup)...',
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
        // Exclusively Dart AOT native binary
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

  final dartCompile = Process.runSync(
    dartBin,
    [
      'compile',
      'exe',
      '$rootDir/dart/bin/bench.dart',
      '-o',
      '$rootDir/dart/bin/bench_aot.exe',
    ],
    workingDirectory: '$rootDir/dart',
    environment: _toolchainEnv,
  );
  if (dartCompile.exitCode != 0) {
    stderr.writeln('Dart AOT compile error: ${dartCompile.stderr}');
  }

  final rustCompile = Process.runSync(
    'cargo',
    ['build', '--release'],
    workingDirectory: '$rootDir/rust',
    environment: _toolchainEnv,
  );
  if (rustCompile.exitCode != 0) {
    stderr.writeln('Rust compile error: ${rustCompile.stderr}');
  }

  final goCompile = Process.runSync(
    'go',
    ['build', '-o', 'json_compare_bench_go', '.'],
    workingDirectory: '$rootDir/go',
    environment: _toolchainEnv,
  );
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
    final res = await Process.run(executable, args, environment: _toolchainEnv);
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
  var osName = Platform.operatingSystem;
  var osVersion = Platform.operatingSystemVersion;
  var arch = Platform.localeName.contains('64') ? 'x86_64' : 'unknown';
  var cpuModel = 'Unknown CPU';
  var logicalCores = Platform.numberOfProcessors;
  var totalRam = 'Unknown';

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
      final unameRes = Process.runSync('uname', [
        '-m',
      ], environment: _toolchainEnv);
      if (unameRes.exitCode == 0) {
        arch = unameRes.stdout.toString().trim();
      }
    } else if (Platform.isMacOS) {
      final cpuRes = Process.runSync('sysctl', [
        '-n',
        'machdep.cpu.brand_string',
      ], environment: _toolchainEnv);
      if (cpuRes.exitCode == 0) {
        cpuModel = cpuRes.stdout.toString().trim();
      }
      final memRes = Process.runSync('sysctl', [
        '-n',
        'hw.memsize',
      ], environment: _toolchainEnv);
      if (memRes.exitCode == 0) {
        final bytes = int.tryParse(memRes.stdout.toString().trim());
        if (bytes != null) {
          totalRam = '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
        }
      }
      final unameRes = Process.runSync('uname', [
        '-m',
      ], environment: _toolchainEnv);
      if (unameRes.exitCode == 0) {
        arch = unameRes.stdout.toString().trim();
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
  var dartVersion = Platform.version;
  var rustVersion = 'Unknown';
  var goVersion = 'Unknown';
  var nodeVersion = 'Unknown';
  final dartPackages = <String, String>{
    'codable': 'package:codable (SDK integration)',
  };
  final rustPackages = <String, String>{};
  final goPackages = <String, String>{'encoding/json': 'Standard Library'};
  final nodePackages = <String, String>{'v8_builtin': 'V8 C++ Built-in'};

  try {
    final rustRes = Process.runSync('rustc', [
      '--version',
    ], environment: _toolchainEnv);
    if (rustRes.exitCode == 0) {
      rustVersion = rustRes.stdout.toString().trim();
    }
  } catch (_) {}

  try {
    final goRes = Process.runSync('go', [
      'version',
    ], environment: _toolchainEnv);
    if (goRes.exitCode == 0) {
      goVersion = goRes.stdout.toString().trim();
    }
  } catch (_) {}

  try {
    final nodeRes = Process.runSync(nodeBin, [
      '--version',
    ], environment: _toolchainEnv);
    final v8Res = Process.runSync(nodeBin, [
      '-p',
      'process.versions.v8',
    ], environment: _toolchainEnv);
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
      if (match != null) {
        rustPackages['serde_json'] = match.group(1)!;
      }
      final serdeMatch = RegExp(
        r'name\s*=\s*"serde"\s*\nversion\s*=\s*"([^"]+)"',
      ).firstMatch(content);
      if (serdeMatch != null) {
        rustPackages['serde'] = serdeMatch.group(1)!;
      }
      final mimallocMatch = RegExp(
        r'name\s*=\s*"mimalloc"\s*\nversion\s*=\s*"([^"]+)"',
      ).firstMatch(content);
      if (mimallocMatch != null) {
        rustPackages['mimalloc'] =
            '${mimallocMatch.group(1)!} (global allocator)';
      }
    }
  } catch (_) {}

  return {
    'dart': {'version': dartVersion, 'packages': dartPackages},
    'rust': {'version': rustVersion, 'packages': rustPackages},
    'go': {'version': goVersion, 'packages': goPackages},
    'node': {'version': nodeVersion, 'packages': nodePackages},
  };
}

String _findNode() {
  final miseNode =
      '${Platform.environment['HOME']}/.local/share/mise/installs/node/24/bin/node';
  if (File(miseNode).existsSync()) return miseNode;
  final miseNode2 =
      '${Platform.environment['HOME']}/.local/share/mise/shims/node';
  if (File(miseNode2).existsSync()) return miseNode2;
  try {
    final whichRes = Process.runSync('which', [
      'node',
    ], environment: _toolchainEnv);
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
    '* **Hardware**: ${system['cpu_model']} '
    '(${system['logical_cores']} logical cores) | '
    'RAM: ${system['total_ram']}',
  );
  buffer.writeln('* **Toolchains & Packages**:');

  void printToolchain(String label, String key) {
    final tc = toolchains[key];
    if (tc is Map<String, dynamic>) {
      final ver = tc['version'] ?? 'Unknown';
      buffer.writeln('  * **$label**: `$ver`');
      final pkgs = tc['packages'] as Map<String, dynamic>? ?? {};
      for (final entry in pkgs.entries) {
        final val = entry.value.toString();
        if (val.startsWith('http')) {
          buffer.writeln('    * `${entry.key}`: [$val]($val)');
        } else {
          buffer.writeln('    * `${entry.key}`: `$val`');
        }
      }
    } else if (tc != null) {
      buffer.writeln('  * **$label**: `$tc`');
    }
  }

  printToolchain('Dart', 'dart');
  printToolchain('Rust', 'rust');
  printToolchain('Go', 'go');
  printToolchain('Node.js', 'node');
  buffer.writeln('');
  buffer.writeln(
    '> [!NOTE]\n'
    '> **Native Byte Buffer Contract & Implementation Context**:\n'
    '> * **Native Byte Buffer Contract**: Native binaries (Dart AOT, Rust, Go) '
    'benchmark direct UTF-8 byte serialization/deserialization '
    '(`Uint8List` / `&[u8]` / `[]byte`), which represents real-world '
    'production I/O (sockets, files, cache). Node.js executes via V8 C++ '
    'built-ins.\n'
    '> * **`Dart AOT (std)`**: Uses standard library `dart:convert`. Decode is '
    '`utf8.decoder.fuse(json.decoder)` into dynamic `Map<String, dynamic>`. '
    'Encode is `json.encoder.fuse(utf8.encoder)`.\n'
    '> * **`Dart AOT (package:codable)`**: Uses the next-generation streaming '
    'zero-allocation deserializer/serializer (`package:codable`) with '
    'delimiter-fused reads, SWAR 64-bit jump tables, and Eisel-Lemire float '
    'parsing operating directly over raw UTF-8 byte spans without '
    'intermediate DOM maps.\n',
  );

  final datasets = rawBenchmarks
      .map((r) => r['dataset'] as String)
      .toSet()
      .toList();

  for (final mode in ['decode', 'encode']) {
    buffer.writeln('## ${mode.toUpperCase()} Throughput Matrix\n');
    buffer.writeln(
      'Higher throughput (MB/s) is better. '
      'Medals (🥇, 🥈, 🥉) indicate top 3 performance per dataset.\n',
    );
    buffer.writeln(
      '| Dataset | Dart AOT (std) | Dart AOT (package:codable) | '
      'Rust (`serde_json`) | Node.js (V8) | Go (`encoding/json`) |',
    );
    buffer.writeln('| :--- | :---: | :---: | :---: | :---: | :---: |');

    for (final dataset in datasets) {
      final subset = rawBenchmarks
          .where((r) => r['dataset'] == dataset && r['mode'] == mode)
          .toList();
      if (subset.isEmpty) continue;

      // Extract scores
      final dartStdBest = subset
          .where(
            (r) =>
                r['language'] == 'dart' &&
                r['implementation'] == 'convert_utf8',
          )
          .firstOrNull;

      final dartCodableBest = subset
          .where(
            (r) =>
                r['language'] == 'dart' &&
                (r['implementation'] == 'codable_utf8' ||
                    r['implementation'] == 'codable' ||
                    r['implementation'] == 'package_codable'),
          )
          .firstOrNull;

      final rustBest = subset.where((r) => r['language'] == 'rust').firstOrNull;
      final nodeBest = subset.where((r) => r['language'] == 'node').firstOrNull;
      final goBest = subset.where((r) => r['language'] == 'go').firstOrNull;

      final dartStdMb =
          (dartStdBest?['throughput_mb_s'] as num?)?.toDouble() ?? 0.0;
      final dartCodableMb =
          (dartCodableBest?['throughput_mb_s'] as num?)?.toDouble() ?? 0.0;
      final rustMb = (rustBest?['throughput_mb_s'] as num?)?.toDouble() ?? 0.0;
      final nodeMb = (nodeBest?['throughput_mb_s'] as num?)?.toDouble() ?? 0.0;
      final goMb = (goBest?['throughput_mb_s'] as num?)?.toDouble() ?? 0.0;

      // Determine top 3 medals across all 5 contenders
      final scores = <ScoreEntry>[
        ScoreEntry('dart_std', dartStdMb),
        ScoreEntry('dart_codable', dartCodableMb),
        ScoreEntry('rust', rustMb),
        ScoreEntry('node', nodeMb),
        ScoreEntry('go', goMb),
      ]..sort((a, b) => b.score.compareTo(a.score));

      final winnerMb = scores.first.score > 0 ? scores.first.score : 1.0;

      String medal(String key) {
        if (scores[0].name == key && scores[0].score > 0) return '🥇 ';
        if (scores[1].name == key && scores[1].score > 0) return '🥈 ';
        if (scores[2].name == key && scores[2].score > 0) return '🥉 ';
        return '';
      }

      String formatCell(Map<String, dynamic>? item, String key, double mb) {
        if (item == null || mb == 0) return 'N/A';
        final m = medal(key);
        final isBold = m.isNotEmpty;
        final mbStr = '${mb.toStringAsFixed(1)} MB/s';
        return isBold ? '$m**$mbStr**' : mbStr;
      }

      String formatPercent(double mb) {
        if (mb == 0) return 'N/A';
        final pct = (mb / winnerMb * 100.0).toStringAsFixed(1);
        final isWinner = mb == winnerMb;
        return isWinner ? '**$pct%**' : '$pct%';
      }

      final fileBytes = (subset.first['file_bytes'] as num?)?.toInt() ?? 0;
      final sizeStr = fileBytes > 1048576
          ? '${(fileBytes / 1048576).toStringAsFixed(1)} MB'
          : '${(fileBytes / 1024).toStringAsFixed(0)} KB';

      // Row 1: Throughput
      buffer.writeln(
        '| **`$dataset`** (~$sizeStr) | '
        '${formatCell(dartStdBest, 'dart_std', dartStdMb)} | '
        '${formatCell(dartCodableBest, 'dart_codable', dartCodableMb)} | '
        '${formatCell(rustBest, 'rust', rustMb)} | '
        '${formatCell(nodeBest, 'node', nodeMb)} | '
        '${formatCell(goBest, 'go', goMb)} |',
      );
      // Row 2: % of Winner
      buffer.writeln(
        '| ↳ *% of Winner* | '
        '${formatPercent(dartStdMb)} | '
        '${formatPercent(dartCodableMb)} | '
        '${formatPercent(rustMb)} | '
        '${formatPercent(nodeMb)} | '
        '${formatPercent(goMb)} |',
      );
    }
    buffer.writeln('');
  }

  return buffer.toString();
}

class ScoreEntry {
  final String name;
  final double score;

  ScoreEntry(this.name, this.score);
}
