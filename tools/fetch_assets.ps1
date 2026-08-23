param(
    [string[]]$Slugs = @("roguelike-rpg-pack", "particle-pack")
)

# Downloads CC0 Kenney asset packs and extracts them under assets/kenney/.
# Every Kenney pack is Creative Commons Zero (public domain) - see
# docs/art/ASSET_CREDITS.md for provenance notes.

$ErrorActionPreference = "Stop"
$proj = Split-Path -Parent $PSScriptRoot
$dest = Join-Path $proj "assets\kenney"
New-Item -ItemType Directory -Force -Path $dest | Out-Null

foreach ($slug in $Slugs) {
    $outDir = Join-Path $dest $slug
    if (Test-Path $outDir) {
        Write-Host "== $slug already present, skipping"
        continue
    }
    Write-Host "== fetching $slug"
    $page = Invoke-WebRequest -Uri "https://kenney.nl/assets/$slug" -UseBasicParsing
    $match = [regex]::Match($page.Content, 'href=[''"]([^''"]+\.zip)[''"]')
    if (-not $match.Success) {
        Write-Warning "no .zip link found on the $slug page; skipping"
        continue
    }
    $zipUrl = $match.Groups[1].Value
    if ($zipUrl -notlike "http*") { $zipUrl = "https://kenney.nl" + $zipUrl }
    Write-Host "== downloading $zipUrl"
    $tmp = Join-Path $env:TEMP "$slug.zip"
    Invoke-WebRequest -Uri $zipUrl -OutFile $tmp -UseBasicParsing
    Expand-Archive -Path $tmp -DestinationPath $outDir -Force
    Remove-Item $tmp
    Write-Host "== extracted -> $outDir"
}
Write-Host "== done"
