param(
    [string]$GodotExe = "",
    [int]$Frames = 120
)

$ErrorActionPreference = "Stop"

if (-not $GodotExe) {
    $candidates = @(
        "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_*\*_console.exe",
        "$env:LOCALAPPDATA\Microsoft\WinGet\Links\godot_console.exe"
    )
    foreach ($pattern in $candidates) {
        $hit = Get-Item $pattern -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($hit) { $GodotExe = $hit.FullName; break }
    }
}
if (-not $GodotExe -or -not (Test-Path -LiteralPath $GodotExe)) {
    Write-Error "Godot console executable not found. Pass -GodotExe <path>."
    exit 1
}

$proj = Split-Path -Parent $PSScriptRoot

Write-Host "== Smoke run: boot main scene for $Frames frames (headless)"
$output = & $GodotExe --headless --path $proj --quit-after $Frames 2>&1
$code = $LASTEXITCODE
foreach ($line in $output) { Write-Host "   $line" }

$failures = @($output | Select-String -Pattern "SCRIPT ERROR|ERROR:")
if ($code -ne 0) {
    Write-Error "Smoke FAILED: exit code $code"
    exit $code
}
if ($failures.Count -gt 0) {
    Write-Error "Smoke FAILED: $($failures.Count) error line(s) in output"
    exit 1
}
Write-Host "== SMOKE OK"
exit 0
