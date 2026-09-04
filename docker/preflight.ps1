$ErrorActionPreference = 'Stop'

function Show-Check($name, $ok, $detail) {
  $mark = if ($ok) { 'PASS' } else { 'CHECK' }
  Write-Host "[$mark] $name - $detail"
}

$docker = Get-Command docker -ErrorAction SilentlyContinue
Show-Check 'Docker CLI' ($null -ne $docker) 'docker 명령 사용 가능 여부'
if (-not $docker) { exit 1 }

try { $null = docker version --format '{{.Server.Version}}' 2>$null; Show-Check 'Docker Engine' $true 'Docker Desktop Engine 실행 중' } catch { Show-Check 'Docker Engine' $false 'Docker Desktop을 실행한 뒤 다시 시도'; exit 1 }

try { $composeVersion = docker compose version; Show-Check 'Docker Compose' $true $composeVersion } catch { Show-Check 'Docker Compose' $false 'Docker Desktop 최신 버전 확인'; exit 1 }

$wsl = (& wsl --status 2>$null | Out-String)
Show-Check 'WSL 2' ($LASTEXITCODE -eq 0) 'WSL 상태 확인'

$freeGb = [math]::Round((Get-PSDrive -Name C).Free / 1GB, 1)
Show-Check 'C 드라이브 여유 공간' ($freeGb -ge 15) "$freeGb GB (권장 15GB 이상)"
if ($freeGb -lt 15) { exit 1 }

function Get-ConfiguredPort($variableName, $fallbackPort) {
  $envPath = Join-Path $PSScriptRoot '.env'
  if (-not (Test-Path -LiteralPath $envPath)) { return $fallbackPort }
  $line = Get-Content -LiteralPath $envPath | Where-Object { $_ -match "^$variableName=" } | Select-Object -First 1
  if (-not $line) { return $fallbackPort }
  $value = $line.Split('=', 2)[1]
  if ($value -match ':(\d+)$') { return [int]$Matches[1] }
  return $fallbackPort
}

function Test-PortAvailable($port, $label) {
  $listeners = @(Get-NetTCPConnection -State Listen -LocalPort $port -ErrorAction SilentlyContinue)
  $available = $listeners.Count -eq 0
  $detail = if ($available) { "localhost:$port 사용 가능" } else { "localhost:$port 를 다른 프로그램 또는 컨테이너가 사용 중" }
  Show-Check $label $available $detail
  if (-not $available) { exit 1 }
}

$esPort = Get-ConfiguredPort 'ES_PORT' 9200
$kibanaPort = Get-ConfiguredPort 'KIBANA_PORT' 5601
Test-PortAvailable $esPort 'ES 포트'
Test-PortAvailable $kibanaPort 'Kibana 포트'

Write-Host "`n다음 단계: .\pull-images.ps1 실행 후 .\start.ps1"
