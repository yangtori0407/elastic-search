$ErrorActionPreference = 'Stop'
Set-Location (Split-Path -Parent $PSCommandPath)
docker compose down
Write-Host '컨테이너를 중지했습니다. 데이터 볼륨은 보존됩니다. -v 옵션은 사용하지 않습니다.'
