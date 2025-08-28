$ErrorActionPreference = "Stop"

# Корень репозитория = папка, где лежит сам скрипт
$repo = $PSScriptRoot
Set-Location -LiteralPath $repo

# Сегодняшняя дата и пути
$today = Get-Date -Format "yyyy-MM-dd"
$Y = Get-Date -Format "yyyy"
$M = Get-Date -Format "MM"

$journalDir = Join-Path $repo "journal"
$journalDir = Join-Path $journalDir $Y
$journalDir = Join-Path $journalDir $M
$todayFile  = Join-Path $journalDir "$today.md"

# Создать каталоги/файл при отсутствии
if (-not (Test-Path $journalDir)) { New-Item -ItemType Directory -Path $journalDir -Force | Out-Null }
if (-not (Test-Path $todayFile)) {
@"
# $today

Что сделано:
- 

Что не сделано:
- 
"@ | Out-File -FilePath $todayFile -Encoding UTF8
}

# Коммит и push
git add -A
Write-Host "Введи название коммита:"
$MSG = Read-Host
try {
    git commit -m "$MSG"
} catch {
    Write-Host "Нет изменений для коммита"
}
git push -u origin main
