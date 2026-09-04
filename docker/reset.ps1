$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSCommandPath
Set-Location $root

Write-Host '경고: 현재 Day 1 Docker 환경의 컨테이너, ES 데이터, 인증서, Kibana 저장 데이터를 삭제합니다.' -ForegroundColor Yellow
Write-Host '개인 PBL 저장소와 강사 배포 저장소의 파일은 삭제하지 않습니다.' -ForegroundColor Yellow
Write-Host '계속하려면 RESET 을 정확히 입력합니다. 다른 입력은 취소합니다.'
$confirmation = Read-Host '입력'
if ($confirmation -cne 'RESET') {
  Write-Host '초기화를 취소했습니다.'
  exit 0
}

$envFile = if (Test-Path -LiteralPath '.env') { '.env' } else { '.env.example' }
Write-Host "Compose 리소스를 초기화합니다. 환경 설정 파일: $envFile"
docker compose --env-file $envFile down --volumes --remove-orphans
if ($LASTEXITCODE -ne 0) { throw 'Docker Compose 초기화에 실패했습니다. 오류 메시지를 확인하고 강사에게 알립니다.' }

$images = @(
  'docker.elastic.co/elasticsearch/elasticsearch:9.5.0',
  'docker.elastic.co/kibana/kibana:9.5.0'
)

foreach ($image in $images) {
  $remainingUsers = @(docker ps -a --filter "ancestor=$image" --format '{{.Names}}')
  if ($remainingUsers.Count -gt 0) {
    Write-Warning "$image 이미지는 다른 컨테이너가 사용 중이므로 삭제하지 않았습니다: $($remainingUsers -join ', ')"
    continue
  }

  docker image inspect $image 2>$null | Out-Null
  if ($LASTEXITCODE -eq 0) {
    docker image rm $image
    if ($LASTEXITCODE -ne 0) { throw "$image 이미지를 삭제하지 못했습니다. 오류 메시지를 확인하고 강사에게 알립니다." }
  }
}

if (Test-Path -LiteralPath '.env') {
  Remove-Item -LiteralPath '.env'
  Write-Host '.env를 삭제했습니다. 다음 시작 전에 .env.example에서 다시 만듭니다.'
}

Write-Host '초기화 완료: 다음 순서로 다시 시작합니다.' -ForegroundColor Green
Write-Host 'Copy-Item .env.example .env → .\preflight.ps1 → .\pull-images.ps1 → .\start.ps1 → .\status.ps1'
