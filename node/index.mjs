import fs from 'node:fs';
import path from 'node:path';
import { hrtime } from 'node:process';

const args = process.argv.slice(2);
let datasetPath = '';
let mode = 'decode';
let implChoice = 'v8_builtin';
let iterations = 100;
let warmup = 10;

for (let i = 0; i < args.length; i++) {
  const arg = args[i];
  if (arg === '--dataset' || arg === '-d') {
    datasetPath = args[++i];
  } else if (arg === '--mode' || arg === '-m') {
    mode = args[++i];
  } else if (arg === '--impl' || arg === '-i') {
    implChoice = args[++i];
  } else if (arg === '--iterations' || arg === '-n') {
    iterations = parseInt(args[++i], 10);
  } else if (arg === '--warmup' || arg === '-w') {
    warmup = parseInt(args[++i], 10);
  }
}

if (!datasetPath) {
  console.error('Usage: node index.mjs --dataset <path> [--mode <decode|encode>] [--iterations <N>] [--warmup <N>]');
  process.exit(1);
}

const buffer = fs.readFileSync(datasetPath);
const stringSource = buffer.toString('utf-8');
const datasetName = path.basename(datasetPath);
const parsedObject = JSON.parse(stringSource);

let blackhole;

function runPass() {
  if (mode === 'decode') {
    blackhole = JSON.parse(stringSource);
  } else {
    blackhole = JSON.stringify(parsedObject);
  }
}

// Warmup
for (let i = 0; i < warmup; i++) {
  runPass();
}

// Measured run
const start = hrtime.bigint();
for (let i = 0; i < iterations; i++) {
  runPass();
}
const end = hrtime.bigint();

const elapsedNs = Number(end - start);
const elapsedMicros = elapsedNs / 1000.0;
const totalBytes = buffer.length * iterations;
const throughputMbPerSec = (totalBytes / (1024.0 * 1024.0)) / (elapsedMicros / 1000000.0);
const nsPerOp = Math.floor(elapsedNs / iterations);

const output = {
  language: 'node',
  implementation: implChoice,
  dataset: datasetName,
  mode: mode,
  iterations: iterations,
  file_bytes: buffer.length,
  total_bytes: totalBytes,
  elapsed_ns: elapsedNs,
  throughput_mb_s: parseFloat(throughputMbPerSec.toFixed(2)),
  ns_per_op: nsPerOp,
};

console.log(JSON.stringify(output));
