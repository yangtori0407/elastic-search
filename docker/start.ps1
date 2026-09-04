$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSCommandPath
Set-Location $root

if (-not (Test-Path -LiteralPath '.env')) { throw '.env가 없습니다. 강사가 제공한 실습 패키지의 .env를 이 폴더에 둡니다.' }
& "$root\preflight.ps1"
if ($LASTEXITCODE -ne 0) { throw '사전 점검을 통과하지 못했습니다. 위 CHECK 항목을 해결한 후 다시 실행합니다.' }

try {
  docker image inspect 'docker.elastic.co/elasticsearch/elasticsearch:9.5.0' | Out-Null
  docker image inspect 'docker.elastic.co/kibana/kibana:9.5.0' | Out-Null
} catch {
  throw 'ES 또는 Kibana 이미지가 없습니다. 인터넷 연결 상태에서 .\pull-images.ps1를 먼저 한 번 실행합니다.'
}

Write-Host '3노드 Elasticsearch와 Kibana를 시작합니다. 최초 실행은 인증서 생성 때문에 시간이 더 걸릴 수 있습니다.'
docker compose up --detach
if ($LASTEXITCODE -ne 0) { throw '컨테이너 시작에 실패했습니다. 오류 메시지를 확인하고 강사에게 알립니다.' }
Write-Host '시작 요청이 완료되었습니다. .\status.ps1로 상태를 확인하고, http://localhost:5601을 엽니다.'
