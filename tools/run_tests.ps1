param(
    [string]$GodotExe = "",
    [string]$TestDir = "res://tests/unit"
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
Write-Host "== Godot: $GodotExe"

$proj = Split-Path -Parent $PSScriptRoot

Write-Host "== Importing project (headless)..."
& $GodotExe --headless --path $proj --import
if ($LASTEXITCODE -ne 0) {
    Write-Error "Import failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
}

Write-Host "== Running GUT tests: $TestDir"
& $GodotExe --headless --path $proj -s res://addons/gut/gut_cmdln.gd "-gdir=$TestDir" -ginclude_subdirs -gexit
exit $LASTEXITCODE
