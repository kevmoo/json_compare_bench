import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('N == 1 disqualifies from stable and appends ? to % of Winner', () {
    final results = {
      'raw_benchmarks': [
        {
          'language': 'dart',
          'implementation': 'json_serializable',
          'dataset': 'small.json',
          'mode': 'decode',
          'iterations': 100,
          'file_bytes': 1024,
          'total_bytes': 102400,
          'elapsed_ns': 1000000,
          'throughput_mb_s': 500.0,
          'ns_per_op': 10000,
          'raw_samples_ns': [1000000, 1000001],
          'is_robust_stable': true,
        },
        {
          'language': 'rust',
          'implementation': 'rust',
          'dataset': 'small.json',
          'mode': 'decode',
          'iterations': 100,
          'file_bytes': 1024,
          'total_bytes': 102400,
          'elapsed_ns': 500000,
          'throughput_mb_s': 1000.0,
          'ns_per_op': 5000,
          'raw_samples_ns': [500000],
          'is_robust_stable': true,
        },
      ],
    };

    File('test/test_out_results.json').writeAsStringSync(jsonEncode(results));

    // Run the generator
    final result = Process.runSync('dart', [
      'tool/run_benchmarks.dart',
      '--from-json',
      'test/test_out_results.json',
    ]);

    expect(result.exitCode, 0, reason: result.stderr.toString());

    // Check RESULTS.md or the output
    final md = File('RESULTS.md').readAsStringSync();

    // Rust should have the ❓ mark and shouldn't get a medal if it's unstable,
    expect(md.contains('❓'), isTrue);
    expect(md.contains('200.0% ❓'), isTrue);
  });
}
