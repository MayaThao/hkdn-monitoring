
# ==========================================
# CHECK PROMETHEUS TARGETS
# VM1: 172.20.10.13
# VM2: 172.20.10.14
# ==========================================

$PrometheusUrl = "http://172.20.10.13:9090"
$VM2IP = "172.20.10.14"

Write-Host "Checking Prometheus Targets..." -ForegroundColor Cyan

try {
    $Response = Invoke-RestMethod `
        -Uri "$PrometheusUrl/api/v1/targets" `
        -Method GET `
        -TimeoutSec 10

    if ($Response.status -ne "success") {
        Write-Host "FAIL: Cannot retrieve Prometheus targets." -ForegroundColor Red
        exit 1
    }

    $Targets = @($Response.data.activeTargets)

    $VM2Target = @(
        $Targets | Where-Object {
            $_.scrapeUrl -like "*${VM2IP}:9100*"
        }
    )

    if ($VM2Target.Count -eq 0) {
        Write-Host "FAIL: VM2 Node Exporter target not found." -ForegroundColor Red
        exit 1
    }

    foreach ($Target in $VM2Target) {

        Write-Host "Target: $($Target.scrapeUrl)"
        Write-Host "Health: $($Target.health)"

        if ($Target.health -eq "up") {
            Write-Host "PASS: VM2 Node Exporter is UP." -ForegroundColor Green
            exit 0
        }
        else {
            Write-Host "FAIL: VM2 Node Exporter is DOWN." -ForegroundColor Red
            Write-Host "Last Error: $($Target.lastError)"
            exit 1
        }
    }
}
catch {
    Write-Host "ERROR: Cannot connect to Prometheus API." -ForegroundColor Red
    Write-Host $_.Exception.Message
    exit 1
}
