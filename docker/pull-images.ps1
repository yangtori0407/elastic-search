$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSCommandPath
Set-Location $root

if (-not (Test-Path -LiteralPath '.env')) {
  throw '.env가 없습니다. 강사가 제공한 실습 패키지의 .env를 이 폴더에 둡니다.'
}

Write-Host '공식 Elastic Registry에서 ES와 Kibana 9.5.0 이미지를 내려받습니다. 컨테이너는 아직 시작하지 않습니다.'
docker compose pull

docker image inspect 'docker.elastic.co/elasticsearch/elasticsearch:9.5.0' | Out-Null
docker image inspect 'docker.elastic.co/kibana/kibana:9.5.0' | Out-Null
Write-Host 'PASS: Elasticsearch 9.5.0 및 Kibana 9.5.0 이미지 다운로드가 완료되었습니다.'
