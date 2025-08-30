$ErrorActionPreference = 'Stop'

# --- Setup ---
$repo    = $PSScriptRoot
$logFile = Join-Path $repo 'daily-commit.log'

function Write-Log([string]$msg) {
    $ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    Add-Content -Path $logFile -Value "[$ts] $msg" -Encoding UTF8
}

Set-Location -LiteralPath $repo

# --- Check Git configuration ---
$gitUser = git config user.name
$gitEmail = git config user.email

if (-not $gitUser -or -not $gitEmail) {
    Write-Host "Git не настроен! Настройте имя пользователя и email:" -ForegroundColor Yellow
    Write-Host "git config --global user.name 'Ваше имя'" -ForegroundColor Cyan
    Write-Host "git config --global user.email 'ваш@email.com'" -ForegroundColor Cyan
    Write-Log "Git configuration missing"
    exit 1
}

# --- Today ---
$today = Get-Date -Format 'yyyy-MM-dd'
$Y = Get-Date -Format 'yyyy'
$M = Get-Date -Format 'MM'

$journalDir = Join-Path $repo ("journal\" + $Y + "\" + $M)
$todayFile  = Join-Path $journalDir ($today + '.md')

# Create folder/file if missing (no here-strings)
if (-not (Test-Path $journalDir)) {
    New-Item -ItemType Directory -Path $journalDir -Force | Out-Null
}
if (-not (Test-Path $todayFile)) {
    $content = @(
        "# $today",
        "",
        "## Done",
        "",
        "- ",
        "",
        "## Not done",
        "",
        "- "
    ) -join "`r`n"
    Set-Content -Path $todayFile -Value $content -Encoding UTF8
    Write-Log "Created: $todayFile"
    
    # Open file in default editor
    Write-Host "📝 Открываю файл для редактирования..." -ForegroundColor Cyan
    Start-Process $todayFile
    Write-Host "💡 Заполни файл и сохрани его (Ctrl+S), затем вернись сюда" -ForegroundColor Yellow
    Write-Host "💡 Нажми Enter, когда закончишь редактирование..." -ForegroundColor Yellow
    Read-Host
}

# --- Validate "Done" section ---
$fileContent = Get-Content -Path $todayFile
$inDoneSection = $false
$hasDoneItems = $false

foreach ($line in $fileContent) {
    if ($line -match '^## Done$') {
        $inDoneSection = $true
        continue
    }
    if ($line -match '^## Not done$') {
        $inDoneSection = $false
        continue
    }
    if ($inDoneSection -and $line -match '^- ') {
        $hasDoneItems = $true
        break
    }
}

if (-not $hasDoneItems) {
    Write-Host "No items under 'Done'. Add at least one '- ...'." -ForegroundColor Yellow
    Write-Log  "Skipped commit: empty 'Done' section."
    exit 1
}

# --- Git add/commit/push ---
git add -A

# Check if running interactively
if ([Environment]::UserInteractive) {
    $Msg = Read-Host 'Enter commit title'
} else {
    $Msg = "Daily update $today"
}
$FullMsg = "$today - $Msg"   # plain hyphen

try {
    git commit -m "$FullMsg"
    Write-Log "Commit created: $FullMsg"
} catch {
    Write-Host 'Nothing to commit.'
    Write-Log  'Nothing to commit.'
    exit 0
}

try {
    # First try to pull any remote changes
    Write-Host "Pulling remote changes..." -ForegroundColor Cyan
    $pullOutput = git pull origin main 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Pull warning: $pullOutput" -ForegroundColor Yellow
        Write-Log  ("Pull warning: " + ($pullOutput -join ' '))
    }
    
    # Then push
    Write-Host "Pushing changes..." -ForegroundColor Cyan
    $pushOutput = git push -u origin main 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Successfully pushed: $FullMsg" -ForegroundColor Green
        Write-Log  "Push OK: $FullMsg"
    } else {
        Write-Host '❌ Push error!' -ForegroundColor Red
        Write-Host $pushOutput -ForegroundColor Red
        Write-Log  ('Push error: ' + ($pushOutput -join ' '))
        Write-Host "Try running 'git push origin main' manually" -ForegroundColor Yellow
    }
} catch {
    Write-Host '❌ Exception on push!' -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Log  ('Exception on push: ' + $_.Exception.Message)
}
