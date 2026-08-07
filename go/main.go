package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"time"
)

var blackhole any

func main() {
	datasetPath := flag.String("dataset", "", "Path to JSON dataset file")
	flag.StringVar(datasetPath, "d", "", "Path to JSON dataset file (shorthand)")
	mode := flag.String("mode", "decode", "Benchmark mode (decode/encode)")
	flag.StringVar(mode, "m", "decode", "Benchmark mode (shorthand)")
	implChoice := flag.String("impl", "encoding_json", "Implementation to benchmark")
	flag.StringVar(implChoice, "i", "encoding_json", "Implementation to benchmark (shorthand)")
	iterations := flag.Int("iterations", 100, "Number of measured iterations")
	flag.IntVar(iterations, "n", 100, "Number of measured iterations (shorthand)")
	warmup := flag.Int("warmup", 10, "Number of warmup iterations")
	flag.IntVar(warmup, "w", 10, "Number of warmup iterations (shorthand)")

	flag.Parse()

	if *datasetPath == "" {
		fmt.Fprintln(os.Stderr, "Usage: json_compare_bench_go --dataset <path> [--mode <decode|encode>] [--iterations <N>] [--warmup <N>]")
		os.Exit(1)
	}

	bytes, err := os.ReadFile(*datasetPath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to read dataset '%s': %v\n", *datasetPath, err)
		os.Exit(1)
	}

	datasetName := filepath.Base(*datasetPath)

	var parsedObject any
	if err := json.Unmarshal(bytes, &parsedObject); err != nil {
		fmt.Fprintf(os.Stderr, "Failed to parse initial JSON: %v\n", err)
		os.Exit(1)
	}

	runPass := func() {
		if *mode == "decode" {
			var out any
			if err := json.Unmarshal(bytes, &out); err != nil {
				panic(err)
			}
			blackhole = out
		} else {
			out, err := json.Marshal(parsedObject)
			if err != nil {
				panic(err)
			}
			blackhole = out
		}
	}

	// Warmup
	for i := 0; i < *warmup; i++ {
		runPass()
	}

	// Measured run
	start := time.Now()
	for i := 0; i < *iterations; i++ {
		runPass()
	}
	elapsed := time.Since(start)

	elapsedNs := elapsed.Nanoseconds()
	elapsedMicros := float64(elapsed.Microseconds())
	totalBytes := float64(len(bytes) * (*iterations))
	throughputMbPerSec := (totalBytes / (1024.0 * 1024.0)) / (elapsedMicros / 1000000.0)
	nsPerOp := elapsedNs / int64(*iterations)

	fmt.Printf(
		`{"language":"go","implementation":"%s","dataset":"%s","mode":"%s","iterations":%d,"file_bytes":%d,"total_bytes":%d,"elapsed_ns":%d,"throughput_mb_s":%.2f,"ns_per_op":%d}`+"\n",
		*implChoice,
		datasetName,
		*mode,
		*iterations,
		len(bytes),
		int64(totalBytes),
		elapsedNs,
		throughputMbPerSec,
		nsPerOp,
	)
}
