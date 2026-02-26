/*
#######################################################################################################################
#
#
#   Project         :   Demo Application showing Prometheus metrics
#
#   File            :   main.go
#
#   Description     :
#
#   By              :   George Leonard
#   Email           :   georgelza@gmail.com
#
#   Created         :   Feb 2026
#
#########################################################################################################################
*/

package main

import (
	"encoding/json"
	"fmt"
	"math/rand"
	"net/http"
	"os"
	"strconv"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

const appVersion = "1.0.0"

// ---------------------------------------------------------------------------
// Config from environment (populated via ConfigMap)
// ---------------------------------------------------------------------------
func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func getEnvFloat(key string, fallback float64) float64 {
	if v := os.Getenv(key); v != "" {
		if f, err := strconv.ParseFloat(v, 64); err == nil {
			return f
		}
	}
	return fallback
}

func getEnvInt(key string, fallback int) int {
	if v := os.Getenv(key); v != "" {
		if i, err := strconv.Atoi(v); err == nil {
			return i
		}
	}
	return fallback
}

// ---------------------------------------------------------------------------
// Structured logger – every line is a JSON object, AppName is always first
// Column order: app | module | level | ts | event | <remaining fields>
// ---------------------------------------------------------------------------
func logEvent(appName, modName, level, event string, fields map[string]interface{}) {
	record := map[string]interface{}{
		"app":    appName,
		"module": modName,
		"level":  level,
		"ts":     time.Now().UTC().Format(time.RFC3339),
		"event":  event,
	}
	for k, v := range fields {
		record[k] = v
	}
	b, _ := json.Marshal(record)
	fmt.Println(string(b))
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
func main() {
	appName     := getEnv("APP_NAME", "golang-prometheus-demo")
	sleepMin    := getEnvFloat("SLEEP_MIN", 1.0)
	sleepMax    := getEnvFloat("SLEEP_MAX", 5.0)
	metricsPort := getEnvInt("METRICS_PORT", 8000)

	maxRunRaw := getEnv("MAX_RUN", "")
	maxRun    := 0
	unlimited := true
	if maxRunRaw != "" {
		if v, err := strconv.Atoi(maxRunRaw); err == nil && v > 0 {
			maxRun    = v
			unlimited = false
		}
	}

	startTime    := time.Now()
	startTimeStr := startTime.UTC().Format(time.RFC3339)

	maxRunStr := "unlimited"
	if !unlimited {
		maxRunStr = strconv.Itoa(maxRun)
	}

	// ── Prometheus metrics ────────────────────────────────────────────────────

	// Info gauge — labels carry the config values
	appInfo := promauto.NewGaugeVec(prometheus.GaugeOpts{
		Name: "app_info",
		Help: "Application information",
	}, []string{"app_name", "start_time", "version", "sleep_min", "sleep_max", "max_run"})

	appInfo.WithLabelValues(
		appName,
		startTimeStr,
		appVersion,
		fmt.Sprintf("%.1f", sleepMin),
		fmt.Sprintf("%.1f", sleepMax),
		maxRunStr,
	).Set(1)

	// Gauge: random number
	randomNumber := promauto.NewGauge(prometheus.GaugeOpts{
		Name: "random_number",
		Help: "Random number generated each loop",
	})

	// Gauge: percentage complete
	pctComplete := promauto.NewGauge(prometheus.GaugeOpts{
		Name: "loop_pct_complete",
		Help: "Current loop count as % of MaxRun (0 when unlimited)",
	})

	// Summary: loop elapsed time
	loopSummary := promauto.NewSummary(prometheus.SummaryOpts{
		Name: "loop_duration_seconds",
		Help: "Summary of loop execution times",
	})

	// Counter: total iterations
	loopCounter := promauto.NewCounter(prometheus.CounterOpts{
		Name: "loop_total",
		Help: "Total number of while loop iterations executed",
	})

	// Histogram: per-loop elapsed time, 5 explicit buckets
	loopHistogram := promauto.NewHistogram(prometheus.HistogramOpts{
		Name:    "loop_execution_seconds",
		Help:    "Histogram of loop execution times",
		Buckets: []float64{1.0, 2.0, 3.0, 4.0, 5.0},
	})

	// ── Start metrics HTTP server ─────────────────────────────────────────────
	http.Handle("/metrics", promhttp.Handler())
	go func() {
		addr := fmt.Sprintf(":%d", metricsPort)
		if err := http.ListenAndServe(addr, nil); err != nil {
			fmt.Fprintf(os.Stderr, "metrics server error: %v\n", err)
			os.Exit(1)
		}
	}()

	// ── Log startup ───────────────────────────────────────────────────────────
	logEvent(appName, "main", "INFO", "startup", map[string]interface{}{
		"app_name":     appName,
		"start_time":   startTimeStr,
		"version":      appVersion,
		"sleep_min":    sleepMin,
		"sleep_max":    sleepMax,
		"max_run":      maxRunStr,
		"metrics_port": metricsPort,
	})

	// ── Main loop ─────────────────────────────────────────────────────────────
	loopCount := 0

	for {
		// Check cap
		if !unlimited && loopCount >= maxRun {
			totalRuntime := time.Since(startTime).Seconds()
			logEvent(appName, "main", "INFO", "max_run_reached", map[string]interface{}{
				"max_run":                maxRun,
				"current_run":            loopCount,
				"total_execution_time_s": fmt.Sprintf("%.2f", totalRuntime),
			})
			os.Exit(0)
		}

		loopStart := time.Now()

		// Random sleep within bounds
		sleepDuration := sleepMin + rand.Float64()*(sleepMax-sleepMin)
		time.Sleep(time.Duration(sleepDuration * float64(time.Second)))

		elapsed      := time.Since(loopStart).Seconds()
		totalRuntime := time.Since(startTime).Seconds()

		// Random number 1-10
		rnd := rand.Intn(10) + 1

		// Update metrics
		randomNumber.Set(float64(rnd))
		loopCounter.Inc()
		loopSummary.Observe(elapsed)
		loopHistogram.Observe(elapsed)

		loopCount++

		pct := 0.0
		pctStr := "n/a"
		if !unlimited {
			pct    = float64(loopCount) / float64(maxRun) * 100
			pctStr = fmt.Sprintf("%.2f", pct)
		}
		pctComplete.Set(pct)

		logEvent(appName, "main", "INFO", "loop_tick", map[string]interface{}{
			"max_run":                maxRunStr,
			"current_run":            loopCount,
			"pct_complete":           pctStr,
			"total_execution_time_s": fmt.Sprintf("%.2f", totalRuntime),
			"loop_execution_time_s":  fmt.Sprintf("%.2f", elapsed),
			"sleep_s":                fmt.Sprintf("%.2f", sleepDuration),
			"random_number":          rnd,
		})
	}
}
