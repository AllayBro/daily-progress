$ErrorActionPreference = "Stop"

# === Настройки ===
$repo    = $PSScriptRoot
$logFile = Join-Path $repo "daily-commit.log"

# === Функция логирования ===
function Write-Log($msg) {
    $timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    Add-Content -Path $logFile -Value "[$timestamp] $msg"
}

# === Работаем из папки репозитория ===
Set-Location -LiteralPath $repo

# === Сегодняшняя дата и файл ===
$today = Get-Date -Format "yyyy-MM-dd"
$Y = Get-Date -Format "yyyy"
$M = Get-Date -Format "MM"

$journalDir = Join-Path $repo "journal\$Y\$M"
$todayFile  = Join-Path $journalDir "$today.md"

# Создать каталог/файл при отсутствии
if (-not (Test-Path $journalDir)) { New-Item -ItemType Directory -Path $journalDir -Force | Out-Null }
if (-not (Test-Path $todayFile)) {
@"
# $today

Что сделано:
- 

Что не сделано:
- 
"@ | Out-File -FilePath $todayFile -Encoding UTF8
Write-Log "Создан новый файл: $todayFile"
}

# === Проверка содержимого "Что сделано" ===
$fileContent = Get-Content -Path $todayFile -Raw
$doneSection = ($fileContent -split "Что сделано:")[1] -split "Что не сделано:" | Select-Object -First 1

if ($doneSection -notmatch "- ") {
    Write-Host "В разделе 'Что сделано' нет пунктов. Добавь хотя бы один '- ...' и попробуй снова."
    Write-Log "Пропущен коммит: раздел 'Что сделано' пуст."
    exit 1
}

# === Git add/commit/push ===
git add -A

Write-Host "Введи название коммита:"
$MSG = Read-Host
$fullMsg = "$today — $MSG"

try {
    git commit -m "$fullMsg"
    Write-Log "Создан коммит: $fullMsg"
} catch {
    Write-Host "Нет изменений для коммита."
    Write-Log "Нет изменений для коммита."
    exit 0
}

# === Git push с проверкой ошибок ===
try {
    git push -u origin main 2>&1 | Tee-Object -Variable pushOutput | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Коммит отправлен: $fullMsg"
        Write-Log "Успешный push: $fullMsg"
    } else {
        Write-Host "Ошибка при git push!"
        Write-Log "Ошибка git push: $($pushOutput -join ' ')"
    }
} catch {
    Write-Host "Исключение при git push!"
    Write-Log "Исключение при git push: $_"
}
