
# ==========================================
# CHECK PROMETHEUS METRICS
# VM1: 172.20.10.13
# VM2: 172.20.10.14
# ==========================================

$PrometheusUrl = "http://172.20.10.13:9090"
$VM2IP = "172.20.10.14"

$Query = "node_cpu_seconds_total{instance=`"$VM2IP`:9100`"}"

Write-Host "Checking Node Exporter Metrics..." -ForegroundColor Cyan

try {
    # Encode query
    $EncodedQuery = [uri]::EscapeDataString($Query)

    # Send request to Prometheus
    $Response = Invoke-RestMethod `
        -Uri "$PrometheusUrl/api/v1/query?query=$EncodedQuery" `
        -Method GET `
        -TimeoutSec 10

    # Check API response
    if ($Response.status -ne "success") {
        Write-Host "FAIL: Prometheus query was unsuccessful." -ForegroundColor Red
        exit 1
    }

    # Get metric results
    $Results = @($Response.data.result)

    # Check whether metrics exist
    if ($Results.Count -gt 0) {
        Write-Host "PASS: VM2 CPU metrics received." -ForegroundColor Green
        Write-Host "Number of metric results: $($Results.Count)" -ForegroundColor Yellow

        exit 0
    }
    else {
        Write-Host "FAIL: No CPU metrics found for VM2." -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host "ERROR: Cannot connect to Prometheus." -ForegroundColor Red
    Write-Host "Details: $($_.Exception.Message)" -ForegroundColor Yellow

    exit 1
}
