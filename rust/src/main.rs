use mimalloc::MiMalloc;
use std::env;
use std::fs;
use std::path::Path;
use std::process;
use std::time::Instant;

mod models;
use models::*;

#[global_allocator]
static GLOBAL: MiMalloc = MiMalloc;

enum PredecodedModel {
    Small(SmallDocument),
    Twitter(TwitterResponse),
    Citm(CitmCatalog),
    Canada(CanadaFeatureCollection),
    Unknown(serde_json::Value),
}

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

    let predecoded_model = if dataset_name.contains("small") {
        let m: SmallDocument = serde_json::from_slice(&bytes).expect("Initial parse small failed");
        PredecodedModel::Small(m)
    } else if dataset_name.contains("twitter") {
        let m: TwitterResponse = serde_json::from_slice(&bytes).expect("Initial parse twitter failed");
        PredecodedModel::Twitter(m)
    } else if dataset_name.contains("citm") {
        let m: CitmCatalog = serde_json::from_slice(&bytes).expect("Initial parse citm failed");
        PredecodedModel::Citm(m)
    } else if dataset_name.contains("canada") {
        let m: CanadaFeatureCollection = serde_json::from_slice(&bytes).expect("Initial parse canada failed");
        PredecodedModel::Canada(m)
    } else {
        let m: serde_json::Value = serde_json::from_slice(&bytes).expect("Initial parse unknown failed");
        PredecodedModel::Unknown(m)
    };

    let run_pass = || {
        if mode == "decode" {
            if dataset_name.contains("small") {
                let val: SmallDocument = serde_json::from_slice(&bytes).expect("decode failed");
                std::hint::black_box(val);
            } else if dataset_name.contains("twitter") {
                let val: TwitterResponse = serde_json::from_slice(&bytes).expect("decode failed");
                std::hint::black_box(val);
            } else if dataset_name.contains("citm") {
                let val: CitmCatalog = serde_json::from_slice(&bytes).expect("decode failed");
                std::hint::black_box(val);
            } else if dataset_name.contains("canada") {
                let val: CanadaFeatureCollection = serde_json::from_slice(&bytes).expect("decode failed");
                std::hint::black_box(val);
            } else {
                let val: serde_json::Value = serde_json::from_slice(&bytes).expect("decode failed");
                std::hint::black_box(val);
            }
        } else {
            match &predecoded_model {
                PredecodedModel::Small(m) => {
                    let out = serde_json::to_vec(m).expect("encode failed");
                    std::hint::black_box(out);
                }
                PredecodedModel::Twitter(m) => {
                    let out = serde_json::to_vec(m).expect("encode failed");
                    std::hint::black_box(out);
                }
                PredecodedModel::Citm(m) => {
                    let out = serde_json::to_vec(m).expect("encode failed");
                    std::hint::black_box(out);
                }
                PredecodedModel::Canada(m) => {
                    let out = serde_json::to_vec(m).expect("encode failed");
                    std::hint::black_box(out);
                }
                PredecodedModel::Unknown(m) => {
                    let out = serde_json::to_vec(m).expect("encode failed");
                    std::hint::black_box(out);
                }
            }
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
