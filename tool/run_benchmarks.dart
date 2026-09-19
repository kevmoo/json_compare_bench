import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:bench_press/bench_press.dart';

final rootDir = File(Platform.script.toFilePath()).parent.parent.path;
const sdkRepoDir =
    '/usr/local/google/home/kevmoo/github/dart-sdk/core/agent-json-utf8-kernels/sdk';
final customSdkDeployDir =
    '${Platform.environment['HOME'] ?? ''}/.local/share/dart-sdk-json-utf8-kernels/dart-sdk';
const codableMonorepoDir =
    '/usr/local/google/home/kevmoo/github/kevmoo/codable.dart';

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
          'Only compiles and executes Dart benchmarks (Dart Codable AOT, '
          'Dart json_serializable AOT, Dart Std AOT, and Stock Dart if '
          'provided), skipping Rust, Go, and Node.js.',
    )
    ..addOption(
      'stock-sdk',
      help:
          'Path to a stock/unmodified Dart SDK binary or directory to '
          'benchmark baseline out-of-the-box Dart AOT (both json_serializable '
          'and std_convert) as an explicit comparative tier.',
    )
    ..addFlag(
      'gen',
      abbr: 'g',
      defaultsTo: false,
      negatable: false,
      help:
          'Runs build_runner build --delete-conflicting-outputs across '
          'dart/ and codable.dart before running.',
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
      defaultsTo: false,
      help:
          'Synchronize cross_language_benchmark_matrix.json and '
          'BENCHMARK_REPORT.md in codable.dart if present.',
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

  // 2. In codable.dart/pkgs/codable_benchmarks
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
        final rustRecords = await _runProcess(
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
        );
        for (final r in rustRecords) {
          r['semantic_category'] = 'typed_struct';
        }
        benchmarkRecords.addAll(rustRecords);
      }

      if (targetLanguages.contains('go')) {
        final goRecords =
            await _runProcess('$rootDir/go/json_compare_bench_go', [
              '--dataset',
              datasetPath,
              '--mode',
              mode,
              '--iterations',
              '$iterations',
              '--warmup',
              '$warmup',
            ]);
        for (final r in goRecords) {
          r['semantic_category'] = 'typed_struct';
        }
        benchmarkRecords.addAll(goRecords);
      }

      if (targetLanguages.contains('node')) {
        final nodeRecords = await _runProcess(nodeBin, [
          '$rootDir/node/index.mjs',
          '--dataset',
          datasetPath,
          '--mode',
          mode,
          '--iterations',
          '$iterations',
          '--warmup',
          '$warmup',
        ]);
        for (final r in nodeRecords) {
          r['semantic_category'] = 'untyped_dom';
          r['note'] = 'Untyped JS Object';
        }
        benchmarkRecords.addAll(nodeRecords);
      }

      if (targetLanguages.contains('dart')) {
        // 1. Custom Dart SDK - Standard Library AOT (Untyped Map/DOM)
        final stdRecords =
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
            ], labelPrefix: 'dart_aot');
        for (final r in stdRecords) {
          r['semantic_category'] = 'untyped_dom';
          r['note'] = 'Untyped Map/DOM';
        }
        benchmarkRecords.addAll(stdRecords);

        // 2. Custom Dart SDK - json_serializable AOT (Typed Struct)
        final jsRecords =
            await _runProcess('$rootDir/dart/bin/dart_json_serializable.exe', [
              '--dataset',
              datasetPath,
              '--mode',
              mode,
              '--impl',
              'json_serializable',
              '--iterations',
              '$iterations',
              '--warmup',
              '$warmup',
            ], labelPrefix: 'dart_aot');
        for (final r in jsRecords) {
          r['semantic_category'] = 'typed_struct';
        }
        benchmarkRecords.addAll(jsRecords);

        // 3. Custom Dart SDK - package:codable AOT (Typed Struct)
        final codableRecords =
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
            ], labelPrefix: 'dart_aot');
        for (final r in codableRecords) {
          r['semantic_category'] = 'typed_struct';
        }
        benchmarkRecords.addAll(codableRecords);

        // 4. Stock Dart SDK - Standard Library AOT (Untyped Map/DOM)
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
            record['semantic_category'] = 'untyped_dom';
            record['note'] = 'Untyped Map/DOM';
          }
          benchmarkRecords.addAll(stockRecords);
        }

        // 5. Stock Dart SDK - json_serializable AOT (Typed Struct)
        if (stockDartBin != null &&
            File(
              '$rootDir/dart/bin/stock_json_serializable_aot.exe',
            ).existsSync()) {
          final stockJsRecords = await _runProcess(
            '$rootDir/dart/bin/stock_json_serializable_aot.exe',
            [
              '--dataset',
              datasetPath,
              '--mode',
              mode,
              '--impl',
              'stock_json_serializable',
              '--iterations',
              '$iterations',
              '--warmup',
              '$warmup',
            ],
            labelPrefix: 'dart_stock_aot',
          );
          for (final record in stockJsRecords) {
            record['language'] = 'dart_stock';
            record['implementation'] = 'stock_json_serializable';
            record['semantic_category'] = 'typed_struct';
          }
          benchmarkRecords.addAll(stockJsRecords);
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

  // 1. Dart AOT (dart:convert std - Untyped Map/DOM)
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

  // 2. Dart AOT (json_serializable - Typed)
  print(
    '   Compiling Dart AOT (json_serializable) -> '
    'bin/dart_json_serializable.exe...',
  );
  final jsCompile = Process.runSync(
    customDartExecutable,
    [
      'compile',
      'exe',
      '$rootDir/dart/bin/dart_json_serializable.dart',
      '-o',
      '$rootDir/dart/bin/dart_json_serializable.exe',
    ],
    workingDirectory: '$rootDir/dart',
    environment: _toolchainEnv,
  );
  if (jsCompile.exitCode != 0) {
    stderr.writeln(
      'Error: Dart AOT compile error (dart_json_serializable.dart):\n'
      '${jsCompile.stderr}',
    );
    exit(jsCompile.exitCode);
  }

  // 3. Dart AOT (package:codable - Typed)
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

  // 4. Stock Dart SDK (if provided)
  if (stockDartExecutable != null) {
    print(
      '   Compiling Stock Dart AOT (std_convert) -> bin/stock_bench_aot.exe...',
    );
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

    print(
      '   Compiling Stock Dart AOT (json_serializable) -> '
      'bin/stock_json_serializable_aot.exe...',
    );
    final stockJsCompile = Process.runSync(
      stockDartExecutable,
      [
        'compile',
        'exe',
        '$rootDir/dart/bin/dart_json_serializable.dart',
        '-o',
        '$rootDir/dart/bin/stock_json_serializable_aot.exe',
      ],
      workingDirectory: '$rootDir/dart',
      environment: _toolchainEnv,
    );
    if (stockJsCompile.exitCode != 0) {
      stderr.writeln(
        'Error: Stock Dart json_serializable AOT compile error:\n'
        '${stockJsCompile.stderr}',
      );
      exit(stockJsCompile.exitCode);
    }
  }

  // 5. Non-Dart binaries (unless --dart-only)
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
  int trials = 15,
}) async {
  final keys = <String>{};
  final rawSamplesByKey = <String, List<double>>{};
  final extraDataByKey = <String, Map<String, dynamic>>{};

  for (var t = 0; t < trials; t++) {
    try {
      final runExec = Platform.isLinux ? 'taskset' : executable;
      final runArgs = Platform.isLinux
          ? ['-c', '2', executable, ...args]
          : args;
      final res = await Process.run(
        runExec,
        runArgs,
        environment: _toolchainEnv,
      );
      if (res.exitCode != 0) {
        stderr.writeln('Error running $executable: ${res.stderr}');
        continue;
      }

      final lines = res.stdout.toString().trim().split('\n');
      for (final line in lines) {
        if (line.trim().isEmpty) continue;
        try {
          final data = jsonDecode(line.trim()) as Map<String, dynamic>;
          if (labelPrefix != null) {
            data['runtime'] = labelPrefix;
          }
          final key =
              '${data['language']}:${data['implementation']}:'
              '${data['dataset']}:${data['mode']}';

          keys.add(key);
          extraDataByKey[key] = data; // Keep latest metadata

          final iterations = (data['iterations'] as num).toDouble();
          final elapsedNs = (data['elapsed_ns'] as num).toDouble();

          rawSamplesByKey
              .putIfAbsent(key, () => [])
              .add(elapsedNs / iterations);
        } catch (e) {
          stderr.writeln('Failed to parse line: $line ($e)');
        }
      }
    } catch (e) {
      stderr.writeln('Process execution error for $executable: $e');
    }
  }

  final results = <Map<String, dynamic>>[];
  for (final key in keys) {
    final samplesNs = rawSamplesByKey[key]!;
    final data = extraDataByKey[key]!;
    final fileBytes = (data['file_bytes'] as num).toInt();

    final metrics = BenchmarkMetrics.fromSamples(samplesNs);

    // Evaluate throughput per second using the median latency
    data['throughput_mb_s'] = 0.0;
    if (metrics.medianNs > 0) {
      final secondsPerOp = metrics.medianNs / 1e9;
      final bytesPerSecond = fileBytes / secondsPerOp;
      data['throughput_mb_s'] = bytesPerSecond / (1024 * 1024);
    }

    data['elapsed_ns'] =
        metrics.medianNs; // Replace for _formatLatency formatting
    data['iterations'] = 1.0; // so _formatLatency returns medianNs

    data['raw_samples_ns'] = samplesNs;
    data['is_robust_stable'] = metrics.isRobustStable;
    data['metrics'] = metrics.toJson();
    results.add(data);
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
    'codable': 'package:codable (SDK Layer 1 native substrate)',
    'json_serializable': 'package:json_serializable (Typed fromJson/toJson)',
    'convert': 'dart:convert (Untyped Map/DOM)',
  };
  final rustPackages = <String, String>{};
  final goPackages = <String, String>{'encoding/json': 'Standard Library'};
  final nodePackages = <String, String>{
    'v8_builtin': 'V8 C++ Built-in (Untyped JS Object)',
  };

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
        'json_serializable':
            'package:json_serializable (Typed fromJson/toJson)',
        'convert': 'Standard Library (Untyped Map/DOM)',
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

String _formatLatency(Map<String, dynamic>? item) {
  if (item == null) return 'N/A';
  final iterations = (item['iterations'] as num?)?.toDouble() ?? 1.0;
  final elapsedNs = (item['elapsed_ns'] as num?)?.toDouble() ?? 0.0;
  if (elapsedNs <= 0 || iterations <= 0) return 'N/A';
  final latencyNs = elapsedNs / iterations;
  if (latencyNs < 1000) {
    return '${latencyNs.toStringAsFixed(0)} ns';
  } else if (latencyNs < 1000000) {
    return '${(latencyNs / 1000.0).toStringAsFixed(2)} µs';
  } else {
    return '${(latencyNs / 1000000.0).toStringAsFixed(2)} ms';
  }
}

String _generateMarkdownReport(Map<String, dynamic> data) {
  final buffer = StringBuffer();
  final timestamp = data['timestamp'] ?? 'Unknown';
  final system = data['system'] as Map<String, dynamic>? ?? {};
  final toolchains = data['toolchains'] as Map<String, dynamic>? ?? {};
  final rawBenchmarks = (data['benchmarks'] as List<dynamic>? ?? [])
      .cast<Map<String, dynamic>>();

  buffer.writeln('# Cross-Language JSON Serialization Benchmark Results\n');
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

  printToolchain('New Dart (Custom SDK)', 'dart');
  if (toolchains.containsKey('dart_stock')) {
    printToolchain('Stock Dart (Baseline SDK)', 'dart_stock');
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
    '> [!IMPORTANT]\n'
    '> **Typed Struct Serialization vs. Untyped DOM Parsing**:\n'
    '> * **Typed Struct Serialization (`Rust serde_json`, `Go encoding/json`, '
    '`Stock Dart + json_serializable`, `New Dart + json_serializable`, '
    '`New Dart + package:codable`)**: '
    'Deserializes raw UTF-8 bytes (`Uint8List` / `&[u8]` / `[]byte`) into '
    'strongly-typed domain model objects (`SmallDocument`, `TwitterResponse`, '
    '`CitmCatalog`, `CanadaFeatureCollection`) and serializes those '
    'strongly-typed models back to UTF-8 bytes.\n'
    '> * **Untyped DOM Parsing (`Node.js V8`, `Stock Dart std_convert`, '
    '`New Dart std_convert`)**: '
    'Only parses UTF-8 bytes into an untyped dynamic AST '
    '(`Map<String, dynamic>` in Dart or raw V8 JS `Object` in Node.js), '
    'completely skipping typed `.fromJson(...)` / `.toJson()` model '
    'hydration and validation.\n'
    '> * **`New Dart + package:codable`**: Uses single-pass streaming '
    'pull/push readers/writers (`JsonCodableDecoder.fromBytes` / '
    '`JsonCodableEncoder.toBytes`) backed by the native `dart:convert` '
    'Layer 1 UTF-8 token substrate, bypassing intermediate '
    '`Map<String, dynamic>` AST allocation entirely.\n',
  );

  final datasets = rawBenchmarks
      .map((r) => r['dataset'] as String)
      .toSet()
      .toList();

  Map<String, dynamic>? findRecord(
    List<Map<String, dynamic>> subset,
    bool Function(Map<String, dynamic>) predicate,
  ) => subset.where(predicate).firstOrNull;

  for (final mode in ['decode', 'encode']) {
    final modeUpper = mode.toUpperCase();
    final secNum = mode == 'decode' ? '1' : '2';
    final dirDesc = mode == 'decode'
        ? 'deserialization (UTF-8 bytes -> Typed Structs)'
        : 'serialization (Typed Structs -> UTF-8 bytes)';
    buffer.writeln(
      '## 1.$secNum $modeUpper — Apples-to-Apples Typed Struct Matrix\n',
    );
    buffer.writeln(
      'Strongly-typed domain model $dirDesc. '
      'Each cell displays **Throughput (`MiB/s`)** and '
      '**Single-Pass Latency (`ms`/`µs`)**. '
      'Medals (🥇, 🥈, 🥉) rank the top 3 typed struct contenders '
      'per dataset.\n',
    );
    buffer.writeln('<!-- mdformat off -->');
    buffer.writeln(
      '| Dataset | Rust (`serde_json` Typed) | Go (`encoding/json` Typed) | '
      'Stock Dart + `json_serializable` (Typed) | '
      'New Dart + `json_serializable` (Typed) | '
      'New Dart + `package:codable` (Typed) | '
      '`codable` vs Stock `json_serializable` | '
      '`codable` vs Go `encoding/json` |',
    );
    buffer.writeln(
      '| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |',
    );

    for (final dataset in datasets) {
      final subset = rawBenchmarks
          .where((r) => r['dataset'] == dataset && r['mode'] == mode)
          .toList();
      if (subset.isEmpty) continue;

      final rustRec = findRecord(subset, (r) => r['language'] == 'rust');
      final goRec = findRecord(subset, (r) => r['language'] == 'go');
      final stockJsRec = findRecord(
        subset,
        (r) => r['implementation'] == 'stock_json_serializable',
      );
      final newJsRec = findRecord(
        subset,
        (r) =>
            r['language'] == 'dart' &&
            r['implementation'] == 'json_serializable',
      );
      final codableRec = findRecord(
        subset,
        (r) =>
            r['language'] == 'dart' &&
            (r['implementation'] == 'codable' ||
                r['implementation'] == 'codable_utf8' ||
                r['implementation'] == 'package_codable'),
      );

      final rustMb = (rustRec?['throughput_mb_s'] as num?)?.toDouble() ?? 0.0;
      final goMb = (goRec?['throughput_mb_s'] as num?)?.toDouble() ?? 0.0;
      final stockJsMb =
          (stockJsRec?['throughput_mb_s'] as num?)?.toDouble() ?? 0.0;
      final newJsMb = (newJsRec?['throughput_mb_s'] as num?)?.toDouble() ?? 0.0;
      final codableMb =
          (codableRec?['throughput_mb_s'] as num?)?.toDouble() ?? 0.0;

      final typedScores = <ScoreEntry>[
        if (rustMb > 0) ScoreEntry('rust', rustMb),
        if (goMb > 0) ScoreEntry('go', goMb),
        if (stockJsMb > 0) ScoreEntry('stock_js', stockJsMb),
        if (newJsMb > 0) ScoreEntry('new_js', newJsMb),
        if (codableMb > 0) ScoreEntry('codable', codableMb),
      ]..sort((a, b) => b.score.compareTo(a.score));

      String typedMedal(String key) {
        if (typedScores.isNotEmpty && typedScores[0].name == key) return '🥇 ';
        if (typedScores.length >= 2 && typedScores[1].name == key) return '🥈 ';
        if (typedScores.length >= 3 && typedScores[2].name == key) return '🥉 ';
        return '';
      }

      String formatTypedCell(
        Map<String, dynamic>? item,
        String key,
        double mb,
      ) {
        if (item == null || mb == 0) return 'N/A';
        final m = typedMedal(key);
        final lat = _formatLatency(item);
        final cell = '${mb.toStringAsFixed(1)} MB/s ($lat)';
        final isUnstable = item['is_robust_stable'] == false;
        if (isUnstable) return '$cell ❓';
        return m.isNotEmpty ? '$m**$cell**' : cell;
      }

      String formatComparison(
        Map<String, dynamic>? baseRec,
        Map<String, dynamic>? curRec,
      ) {
        if (baseRec == null || curRec == null) return 'N/A';
        final baseSamples =
            (baseRec['raw_samples_ns'] as List<dynamic>?)?.cast<double>() ?? [];
        final curSamples =
            (curRec['raw_samples_ns'] as List<dynamic>?)?.cast<double>() ?? [];
        final baseStable = baseRec['is_robust_stable'] == true;
        final curStable = curRec['is_robust_stable'] == true;

        if (!baseStable ||
            !curStable ||
            baseSamples.length < 2 ||
            curSamples.length < 2) {
          return '❓ Unresolved';
        }

        final baseMedian = (baseRec['elapsed_ns'] as num).toDouble();
        final curMedian = (curRec['elapsed_ns'] as num).toDouble();
        if (curMedian <= 0 || baseMedian <= 0) return 'N/A';

        final f = FiellerInterval.compute(
          sampleA: baseSamples,
          sampleB: curSamples,
        );
        if (!f.isValid || f.lowerBound.isNaN || f.upperBound.isNaN) {
          return '❓ Unresolved';
        }
        final speedup = baseMedian / curMedian;
        final low = f.lowerBound.toStringAsFixed(2);
        final high = f.upperBound.toStringAsFixed(2);
        return '**${speedup.toStringAsFixed(2)}x** [ ${low}x - ${high}x ]';
      }

      final vsStockJs = formatComparison(stockJsRec, codableRec);
      final vsGo = formatComparison(goRec, codableRec);

      final fileBytes = (subset.first['file_bytes'] as num?)?.toInt() ?? 0;
      final sizeStr = fileBytes > 1048576
          ? '${(fileBytes / 1048576).toStringAsFixed(2)} MB'
          : (fileBytes >= 1024
                ? '${(fileBytes / 1024).toStringAsFixed(1)} KB'
                : '$fileBytes B');

      buffer.writeln(
        '| **`$dataset`** ($sizeStr) | '
        '${formatTypedCell(rustRec, 'rust', rustMb)} | '
        '${formatTypedCell(goRec, 'go', goMb)} | '
        '${formatTypedCell(stockJsRec, 'stock_js', stockJsMb)} | '
        '${formatTypedCell(newJsRec, 'new_js', newJsMb)} | '
        '${formatTypedCell(codableRec, 'codable', codableMb)} | '
        '$vsStockJs | '
        '$vsGo |',
      );
    }
    buffer.writeln('<!-- mdformat on -->\n');
  }

  for (final mode in ['decode', 'encode']) {
    final modeUpper = mode.toUpperCase();
    final secNum = mode == 'decode' ? '1' : '2';
    buffer.writeln(
      '## 2.$secNum $modeUpper — Complete Cross-Language Matrix '
      '(Typed Structs + Untyped DOM)\n',
    );
    buffer.writeln(
      'Includes both **Typed Struct** contenders (`Rust`, `Go`, '
      '`Dart json_serializable`, `Dart package:codable`) and '
      '**Untyped DOM** parsers (`Node.js V8 [Untyped JS Object]`, '
      '`Stock/New Dart std_convert [Untyped Map/DOM]`). '
      'Medals (🥇, 🥈, 🥉) indicate top 3 raw throughput across all 8 '
      'columns.\n',
    );
    buffer.writeln('<!-- mdformat off -->');
    buffer.writeln(
      '| Dataset | Rust (`serde_json` Typed) | Go (`encoding/json` Typed) | '
      'Node.js V8 (`Untyped JS Object`) | '
      'Stock Dart + `json_serializable` (`Typed`) | '
      'New Dart + `json_serializable` (`Typed`) | '
      'New Dart + `package:codable` (`Typed`) | '
      'Stock Dart `std_convert` (`Untyped Map/DOM`) | '
      'New Dart `std_convert` (`Untyped Map/DOM`) |',
    );
    buffer.writeln(
      '| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | '
      ':---: |',
    );

    for (final dataset in datasets) {
      final subset = rawBenchmarks
          .where((r) => r['dataset'] == dataset && r['mode'] == mode)
          .toList();
      if (subset.isEmpty) continue;

      final rustRec = findRecord(subset, (r) => r['language'] == 'rust');
      final goRec = findRecord(subset, (r) => r['language'] == 'go');
      final nodeRec = findRecord(subset, (r) => r['language'] == 'node');
      final stockJsRec = findRecord(
        subset,
        (r) => r['implementation'] == 'stock_json_serializable',
      );
      final newJsRec = findRecord(
        subset,
        (r) =>
            r['language'] == 'dart' &&
            r['implementation'] == 'json_serializable',
      );
      final codableRec = findRecord(
        subset,
        (r) =>
            r['language'] == 'dart' &&
            (r['implementation'] == 'codable' ||
                r['implementation'] == 'codable_utf8' ||
                r['implementation'] == 'package_codable'),
      );
      final stockStdRec = findRecord(
        subset,
        (r) => r['implementation'] == 'stock_convert_utf8',
      );
      final newStdRec = findRecord(
        subset,
        (r) =>
            r['language'] == 'dart' &&
            (r['implementation'] == 'convert_utf8' ||
                r['implementation'] == 'convert'),
      );

      final rustMb = (rustRec?['throughput_mb_s'] as num?)?.toDouble() ?? 0.0;
      final goMb = (goRec?['throughput_mb_s'] as num?)?.toDouble() ?? 0.0;
      final nodeMb = (nodeRec?['throughput_mb_s'] as num?)?.toDouble() ?? 0.0;
      final stockJsMb =
          (stockJsRec?['throughput_mb_s'] as num?)?.toDouble() ?? 0.0;
      final newJsMb = (newJsRec?['throughput_mb_s'] as num?)?.toDouble() ?? 0.0;
      final codableMb =
          (codableRec?['throughput_mb_s'] as num?)?.toDouble() ?? 0.0;
      final stockStdMb =
          (stockStdRec?['throughput_mb_s'] as num?)?.toDouble() ?? 0.0;
      final newStdMb =
          (newStdRec?['throughput_mb_s'] as num?)?.toDouble() ?? 0.0;

      final allScores = <ScoreEntry>[
        if (rustMb > 0) ScoreEntry('rust', rustMb),
        if (goMb > 0) ScoreEntry('go', goMb),
        if (nodeMb > 0) ScoreEntry('node', nodeMb),
        if (stockJsMb > 0) ScoreEntry('stock_js', stockJsMb),
        if (newJsMb > 0) ScoreEntry('new_js', newJsMb),
        if (codableMb > 0) ScoreEntry('codable', codableMb),
        if (stockStdMb > 0) ScoreEntry('stock_std', stockStdMb),
        if (newStdMb > 0) ScoreEntry('new_std', newStdMb),
      ]..sort((a, b) => b.score.compareTo(a.score));

      final winnerMb = allScores.isNotEmpty && allScores.first.score > 0
          ? allScores.first.score
          : 1.0;

      String medal(String key) {
        if (allScores.isNotEmpty && allScores[0].name == key) return '🥇 ';
        if (allScores.length >= 2 && allScores[1].name == key) return '🥈 ';
        if (allScores.length >= 3 && allScores[2].name == key) return '🥉 ';
        return '';
      }

      String formatCell(Map<String, dynamic>? item, String key, double mb) {
        if (item == null || mb == 0) return 'N/A';
        final m = medal(key);
        final lat = _formatLatency(item);
        final mbStr = '${mb.toStringAsFixed(1)} MB/s ($lat)';
        final isUnstable = item['is_robust_stable'] == false;
        if (isUnstable) return '$mbStr ❓';
        return m.isNotEmpty ? '$m**$mbStr**' : mbStr;
      }

      String formatPercent(double mb) {
        if (mb == 0) return 'N/A';
        final pct = (mb / winnerMb * 100.0).toStringAsFixed(1);
        final isWinner = mb == winnerMb;
        return isWinner ? '**$pct%**' : '$pct%';
      }

      final fileBytes = (subset.first['file_bytes'] as num?)?.toInt() ?? 0;
      final sizeStr = fileBytes > 1048576
          ? '${(fileBytes / 1048576).toStringAsFixed(2)} MB'
          : (fileBytes >= 1024
                ? '${(fileBytes / 1024).toStringAsFixed(1)} KB'
                : '$fileBytes B');

      buffer.writeln(
        '| **`$dataset`** ($sizeStr) | '
        '${formatCell(rustRec, 'rust', rustMb)} | '
        '${formatCell(goRec, 'go', goMb)} | '
        '${formatCell(nodeRec, 'node', nodeMb)} | '
        '${formatCell(stockJsRec, 'stock_js', stockJsMb)} | '
        '${formatCell(newJsRec, 'new_js', newJsMb)} | '
        '${formatCell(codableRec, 'codable', codableMb)} | '
        '${formatCell(stockStdRec, 'stock_std', stockStdMb)} | '
        '${formatCell(newStdRec, 'new_std', newStdMb)} |',
      );

      buffer.writeln(
        '| ↳ *% of Winner* | '
        '${formatPercent(rustMb)} | '
        '${formatPercent(goMb)} | '
        '${formatPercent(nodeMb)} | '
        '${formatPercent(stockJsMb)} | '
        '${formatPercent(newJsMb)} | '
        '${formatPercent(codableMb)} | '
        '${formatPercent(stockStdMb)} | '
        '${formatPercent(newStdMb)} |',
      );
    }
    buffer.writeln('<!-- mdformat on -->\n');
  }

  return buffer.toString();
}

void _syncCodableMonorepo(Map<String, dynamic> fullResultPayload) {
  final matrixFile = File(
    '$codableMonorepoDir/doc/benchmarks/cross_language_benchmark_matrix.json',
  );

  final oldReportFile = File(
    '$codableMonorepoDir/doc/benchmarks/BENCHMARK_REPORT.md',
  );
  final reportFile = File(
    '$codableMonorepoDir/doc/benchmarks/CROSS_LANGUAGE_REPORT.md',
  );

  if (oldReportFile.existsSync()) {
    oldReportFile.renameSync(reportFile.path);
  }

  final rawBenchmarks =
      (fullResultPayload['benchmarks'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
  final systemInfo = fullResultPayload['system'] as Map<String, dynamic>? ?? {};

  if (matrixFile.existsSync()) {
    try {
      final matrix =
          jsonDecode(matrixFile.readAsStringSync()) as Map<String, dynamic>;
      // Add data tracking etc if required
      matrixFile.writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(matrix),
      );
    } catch (e) {}
  }

  // Pure deterministic generation
  final markdownOutput = _generateMarkdownReport(fullResultPayload);
  reportFile.writeAsStringSync(markdownOutput);
  print('>> Synchronized benchmark report to: ${reportFile.path}');
}

class ScoreEntry {
  final String name;
  final double score;

  ScoreEntry(this.name, this.score);
}
