# Generate addons.xml and addons.xml.md5 for Kace Kodi Repository
$repoBase = Join-Path $PSScriptRoot "repo"

# Collect all addon.xml files
$addonDirs = @("plugin.video.xship", "skin.osmc", "repository.kace")
$blocks = @()

foreach ($dir in $addonDirs) {
    $xmlPath = Join-Path $repoBase "$dir\addon.xml"
    if (Test-Path $xmlPath) {
        $content = (Get-Content $xmlPath -Raw).Trim()
        # Strip XML declaration
        if ($content.StartsWith("<?xml")) {
            $idx = $content.IndexOf("?>")
            $content = $content.Substring($idx + 2).Trim()
        }
        $blocks += $content
        Write-Host "  Added: $dir"
    } else {
        Write-Host "  WARNING: $xmlPath not found!" -ForegroundColor Yellow
    }
}

$combined = $blocks -join "`n`n"
$addonsXml = "<?xml version=`"1.0`" encoding=`"UTF-8`" standalone=`"yes`"?>`n<addons>`n$combined`n</addons>"

$outPath = Join-Path $repoBase "addons.xml"
[System.IO.File]::WriteAllText($outPath, $addonsXml, [System.Text.UTF8Encoding]::new($false))
Write-Host "  addons.xml written"

# MD5
$md5 = (Get-FileHash $outPath -Algorithm MD5).Hash.ToLower()
$md5Path = Join-Path $repoBase "addons.xml.md5"
[System.IO.File]::WriteAllText($md5Path, $md5)
Write-Host "  addons.xml.md5: $md5"
