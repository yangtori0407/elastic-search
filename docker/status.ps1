$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSCommandPath
Set-Location $root
$passwordLine = Get-Content -LiteralPath '.env' | Where-Object { $_ -match '^ELASTIC_PASSWORD=' } | Select-Object -First 1
if (-not $passwordLine) { throw '.env에서 ELASTIC_PASSWORD를 찾지 못했습니다.' }
$elasticPassword = $passwordLine.Substring('ELASTIC_PASSWORD='.Length)

Write-Host '=== Docker / Compose 버전 ==='
docker version --format 'Docker Engine: {{.Server.Version}}'
docker compose version
Write-Host "`n=== 컨테이너 상태 ==="
docker compose ps --all
Write-Host "`n=== Elasticsearch 클러스터 상태 ==="
docker compose exec -T es01 curl -s --cacert config/certs/ca/ca.crt -u "elastic:$elasticPassword" https://localhost:9200/_cluster/health?pretty
Write-Host "`n=== 노드 목록 ==="
docker compose exec -T es01 curl -s --cacert config/certs/ca/ca.crt -u "elastic:$elasticPassword" 'https://localhost:9200/_cat/nodes?v'
Write-Host "`n=== Kibana 상태 ==="
try {
  $kibanaStatus = docker compose exec -T kibana sh -c "curl -s -u 'elastic:$elasticPassword' http://localhost:5601/api/status" | ConvertFrom-Json
  Write-Host "Kibana overall: $($kibanaStatus.status.overall.level) - $($kibanaStatus.status.overall.summary)"
} catch {
  Write-Host 'Kibana가 아직 준비 중입니다. 20~30초 뒤 .\status.ps1를 다시 실행합니다.'
}
Write-Host "`n확인 기준: number_of_nodes가 3이고 es01, es02, es03이 보이면 정상입니다."
