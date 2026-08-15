package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"strings"
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

	var predecodedModel any
	if strings.Contains(datasetName, "small") {
		var m SmallDocument
		if err := json.Unmarshal(bytes, &m); err != nil {
			fmt.Fprintf(os.Stderr, "Failed to parse initial small JSON: %v\n", err)
			os.Exit(1)
		}
		predecodedModel = &m
	} else if strings.Contains(datasetName, "twitter") {
		var m TwitterResponse
		if err := json.Unmarshal(bytes, &m); err != nil {
			fmt.Fprintf(os.Stderr, "Failed to parse initial twitter JSON: %v\n", err)
			os.Exit(1)
		}
		predecodedModel = &m
	} else if strings.Contains(datasetName, "citm") {
		var m CitmCatalog
		if err := json.Unmarshal(bytes, &m); err != nil {
			fmt.Fprintf(os.Stderr, "Failed to parse initial citm JSON: %v\n", err)
			os.Exit(1)
		}
		predecodedModel = &m
	} else if strings.Contains(datasetName, "canada") {
		var m CanadaFeatureCollection
		if err := json.Unmarshal(bytes, &m); err != nil {
			fmt.Fprintf(os.Stderr, "Failed to parse initial canada JSON: %v\n", err)
			os.Exit(1)
		}
		predecodedModel = &m
	} else {
		var m any
		if err := json.Unmarshal(bytes, &m); err != nil {
			fmt.Fprintf(os.Stderr, "Failed to parse initial generic JSON: %v\n", err)
			os.Exit(1)
		}
		predecodedModel = &m
	}

	runPass := func() {
		if *mode == "decode" {
			if strings.Contains(datasetName, "small") {
				var out SmallDocument
				if err := json.Unmarshal(bytes, &out); err != nil {
					panic(err)
				}
				blackhole = &out
			} else if strings.Contains(datasetName, "twitter") {
				var out TwitterResponse
				if err := json.Unmarshal(bytes, &out); err != nil {
					panic(err)
				}
				blackhole = &out
			} else if strings.Contains(datasetName, "citm") {
				var out CitmCatalog
				if err := json.Unmarshal(bytes, &out); err != nil {
					panic(err)
				}
				blackhole = &out
			} else if strings.Contains(datasetName, "canada") {
				var out CanadaFeatureCollection
				if err := json.Unmarshal(bytes, &out); err != nil {
					panic(err)
				}
				blackhole = &out
			} else {
				var out any
				if err := json.Unmarshal(bytes, &out); err != nil {
					panic(err)
				}
				blackhole = out
			}
		} else {
			out, err := json.Marshal(predecodedModel)
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
