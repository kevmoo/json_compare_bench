use std::env;
use std::fs;
use std::path::Path;
use std::process;
use std::time::Instant;

fn main() {
    let args: Vec<String> = env::args().collect();
    let mut dataset_path = String::new();
    let mut mode = String::from("decode");
    let mut impl_choice = String::from("serde_json");
    let mut iterations: usize = 100;
    let mut warmup: usize = 10;

    let mut i = 1;
    while i < args.len() {
        match args[i].as_str() {
            "--dataset" | "-d" if i + 1 < args.len() => {
                dataset_path = args[i + 1].clone();
                i += 1;
            }
            "--mode" | "-m" if i + 1 < args.len() => {
                mode = args[i + 1].clone();
                i += 1;
            }
            "--impl" | "-i" if i + 1 < args.len() => {
                impl_choice = args[i + 1].clone();
                i += 1;
            }
            "--iterations" | "-n" if i + 1 < args.len() => {
                iterations = args[i + 1].parse().unwrap_or(100);
                i += 1;
            }
            "--warmup" | "-w" if i + 1 < args.len() => {
                warmup = args[i + 1].parse().unwrap_or(10);
                i += 1;
            }
            _ => {}
        }
        i += 1;
    }

    if dataset_path.is_empty() {
        eprintln!("Usage: json_compare_bench_rust --dataset <path> [--mode <decode|encode>] [--iterations <N>] [--warmup <N>]");
        process::exit(1);
    }

    let bytes = match fs::read(&dataset_path) {
        Ok(b) => b,
        Err(e) => {
            eprintln!("Failed to read dataset '{}': {}", dataset_path, e);
            process::exit(1);
        }
    };

    let dataset_name = Path::new(&dataset_path)
        .file_name()
        .and_then(|n| n.to_str())
        .unwrap_or("unknown")
        .to_string();

    let string_source = match String::from_utf8(bytes.clone()) {
        Ok(s) => s,
        Err(e) => {
            eprintln!("Invalid UTF-8 in dataset: {}", e);
            process::exit(1);
        }
    };

    let parsed_value: serde_json::Value = serde_json::from_str(&string_source).expect("Valid JSON");

    let run_pass = || {
        if mode == "decode" {
            let val: serde_json::Value = serde_json::from_slice(&bytes).expect("decode failed");
            std::hint::black_box(val);
        } else {
            let out = serde_json::to_vec(&parsed_value).expect("encode failed");
            std::hint::black_box(out);
        }
    };

    // Warmup
    for _ in 0..warmup {
        run_pass();
    }

    // Measured run
    let start = Instant::now();
    for _ in 0..iterations {
        run_pass();
    }
    let elapsed = start.elapsed();

    let elapsed_ns = elapsed.as_nanos();
    let elapsed_micros = elapsed.as_micros() as f64;
    let total_bytes = (bytes.len() * iterations) as f64;
    let throughput_mb_s = (total_bytes / (1024.0 * 1024.0)) / (elapsed_micros / 1_000_000.0);
    let ns_per_op = elapsed_ns / (iterations as u128);

    println!(
        r#"{{"language":"rust","implementation":"{}","dataset":"{}","mode":"{}","iterations":{},"file_bytes":{},"total_bytes":{},"elapsed_ns":{},"throughput_mb_s":{:.2},"ns_per_op":{}}}"#,
        impl_choice,
        dataset_name,
        mode,
        iterations,
        bytes.len(),
        total_bytes as u64,
        elapsed_ns,
        throughput_mb_s,
        ns_per_op
    );
}
