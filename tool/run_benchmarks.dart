import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

final rootDir = File(Platform.script.toFilePath()).parent.parent.path;
const sdkRepoDir =
    '/usr/local/google/home/kevmoo/github/dart-sdk/core/agent-json-utf8-kernels/sdk';
final customSdkDeployDir =
    '${Platform.environment['HOME'] ?? ''}/.local/share/dart-sdk-json-utf8-kernels/dart-sdk';
const codableMonorepoDir =
    '/usr/local/google/home/kevmoo/github/kevmoo/_codable.dart-sdk-integration';

String get nodeBin => _findNode();
String get customDartBin => _findCustomDart();

Map<String, String> get _toolchainEnv => {
  'PATH':
      '${Platform.environment['HOME'] ?? ''}/.cargo/bin:'
      '${Platform.environment['HOME'] ?? ''}/.local/share/mise/shims:'
      '${Platform.environment['HOME'] ?? ''}/.local/share/mise/installs/node/24/bin:'
      '$customSdkDeployDir/bin:'
      '${Platform.environment['PATH'] ?? ''}',
};

void main(List<String> rawArgs) async {
  final parser = ArgParser()
    ..addFlag(
      'rebuild-sdk',
      abbr: 'r',
      defaultsTo: false,
      negatable: false,
      help:
          'Rebuilds the custom SDK via python3 tools/build.py -m release '
          'create_sdk and syncs to deployed SDK directory.',
    )
    ..addFlag(
      'dart-only',
      abbr: 'd',
      defaultsTo: false,
      negatable: false,
      help:
          'Only compiles and executes Dart benchmarks (Dart Codable AOT vs '
          'Dart Std AOT vs Stock Dart if provided), '
          'skipping Rust, Go, and Node.js.',
    )
    ..addOption(
      'stock-sdk',
      help:
          'Path to a stock/unmodified Dart SDK binary or directory to '
          'benchmark baseline out-of-the-box Dart AOT as an explicit '
          'comparative tier.',
    )
    ..addFlag(
      'gen',
      abbr: 'g',
      defaultsTo: false,
      negatable: false,
      help:
          'Runs build_runner build --delete-conflicting-outputs across '
          'dart/ and _codable.dart-sdk-integration before running.',
    )
    ..addOption(
      'dataset',
      defaultsTo: 'all',
      allowed: [
        'small',
        'small.json',
        'twitter',
        'twitter.json',
        'citm_catalog',
        'citm_catalog.json',
        'canada',
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
    ..addOption(
      'iterations',
      abbr: 'n',
      help: 'Override iteration count per dataset.',
    )
    ..addOption('warmup', abbr: 'w', help: 'Override warmup count per dataset.')
    ..addOption(
      'from-json',
      help:
          'Skip benchmarks; generate report directly from existing '
          'JSON file.',
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
    ..addFlag(
      'sync-codable',
      defaultsTo: true,
      help:
          'Synchronize cross_language_benchmark_matrix.json and '
          'BENCHMARK_REPORT.md in _codable.dart-sdk-integration if present.',
    )
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
    if (args.wasParsed('dart-only')) conflictingOptions.add('--dart-only');
    if (args.wasParsed('stock-sdk')) conflictingOptions.add('--stock-sdk');
    if (args.wasParsed('rebuild-sdk')) conflictingOptions.add('--rebuild-sdk');
    if (args.wasParsed('gen')) conflictingOptions.add('--gen');

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
      syncCodable: args['sync-codable'] as bool,
    );
    return;
  }

  // Validate custom iterations and warmup if provided
  int? customIterations;
  if (args['iterations'] != null) {
    final val = int.tryParse(args['iterations'] as String);
    if (val == null || val <= 0) {
      stderr.writeln(
        "Error: '--iterations' must be a positive integer, "
        'got: ${args['iterations']}\n',
      );
      exit(64);
    }
    customIterations = val;
  }

  int? customWarmup;
  if (args['warmup'] != null) {
    final val = int.tryParse(args['warmup'] as String);
    if (val == null || val < 0) {
      stderr.writeln(
        "Error: '--warmup' must be a non-negative integer, "
        'got: ${args['warmup']}\n',
      );
      exit(64);
    }
    customWarmup = val;
  }

  // Normalize dataset choice
  var datasetChoice = args['dataset'] as String;
  if (datasetChoice != 'all' && !datasetChoice.endsWith('.json')) {
    datasetChoice = '$datasetChoice.json';
  }

  // Rebuild SDK if requested
  if (args['rebuild-sdk'] as bool) {
    await _rebuildAndSyncSdk();
  }

  // Run code generators if requested
  if (args['gen'] as bool) {
    await _runCodeGeneration();
  }

  // Resolve optional stock SDK
  String? stockDartBin;
  final stockSdkArg = args['stock-sdk'] as String?;
  if (stockSdkArg != null) {
    stockDartBin = _resolveDartBin(stockSdkArg);
    if (stockDartBin == null) {
      stderr.writeln(
        'Error: Stock Dart SDK executable not found at: $stockSdkArg',
      );
      exit(1);
    }
  }

  // Full or filtered benchmark execution
  await _runBenchmarks(
    datasetChoice: datasetChoice,
    langChoice: args['lang'] as String,
    modeChoice: args['mode'] as String,
    dartOnly: args['dart-only'] as bool,
    stockDartBin: stockDartBin,
    writeJson: args['write-json'] as bool,
    writeMarkdown: args['write-markdown'] as bool,
    jsonOutputPath: args['json-output'] as String,
    markdownOutputPath: args['markdown-output'] as String,
    syncCodable: args['sync-codable'] as bool,
    customIterations: customIterations,
    customWarmup: customWarmup,
  );
}

Future<void> _rebuildAndSyncSdk() async {
  final sdkDir = Directory(sdkRepoDir);
  if (!sdkDir.existsSync()) {
    stderr.writeln('Error: SDK repository not found at: $sdkRepoDir');
    exit(1);
  }

  print('===============================================================');
  print('             Rebuilding Custom Dart SDK                        ');
  print('===============================================================');
  print('Repository: $sdkRepoDir');
  print('Running:    python3 tools/build.py -m release create_sdk\n');

  final buildProcess = await Process.start(
    'python3',
    ['tools/build.py', '-m', 'release', 'create_sdk'],
    workingDirectory: sdkRepoDir,
    environment: _toolchainEnv,
    mode: ProcessStartMode.inheritStdio,
  );
  final exitCode = await buildProcess.exitCode;
  if (exitCode != 0) {
    stderr.writeln('\nError: Dart SDK build failed with exit code $exitCode');
    exit(exitCode);
  }

  final candidates = [
    '$sdkRepoDir/out/ReleaseX64/dart-sdk',
    '$sdkRepoDir/out/ReleaseARM64/dart-sdk',
    '$sdkRepoDir/out/ReleaseIA32/dart-sdk',
    '$sdkRepoDir/out/Release/dart-sdk',
  ];
  String? builtSdk;
  for (final c in candidates) {
    if (Directory(c).existsSync()) {
      builtSdk = c;
      break;
    }
  }

  if (builtSdk == null && Directory('$sdkRepoDir/out').existsSync()) {
    for (final entity in Directory('$sdkRepoDir/out').listSync()) {
      if (entity is Directory) {
        final subSdk = '${entity.path}/dart-sdk';
        if (Directory(subSdk).existsSync()) {
          builtSdk = subSdk;
          break;
        }
      }
    }
  }

  if (builtSdk == null) {
    stderr.writeln('Error: Could not locate built dart-sdk in $sdkRepoDir/out');
    exit(1);
  }

  print('\n>> Syncing built SDK from $builtSdk to $customSdkDeployDir...');
  final deployDir = Directory(customSdkDeployDir);
  if (!deployDir.existsSync()) {
    deployDir.createSync(recursive: true);
  }

  final rsyncRes = Process.runSync('rsync', [
    '-a',
    '--delete',
    '$builtSdk/',
    '$customSdkDeployDir/',
  ], environment: _toolchainEnv);
  if (rsyncRes.exitCode != 0) {
    stderr.writeln('Error syncing SDK: ${rsyncRes.stderr}');
    exit(rsyncRes.exitCode);
  }

  print('>> Custom Dart SDK successfully rebuilt and deployed!\n');
}

Future<void> _runCodeGeneration() async {
  print('===============================================================');
  print('             Running Code Generation (build_runner)            ');
  print('===============================================================');

  // 1. In json_compare_bench/dart
  final dartDir = Directory('$rootDir/dart');
  if (dartDir.existsSync()) {
    print('>> Running build_runner in ${dartDir.path}...');
    final res = Process.runSync(
      customDartBin,
      ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
      workingDirectory: dartDir.path,
      environment: _toolchainEnv,
    );
    if (res.exitCode != 0) {
      stderr.writeln('build_runner in ${dartDir.path} stderr:\n${res.stderr}');
      exit(res.exitCode);
    } else {
      print('>> build_runner in ${dartDir.path} succeeded.');
    }
  }

  // 2. In _codable monorepo
  final codableDir = Directory(codableMonorepoDir);
  if (codableDir.existsSync()) {
    print('>> Running build_runner in $codableMonorepoDir...');
    final res = Process.runSync(
      customDartBin,
      ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
      workingDirectory: codableMonorepoDir,
      environment: _toolchainEnv,
    );
    if (res.exitCode != 0) {
      stderr.writeln(
        'build_runner in $codableMonorepoDir stderr:\n${res.stderr}',
      );
    } else {
      print('>> build_runner in $codableMonorepoDir succeeded.');
    }

    final codableBenchmarksDir = Directory(
      '$codableMonorepoDir/pkgs/codable_benchmarks',
    );
    if (codableBenchmarksDir.existsSync()) {
      print('>> Running build_runner in ${codableBenchmarksDir.path}...');
      final res2 = Process.runSync(
        customDartBin,
        ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
        workingDirectory: codableBenchmarksDir.path,
        environment: _toolchainEnv,
      );
      if (res2.exitCode != 0) {
        stderr.writeln(
          'build_runner in codable_benchmarks stderr:\n${res2.stderr}',
        );
      } else {
        print('>> build_runner in codable_benchmarks succeeded.');
      }
    }
  }

  print('>> Code generation finished.\n');
}

Future<void> _runFromJson({
  required String fromJsonPath,
  required bool writeJson,
  required bool writeMarkdown,
  required String jsonOutputPath,
  required String markdownOutputPath,
  required bool syncCodable,
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

  if (syncCodable) {
    _syncCodableMonorepo(jsonContent);
  }
}

Future<void> _runBenchmarks({
  required String datasetChoice,
  required String langChoice,
  required String modeChoice,
  required bool dartOnly,
  required String? stockDartBin,
  required bool writeJson,
  required bool writeMarkdown,
  required String jsonOutputPath,
  required String markdownOutputPath,
  required bool syncCodable,
  int? customIterations,
  int? customWarmup,
}) async {
  print('===============================================================');
  print('        JSON COMPARE BENCH: Cross-Language Benchmark           ');
  print('===============================================================');

  final systemInfo = _harvestSystemInfo();
  final toolchains = _harvestToolchainInfo(stockDartBin: stockDartBin);

  final osStr = systemInfo['os'];
  final cpuStr = systemInfo['cpu_model'];
  final coresStr = systemInfo['logical_cores'];
  final ramStr = systemInfo['total_ram'];

  print('System: $osStr | $cpuStr ($coresStr cores) | RAM: $ramStr');
  final dartMap = toolchains['dart'] as Map<String, dynamic>;
  print('Dart (Custom SDK): ${dartMap['version']}');
  if (stockDartBin != null && toolchains.containsKey('dart_stock')) {
    final stockMap = toolchains['dart_stock'] as Map<String, dynamic>;
    print('Dart (Stock SDK):  ${stockMap['version']}');
  }

  if (!dartOnly) {
    final rustMap = toolchains['rust'] as Map<String, dynamic>;
    final goMap = toolchains['go'] as Map<String, dynamic>;
    final nodeMap = toolchains['node'] as Map<String, dynamic>;
    print('Rust:              ${rustMap['version']}');
    print('Go:                ${goMap['version']}');
    print('Node:              ${nodeMap['version']}');
  }
  print('');

  final allLanguages = ['rust', 'go', 'node', 'dart'];
  final targetLanguages = dartOnly
      ? ['dart']
      : (langChoice == 'all'
            ? allLanguages
            : langChoice
                  .split(',')
                  .map((s) => s.trim().toLowerCase())
                  .toList());

  await _buildBinaries(
    dartOnly: dartOnly,
    targetLanguages: targetLanguages,
    customDartExecutable: customDartBin,
    stockDartExecutable: stockDartBin,
  );

  final allDatasets = [
    'small.json',
    'twitter.json',
    'citm_catalog.json',
    'canada.json',
  ];
  final datasets = datasetChoice == 'all' ? allDatasets : [datasetChoice];
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
        // 1. Custom Dart SDK - Standard Library AOT
        benchmarkRecords.addAll(
          await _runProcess('$rootDir/dart/bin/bench_aot.exe', [
            '--dataset',
            datasetPath,
            '--mode',
            mode,
            '--impl',
            'convert_utf8',
            '--iterations',
            '$iterations',
            '--warmup',
            '$warmup',
          ], labelPrefix: 'dart_aot'),
        );

        // 2. Custom Dart SDK - package:codable AOT
        benchmarkRecords.addAll(
          await _runProcess('$rootDir/dart/bin/dart_codable.exe', [
            '--dataset',
            datasetPath,
            '--mode',
            mode,
            '--impl',
            'codable',
            '--iterations',
            '$iterations',
            '--warmup',
            '$warmup',
          ], labelPrefix: 'dart_aot'),
        );

        // 3. Stock Dart SDK - Standard Library AOT (if provided)
        if (stockDartBin != null &&
            File('$rootDir/dart/bin/stock_bench_aot.exe').existsSync()) {
          final stockRecords =
              await _runProcess('$rootDir/dart/bin/stock_bench_aot.exe', [
                '--dataset',
                datasetPath,
                '--mode',
                mode,
                '--impl',
                'convert_utf8',
                '--iterations',
                '$iterations',
                '--warmup',
                '$warmup',
              ], labelPrefix: 'dart_stock_aot');
          for (final record in stockRecords) {
            record['language'] = 'dart_stock';
            record['implementation'] = 'stock_convert_utf8';
          }
          benchmarkRecords.addAll(stockRecords);
        }
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

  if (syncCodable) {
    _syncCodableMonorepo(fullResultPayload);
  }
}

Future<void> _buildBinaries({
  required bool dartOnly,
  required List<String> targetLanguages,
  required String customDartExecutable,
  required String? stockDartExecutable,
}) async {
  print('>> Compiling benchmark binaries...');

  // 1. Dart AOT (dart:convert std)
  print('   Compiling Dart AOT (dart:convert std) -> bin/bench_aot.exe...');
  final dartCompile = Process.runSync(
    customDartExecutable,
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
    stderr.writeln(
      'Error: Dart AOT compile error (bench.dart):\n${dartCompile.stderr}',
    );
    exit(dartCompile.exitCode);
  }

  // 2. Dart AOT (package:codable)
  print('   Compiling Dart AOT (package:codable) -> bin/dart_codable.exe...');
  final codableCompile = Process.runSync(
    customDartExecutable,
    [
      'compile',
      'exe',
      '$rootDir/dart/bin/dart_codable.dart',
      '-o',
      '$rootDir/dart/bin/dart_codable.exe',
    ],
    workingDirectory: '$rootDir/dart',
    environment: _toolchainEnv,
  );
  if (codableCompile.exitCode != 0) {
    stderr.writeln(
      'Error: Dart AOT compile error (dart_codable.dart):\n'
      '${codableCompile.stderr}',
    );
    exit(codableCompile.exitCode);
  }

  // 3. Stock Dart SDK (if provided)
  if (stockDartExecutable != null) {
    print('   Compiling Stock Dart AOT -> bin/stock_bench_aot.exe...');
    final stockCompile = Process.runSync(
      stockDartExecutable,
      [
        'compile',
        'exe',
        '$rootDir/dart/bin/bench.dart',
        '-o',
        '$rootDir/dart/bin/stock_bench_aot.exe',
      ],
      workingDirectory: '$rootDir/dart',
      environment: _toolchainEnv,
    );
    if (stockCompile.exitCode != 0) {
      stderr.writeln(
        'Error: Stock Dart AOT compile error:\n${stockCompile.stderr}',
      );
      exit(stockCompile.exitCode);
    }
  }

  // 4. Non-Dart binaries (unless --dart-only)
  if (!dartOnly && targetLanguages.contains('rust')) {
    print('   Compiling Rust release binary (cargo build --release)...');
    final rustCompile = Process.runSync(
      'cargo',
      ['build', '--release'],
      workingDirectory: '$rootDir/rust',
      environment: _toolchainEnv,
    );
    if (rustCompile.exitCode != 0) {
      stderr.writeln('Error: Rust compile error:\n${rustCompile.stderr}');
      exit(rustCompile.exitCode);
    }
  }

  if (!dartOnly && targetLanguages.contains('go')) {
    print('   Compiling Go binary (go build)...');
    final goCompile = Process.runSync(
      'go',
      ['build', '-o', 'json_compare_bench_go', '.'],
      workingDirectory: '$rootDir/go',
      environment: _toolchainEnv,
    );
    if (goCompile.exitCode != 0) {
      stderr.writeln('Error: Go compile error:\n${goCompile.stderr}');
      exit(goCompile.exitCode);
    }
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
  var arch = 'unknown';
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

  if (arch == 'unknown') {
    if (Platform.version.contains('x64')) {
      arch = 'x86_64';
    } else if (Platform.version.contains('arm64')) {
      arch = 'aarch64';
    } else if (Platform.version.contains('ia32')) {
      arch = 'ia32';
    }
  }

  return {
    'os': '$osName ($osVersion)',
    'architecture': arch,
    'cpu_model': cpuModel,
    'logical_cores': logicalCores,
    'total_ram': totalRam,
  };
}

Map<String, dynamic> _harvestToolchainInfo({String? stockDartBin}) {
  var dartVersion = Platform.version;
  // If customDartBin is different, extract its version
  if (customDartBin != Platform.resolvedExecutable) {
    try {
      final vRes = Process.runSync(customDartBin, [
        '--version',
      ], environment: _toolchainEnv);
      final out = vRes.stdout.toString().trim().isNotEmpty
          ? vRes.stdout.toString().trim()
          : vRes.stderr.toString().trim();
      if (out.isNotEmpty) dartVersion = out;
    } catch (_) {}
  }

  var rustVersion = 'Unknown';
  var goVersion = 'Unknown';
  var nodeVersion = 'Unknown';
  final dartPackages = <String, String>{
    'codable': 'package:codable (SDK integration)',
  };
  final rustPackages = <String, String>{};
  final goPackages = <String, String>{'encoding/json': 'Standard Library'};
  final nodePackages = <String, String>{'v8_builtin': 'V8 C++ Built-in'};

  final toolchains = <String, dynamic>{};

  toolchains['dart'] = {
    'version': dartVersion,
    'packages': dartPackages,
    'path': customDartBin,
  };

  if (stockDartBin != null) {
    var stockVersion = 'Unknown';
    try {
      final sRes = Process.runSync(stockDartBin, [
        '--version',
      ], environment: _toolchainEnv);
      final out = sRes.stdout.toString().trim().isNotEmpty
          ? sRes.stdout.toString().trim()
          : sRes.stderr.toString().trim();
      if (out.isNotEmpty) stockVersion = out;
    } catch (_) {}
    toolchains['dart_stock'] = {
      'version': stockVersion,
      'packages': <String, String>{
        'convert': 'Standard Library (stock out-of-the-box)',
      },
      'path': stockDartBin,
    };
  }

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

  toolchains['rust'] = {'version': rustVersion, 'packages': rustPackages};
  toolchains['go'] = {'version': goVersion, 'packages': goPackages};
  toolchains['node'] = {'version': nodeVersion, 'packages': nodePackages};

  return toolchains;
}

String _findNode() {
  final home = Platform.environment['HOME'] ?? '';
  final miseNode = '$home/.local/share/mise/installs/node/24/bin/node';
  if (File(miseNode).existsSync()) return miseNode;
  final miseNode2 = '$home/.local/share/mise/shims/node';
  if (File(miseNode2).existsSync()) return miseNode2;
  try {
    final whichRes = Process.runSync('which', [
      'node',
    ], environment: _toolchainEnv);
    if (whichRes.exitCode == 0) return whichRes.stdout.toString().trim();
  } catch (_) {}
  return 'node';
}

String _findCustomDart() {
  final deployedBin = '$customSdkDeployDir/bin/dart';
  if (File(deployedBin).existsSync()) return deployedBin;
  return Platform.resolvedExecutable;
}

String? _resolveDartBin(String path) {
  var expanded = path;
  final home = Platform.environment['HOME'];
  if (expanded.startsWith('~/') && home != null) {
    expanded = '$home/${expanded.substring(2)}';
  } else if (!expanded.startsWith('/')) {
    final rel = '$rootDir/$expanded';
    if (FileSystemEntity.isDirectorySync(rel) || File(rel).existsSync()) {
      expanded = rel;
    }
  }
  if (FileSystemEntity.isDirectorySync(expanded)) {
    final candidate = '$expanded/bin/dart';
    if (File(candidate).existsSync()) return candidate;
  } else if (File(expanded).existsSync()) {
    return expanded;
  } else if (File(path).existsSync()) {
    return path;
  }
  try {
    final whichRes = Process.runSync('which', [
      path,
    ], environment: _toolchainEnv);
    if (whichRes.exitCode == 0) {
      final found = whichRes.stdout.toString().trim();
      if (File(found).existsSync()) return found;
    }
  } catch (_) {}
  return null;
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

  printToolchain('Dart (Custom SDK)', 'dart');
  if (toolchains.containsKey('dart_stock')) {
    printToolchain('Dart (Stock SDK)', 'dart_stock');
  }
  final rustTc = toolchains['rust'] as Map<String, dynamic>?;
  if (rustTc != null && rustTc['version'] != 'Unknown') {
    printToolchain('Rust', 'rust');
  }
  final goTc = toolchains['go'] as Map<String, dynamic>?;
  if (goTc != null && goTc['version'] != 'Unknown') {
    printToolchain('Go', 'go');
  }
  final nodeTc = toolchains['node'] as Map<String, dynamic>?;
  if (nodeTc != null && nodeTc['version'] != 'Unknown') {
    printToolchain('Node.js', 'node');
  }
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

  final hasStockDart = rawBenchmarks.any(
    (r) =>
        r['language'] == 'dart_stock' ||
        r['runtime'] == 'dart_stock_aot' ||
        r['implementation'] == 'stock_convert_utf8',
  );
  final hasRust = rawBenchmarks.any((r) => r['language'] == 'rust');
  final hasNode = rawBenchmarks.any((r) => r['language'] == 'node');
  final hasGo = rawBenchmarks.any((r) => r['language'] == 'go');

  for (final mode in ['decode', 'encode']) {
    buffer.writeln('## ${mode.toUpperCase()} Throughput Matrix\n');
    buffer.writeln(
      'Higher throughput (MB/s) is better. '
      'Medals (🥇, 🥈, 🥉) indicate top 3 performance per dataset.\n',
    );
    buffer.writeln('<!-- mdformat off -->');

    // Build headers dynamically
    final headerCells = <String>['Dataset'];
    if (hasStockDart) headerCells.add('Dart AOT (Stock std)');
    headerCells.add('Dart AOT (std)');
    headerCells.add('Dart AOT (package:codable)');
    if (hasRust) headerCells.add('Rust (`serde_json`)');
    if (hasNode) headerCells.add('Node.js (V8)');
    if (hasGo) headerCells.add('Go (`encoding/json`)');

    buffer.writeln('| ${headerCells.join(' | ')} |');
    buffer.writeln(
      '| :--- | ${List.filled(headerCells.length - 1, ':---:').join(' | ')} |',
    );

    for (final dataset in datasets) {
      final subset = rawBenchmarks
          .where((r) => r['dataset'] == dataset && r['mode'] == mode)
          .toList();
      if (subset.isEmpty) continue;

      final stockDartBest = subset
          .where(
            (r) =>
                r['language'] == 'dart_stock' ||
                r['runtime'] == 'dart_stock_aot' ||
                r['implementation'] == 'stock_convert_utf8',
          )
          .firstOrNull;

      final dartStdBest = subset
          .where(
            (r) =>
                (r['language'] == 'dart' || r['runtime'] == 'dart_aot') &&
                (r['implementation'] == 'convert_utf8' ||
                    r['implementation'] == 'convert'),
          )
          .firstOrNull;

      final dartCodableBest = subset
          .where(
            (r) =>
                (r['language'] == 'dart' || r['runtime'] == 'dart_aot') &&
                (r['implementation'] == 'codable_utf8' ||
                    r['implementation'] == 'codable' ||
                    r['implementation'] == 'package_codable'),
          )
          .firstOrNull;

      final rustBest = subset.where((r) => r['language'] == 'rust').firstOrNull;
      final nodeBest = subset.where((r) => r['language'] == 'node').firstOrNull;
      final goBest = subset.where((r) => r['language'] == 'go').firstOrNull;

      final stockDartMb =
          (stockDartBest?['throughput_mb_s'] as num?)?.toDouble() ?? 0.0;
      final dartStdMb =
          (dartStdBest?['throughput_mb_s'] as num?)?.toDouble() ?? 0.0;
      final dartCodableMb =
          (dartCodableBest?['throughput_mb_s'] as num?)?.toDouble() ?? 0.0;
      final rustMb = (rustBest?['throughput_mb_s'] as num?)?.toDouble() ?? 0.0;
      final nodeMb = (nodeBest?['throughput_mb_s'] as num?)?.toDouble() ?? 0.0;
      final goMb = (goBest?['throughput_mb_s'] as num?)?.toDouble() ?? 0.0;

      final scores = <ScoreEntry>[
        if (hasStockDart) ScoreEntry('dart_stock', stockDartMb),
        ScoreEntry('dart_std', dartStdMb),
        ScoreEntry('dart_codable', dartCodableMb),
        if (hasRust) ScoreEntry('rust', rustMb),
        if (hasNode) ScoreEntry('node', nodeMb),
        if (hasGo) ScoreEntry('go', goMb),
      ]..sort((a, b) => b.score.compareTo(a.score));

      final winnerMb = scores.first.score > 0 ? scores.first.score : 1.0;

      String medal(String key) {
        if (scores.isNotEmpty && scores[0].name == key && scores[0].score > 0) {
          return '🥇 ';
        }
        if (scores.length >= 2 &&
            scores[1].name == key &&
            scores[1].score > 0) {
          return '🥈 ';
        }
        if (scores.length >= 3 &&
            scores[2].name == key &&
            scores[2].score > 0) {
          return '🥉 ';
        }
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
      final rowCells = <String>['**`$dataset`** (~$sizeStr)'];
      if (hasStockDart) {
        rowCells.add(formatCell(stockDartBest, 'dart_stock', stockDartMb));
      }
      rowCells.add(formatCell(dartStdBest, 'dart_std', dartStdMb));
      rowCells.add(formatCell(dartCodableBest, 'dart_codable', dartCodableMb));
      if (hasRust) rowCells.add(formatCell(rustBest, 'rust', rustMb));
      if (hasNode) rowCells.add(formatCell(nodeBest, 'node', nodeMb));
      if (hasGo) rowCells.add(formatCell(goBest, 'go', goMb));

      buffer.writeln('| ${rowCells.join(' | ')} |');

      // Row 2: % of Winner
      final pctCells = <String>['↳ *% of Winner*'];
      if (hasStockDart) pctCells.add(formatPercent(stockDartMb));
      pctCells.add(formatPercent(dartStdMb));
      pctCells.add(formatPercent(dartCodableMb));
      if (hasRust) pctCells.add(formatPercent(rustMb));
      if (hasNode) pctCells.add(formatPercent(nodeMb));
      if (hasGo) pctCells.add(formatPercent(goMb));

      buffer.writeln('| ${pctCells.join(' | ')} |');
    }
    buffer.writeln('<!-- mdformat on -->\n');
  }

  return buffer.toString();
}

void _syncCodableMonorepo(Map<String, dynamic> fullResultPayload) {
  final matrixFile = File(
    '$codableMonorepoDir/doc/benchmarks/cross_language_benchmark_matrix.json',
  );
  final reportFile = File(
    '$codableMonorepoDir/doc/benchmarks/BENCHMARK_REPORT.md',
  );

  final rawBenchmarks =
      (fullResultPayload['benchmarks'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
  final systemInfo = fullResultPayload['system'] as Map<String, dynamic>? ?? {};

  if (matrixFile.existsSync()) {
    try {
      final matrix =
          jsonDecode(matrixFile.readAsStringSync()) as Map<String, dynamic>;
      matrix['generated_at'] = DateTime.now().toUtc().toIso8601String();
      matrix['host'] = {
        'hostname': Platform.localHostname,
        'cpu':
            '${systemInfo['cpu_model']} '
            '(${systemInfo['logical_cores']} logical cores)',
        'ram': '${systemInfo['total_ram']}',
        'os': '${systemInfo['os']}',
        'architecture': '${systemInfo['architecture']}',
      };

      final datasetsMap =
          matrix['datasets'] as Map<String, dynamic>? ?? <String, dynamic>{};

      for (final record in rawBenchmarks) {
        final dataset = record['dataset'] as String?;
        final mode = record['mode'] as String?;
        if (dataset == null || mode == null) continue;

        final dsEntry =
            datasetsMap.putIfAbsent(dataset, () => <String, dynamic>{})
                as Map<String, dynamic>;
        dsEntry['file_bytes'] = record['file_bytes'];

        final modeEntry =
            dsEntry.putIfAbsent(mode, () => <String, dynamic>{})
                as Map<String, dynamic>;

        final mb = (record['throughput_mb_s'] as num?)?.toDouble() ?? 0.0;
        final iterations = (record['iterations'] as num?)?.toDouble() ?? 1.0;
        final elapsedNs = (record['elapsed_ns'] as num?)?.toDouble() ?? 0.0;
        final latencyMs = (elapsedNs / iterations) / 1e6;
        final latencyMsFormatted = double.parse(
          latencyMs < 0.01
              ? latencyMs.toStringAsFixed(4)
              : latencyMs.toStringAsFixed(2),
        );

        final lang = record['language'] as String?;
        final impl = record['implementation'] as String?;

        if (lang == 'rust') {
          modeEntry['rust_serde_json_typed'] = {
            'throughput_mb_s': mb,
            'latency_ms': latencyMsFormatted,
          };
        } else if (lang == 'node') {
          modeEntry['node_v8_builtin'] = {
            'throughput_mb_s': mb,
            'latency_ms': latencyMsFormatted,
          };
        } else if (lang == 'go') {
          modeEntry['go_encoding_json_typed'] = {
            'throughput_mb_s': mb,
            'latency_ms': latencyMsFormatted,
          };
        } else if (lang == 'dart' && impl == 'convert_utf8') {
          modeEntry['dart_aot_std_convert'] = {
            'throughput_mb_s': mb,
            'latency_ms': latencyMsFormatted,
          };
        } else if (lang == 'dart' &&
            (impl == 'codable' || impl == 'codable_utf8')) {
          modeEntry['dart_aot_package_codable'] = {
            'throughput_mb_s': mb,
            'latency_ms': latencyMsFormatted,
          };
        } else if (lang == 'dart_stock' || impl == 'stock_convert_utf8') {
          modeEntry['dart_aot_stock_convert'] = {
            'throughput_mb_s': mb,
            'latency_ms': latencyMsFormatted,
          };
        }
      }

      matrix['datasets'] = datasetsMap;
      matrixFile.writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(matrix),
      );
      print('>> Synchronized matrix to: ${matrixFile.path}');
    } catch (e) {
      stderr.writeln('Warning: Failed to sync matrix JSON: $e');
    }
  }

  if (reportFile.existsSync()) {
    try {
      final content = reportFile.readAsStringSync();
      final updatedTables = _generateReportDocSection(rawBenchmarks);
      // Replace Section 2 if marker exists
      final s2Start = content.indexOf('## 2. Multi-Language Macro Benchmark');
      final s3Start = content.indexOf('## 3. Kostya');

      if (s2Start != -1 && s3Start != -1) {
        final newContent =
            '${content.substring(0, s2Start)}'
            '$updatedTables\n---\n\n'
            '${content.substring(s3Start)}';
        reportFile.writeAsStringSync(newContent);
        print('>> Synchronized benchmark report to: ${reportFile.path}');
      }
    } catch (e) {
      stderr.writeln('Warning: Failed to sync benchmark report MD: $e');
    }
  }
}

String _generateReportDocSection(List<Map<String, dynamic>> rawBenchmarks) {
  final buffer = StringBuffer();
  buffer.writeln(
    '## 2. Multi-Language Macro Benchmark Matrix (`json_compare_bench`)\n',
  );
  buffer.writeln(
    'Direct throughput and latency comparisons across compiled native '
    'binaries on `${Platform.localHostname}`:\n',
  );

  final datasets = [
    'small.json',
    'twitter.json',
    'citm_catalog.json',
    'canada.json',
  ];

  for (final mode in ['decode', 'encode']) {
    final modeLabel = mode == 'decode'
        ? '2.1 DECODE Matrix'
        : '2.2 ENCODE Matrix';
    buffer.writeln('### $modeLabel\n');
    buffer.writeln('<!-- mdformat off(prevent table wrapping) -->');
    buffer.writeln(
      '| Dataset | Dart AOT (std `dart:convert`) | '
      'Dart AOT (`package:codable`) | '
      'Rust (`serde_json` Typed) | Node.js (V8 Built-in) | '
      'Go (`encoding/json` Typed) |',
    );
    buffer.writeln('| :--- | :---: | :---: | :---: | :---: | :---: |');

    for (final dataset in datasets) {
      final subset = rawBenchmarks
          .where((r) => r['dataset'] == dataset && r['mode'] == mode)
          .toList();
      if (subset.isEmpty) continue;

      final dartStdBest = subset
          .where(
            (r) =>
                (r['language'] == 'dart' || r['runtime'] == 'dart_aot') &&
                (r['implementation'] == 'convert_utf8' ||
                    r['implementation'] == 'convert'),
          )
          .firstOrNull;

      final dartCodableBest = subset
          .where(
            (r) =>
                (r['language'] == 'dart' || r['runtime'] == 'dart_aot') &&
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

      final scores = <ScoreEntry>[
        ScoreEntry('dart_std', dartStdMb),
        ScoreEntry('dart_codable', dartCodableMb),
        ScoreEntry('rust', rustMb),
        ScoreEntry('node', nodeMb),
        ScoreEntry('go', goMb),
      ]..sort((a, b) => b.score.compareTo(a.score));

      final winnerMb = scores.first.score > 0 ? scores.first.score : 1.0;

      String medal(String key) {
        if (scores.isNotEmpty && scores[0].name == key && scores[0].score > 0) {
          return '🥇 ';
        }
        if (scores.length >= 2 &&
            scores[1].name == key &&
            scores[1].score > 0) {
          return '🥈 ';
        }
        if (scores.length >= 3 &&
            scores[2].name == key &&
            scores[2].score > 0) {
          return '🥉 ';
        }
        return '';
      }

      String formatDocCell(Map<String, dynamic>? item, String key, double mb) {
        if (item == null || mb == 0) return 'N/A';
        final m = medal(key);
        final isBold = m.isNotEmpty;
        final iterations = (item['iterations'] as num?)?.toDouble() ?? 1.0;
        final elapsedNs = (item['elapsed_ns'] as num?)?.toDouble() ?? 0.0;
        final fileBytes = (item['file_bytes'] as num?)?.toDouble() ?? 0.0;
        final totalBytes = fileBytes * iterations;
        final elapsedSec = elapsedNs / 1e9;
        final mib = elapsedSec > 0
            ? (totalBytes / (1024 * 1024)) / elapsedSec
            : 0.0;
        final latencyNs = elapsedNs / iterations;
        final latencyStr = latencyNs < 1000
            ? '${latencyNs.toStringAsFixed(0)} ns'
            : (latencyNs < 1000000
                  ? '${(latencyNs / 1000.0).toStringAsFixed(2)} μs'
                  : '${(latencyNs / 1000000.0).toStringAsFixed(2)} ms');

        final formatted =
            '${mib.toStringAsFixed(1)} MiB/s (${mb.toStringAsFixed(1)} MB/s, $latencyStr)';
        return isBold ? '$m**$formatted**' : formatted;
      }

      String formatPercent(double mb) {
        if (mb == 0) return 'N/A';
        final pct = (mb / winnerMb * 100.0).toStringAsFixed(1);
        final isWinner = mb == winnerMb;
        return isWinner ? '**$pct%**' : '$pct%';
      }

      final fileBytes = (subset.first['file_bytes'] as num?)?.toInt() ?? 0;
      final sizeStr = fileBytes < 1024
          ? '$fileBytes B'
          : (fileBytes < 1048576
                ? '${(fileBytes / 1024.0).toStringAsFixed(1)} KB'
                : '${(fileBytes / 1048576.0).toStringAsFixed(2)} MB');

      buffer.writeln(
        '| **`$dataset`** ($sizeStr) | '
        '${formatDocCell(dartStdBest, 'dart_std', dartStdMb)} | '
        '${formatDocCell(dartCodableBest, 'dart_codable', dartCodableMb)} | '
        '${formatDocCell(rustBest, 'rust', rustMb)} | '
        '${formatDocCell(nodeBest, 'node', nodeMb)} | '
        '${formatDocCell(goBest, 'go', goMb)} |',
      );

      buffer.writeln(
        '| ↳ *% of Winner* | '
        '${formatPercent(dartStdMb)} | '
        '${formatPercent(dartCodableMb)} | '
        '${formatPercent(rustMb)} | '
        '${formatPercent(nodeMb)} | '
        '${formatPercent(goMb)} |',
      );
    }
    buffer.writeln('<!-- mdformat on -->\n');
  }

  return buffer.toString();
}

class ScoreEntry {
  final String name;
  final double score;

  ScoreEntry(this.name, this.score);
}
