
# ==========================================
# CHECK PROMETHEUS HEALTH
# VM1: 172.20.10.13
# VM2: 172.20.10.14
# ==========================================

$PrometheusUrl = "http://172.20.10.13:9090"

Write-Host "Checking Prometheus Health..." -ForegroundColor Cyan

try {
    $Response = Invoke-WebRequest `
        -Uri "$PrometheusUrl/-/healthy" `
        -Method GET `
        -TimeoutSec 10

    if ($Response.StatusCode -eq 200) {
        Write-Host "PASS: Prometheus is Healthy." -ForegroundColor Green
        exit 0
    }
    else {
        Write-Host "FAIL: Prometheus returned an unexpected status." -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host "ERROR: Cannot connect to Prometheus." -ForegroundColor Red
    Write-Host $_.Exception.Message
    exit 1
}
