# Coast (T-180) - Night Dark : installer / uninstaller
# Run it by double-clicking INSTALL.bat or UNINSTALL.bat. ASCII only on purpose (Windows PowerShell 5.1).
#
# It adds a second track, "Coast Night", in a folder beside Coast (coast_night). The original Coast is
# not changed. The big files of the new track are hard links to Coast's own, so it takes almost no disk.
param([switch]$Uninstall, [switch]$NoPause, [string]$TrackPath = '')
$ErrorActionPreference = 'Stop'
# The three lighting files that differ on the night track. First 16 hex of sha256 of the shipped v0.2
# file, and of the same file made dark.
$FILES = @(
    @{ rel = 'extension\ext_config.ini';           orig = '811035A31821D440'; dark = '240C5EF64F272F52' },
    @{ rel = 'skins\cm_skins\Gold\ext_config.ini'; orig = 'B3E0D8A71A8A8106'; dark = 'F3FE29CE9940A771' },
    @{ rel = 'skins\cm_skins\Fuji\ext_config.ini'; orig = 'B3E0D8A71A8A8106'; dark = 'F3FE29CE9940A771' }
)
$OLD_SUFFIX = '.before-night-dark'   # backups left by the first version of this installer
$NIGHT_NAME = 'coast_night'
$MARKER = 'made-by-coast-night-dark.txt'
$Payload = Join-Path $PSScriptRoot 'files\coast'
function Say($m, $c = 'Gray') { Write-Host $m -ForegroundColor $c }
function ShortSha($f) { (Get-FileHash -LiteralPath $f -Algorithm SHA256).Hash.Substring(0, 16) }
function Finish($code) { Write-Host ''; if (-not $NoPause) { Read-Host 'Press Enter to close' | Out-Null }; exit $code }
function Find-Track {
    $c = New-Object System.Collections.Generic.List[string]
    $steam = $null
    foreach ($k in 'HKCU:\Software\Valve\Steam', 'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam', 'HKLM:\SOFTWARE\Valve\Steam') {
        try {
            $p = Get-ItemProperty -Path $k -ErrorAction Stop
            if ($p.SteamPath) { $steam = $p.SteamPath; break }
            if ($p.InstallPath) { $steam = $p.InstallPath; break }
        } catch { }
    }
    if ($steam) {
        $bs = [string][char]92
        $steam = $steam.Replace('/', $bs); $c.Add($steam)
        $vdf = Join-Path $steam 'steamapps\libraryfolders.vdf'
        if (Test-Path -LiteralPath $vdf) {
            foreach ($l in Get-Content -LiteralPath $vdf) {
                if ($l -match '"path"\s+"([^"]+)"') { $c.Add($Matches[1].Replace($bs + $bs, $bs)) }
            }
        }
    }
    foreach ($lib in ($c | Select-Object -Unique)) {
        $t = Join-Path $lib 'steamapps\common\assettocorsa\content\tracks\coast'
        if (Test-Path -LiteralPath (Join-Path $t 'ctrack.kn5')) { return $t }
    }
    return $null
}
# Put the original lighting files back if the first version of this installer changed them in place.
function Restore-Old($track) {
    $n = 0
    foreach ($f in $FILES) {
        $cfg = Join-Path $track $f.rel; $bak = $cfg + $OLD_SUFFIX
        if (Test-Path -LiteralPath $bak) {
            Copy-Item -LiteralPath $bak -Destination $cfg -Force; Remove-Item -LiteralPath $bak -Force; $n++
        }
    }
    return $n
}

Say ''; Say 'Coast - Night Dark' 'Cyan'; Say '------------------' 'Cyan'
if (-not $TrackPath) { $TrackPath = Find-Track }
if (-not $TrackPath) {
    Say 'Could not find Coast automatically.' 'Yellow'
    $ac = (Read-Host 'Paste your Assetto Corsa folder (the one that contains "content")').Trim('"', ' ')
    $TrackPath = Join-Path $ac 'content\tracks\coast'
}
if (-not (Test-Path -LiteralPath (Join-Path $TrackPath 'ctrack.kn5'))) {
    Say ('Coast was not found at: ' + $TrackPath) 'Red'; Say 'Nothing was changed.' 'Red'; Finish 1
}
$TrackPath = (Resolve-Path -LiteralPath $TrackPath).Path.TrimEnd([char]92)
$Night = Join-Path (Split-Path $TrackPath) $NIGHT_NAME
Say ('Found the track: ' + $TrackPath)

if ($Uninstall) {
    $did = $false
    if ((Restore-Old $TrackPath) -gt 0) { Say 'Put back the original lighting files of Coast.'; $did = $true }
    if (Test-Path -LiteralPath $Night) {
        if (-not (Test-Path -LiteralPath (Join-Path $Night $MARKER))) {
            Say ('A folder named ' + $NIGHT_NAME + ' exists but this installer did not make it. Left alone.') 'Yellow'; Finish 1
        }
        Remove-Item -LiteralPath $Night -Recurse -Force
        Say 'Removed the Coast Night track.'; $did = $true
    }
    if (-not $did) { Say 'Night Dark does not look installed. Nothing was changed.' 'Yellow'; Finish 1 }
    Say 'Done. Coast is as its author shipped it.' 'Green'; Finish 0
}

# ---- install ----
if ((Restore-Old $TrackPath) -gt 0) { Say 'Put back the original lighting files of Coast (an earlier version had changed them in place).' }
foreach ($f in $FILES) {
    $cfg = Join-Path $TrackPath $f.rel
    if (-not (Test-Path -LiteralPath $cfg)) { Say ('Coast is missing a file this was made for: ' + $f.rel) 'Yellow'; Say 'Nothing was changed.' 'Yellow'; Finish 1 }
    $now = ShortSha $cfg
    if ($now -ne $f.orig) {
        Say ('This file is not the version this was made for (Coast v0.2): ' + $f.rel) 'Yellow'
        Say ('(found ' + $now + ', expected ' + $f.orig + '). Nothing was changed.') 'Yellow'; Finish 1
    }
}
if (Test-Path -LiteralPath $Night) {
    if (-not (Test-Path -LiteralPath (Join-Path $Night $MARKER))) {
        Say ('A folder named ' + $NIGHT_NAME + ' already exists and this installer did not make it. Nothing was changed.') 'Yellow'; Finish 1
    }
    Remove-Item -LiteralPath $Night -Recurse -Force   # rebuild it fresh
}

try {
    New-Item -ItemType Directory -Force -Path $Night | Out-Null
    Set-Content -LiteralPath (Join-Path $Night $MARKER) -Value 'This folder was made by coast-night-dark. UNINSTALL.bat removes it.' -Encoding ASCII
    $linked = 0; $copied = 0
    Get-ChildItem -LiteralPath $TrackPath -Recurse -File | ForEach-Object {
        $rel = $_.FullName.Substring($TrackPath.Length).TrimStart([char]92)
        if ($rel -like '*.pdn' -or $rel -like ('*' + $OLD_SUFFIX)) { return }
        $dst = Join-Path $Night $rel
        New-Item -ItemType Directory -Force -Path (Split-Path $dst) | Out-Null
        $ok = $false
        try { New-Item -ItemType HardLink -Path $dst -Target $_.FullName -ErrorAction Stop | Out-Null; $ok = $true } catch { }
        if ($ok) { $linked++ } else { Copy-Item -LiteralPath $_.FullName -Destination $dst -Force; $copied++ }
    }
    # A hard link shares its bytes with the original, so each file that differs is removed first, then written.
    foreach ($f in $FILES) {
        $dst = Join-Path $Night $f.rel
        Remove-Item -LiteralPath $dst -Force
        Copy-Item -LiteralPath (Join-Path $Payload $f.rel) -Destination $dst
        if ((ShortSha $dst) -ne $f.dark) { throw ('did not copy correctly: ' + $f.rel) }
    }
    $ui = Join-Path $Night 'ui\ui_track.json'
    $text = [System.IO.File]::ReadAllText($ui)
    if ($text -notmatch '"name"\s*:\s*"Coast"') { throw 'ui_track.json does not name the track "Coast"' }
    $text = [regex]::Replace($text, '"name"\s*:\s*"Coast"', '"name": "Coast Night"', 1)
    $text = [regex]::Replace($text, '"description"\s*:\s*"([^"]*)"', '"description": "$1 Night Dark: the stadium floodlights are off at night; the lamps in the road stay lit."', 1)
    Remove-Item -LiteralPath $ui -Force
    [System.IO.File]::WriteAllText($ui, $text, (New-Object System.Text.UTF8Encoding($false)))
    Get-ChildItem -LiteralPath (Join-Path $Night 'skins') -Recurse -Filter 'ui_track_skin.json' -ErrorAction SilentlyContinue | ForEach-Object {
        $t = [System.IO.File]::ReadAllText($_.FullName)
        $t2 = [regex]::Replace($t, '"track"\s*:\s*"coast"', '"track": "' + $NIGHT_NAME + '"')
        Remove-Item -LiteralPath $_.FullName -Force
        [System.IO.File]::WriteAllText($_.FullName, $t2, (New-Object System.Text.UTF8Encoding($false)))
    }
    # the original must be untouched
    foreach ($f in $FILES) { if ((ShortSha (Join-Path $TrackPath $f.rel)) -ne $f.orig) { throw ('the original changed: ' + $f.rel) } }
} catch {
    Say ('Failed: ' + $_.Exception.Message) 'Red'
    if (Test-Path -LiteralPath $Night) { Remove-Item -LiteralPath $Night -Recurse -Force }
    Say 'The half-made Coast Night folder was removed. Coast itself was not changed.' 'Yellow'; Finish 1
}
Say ''
Say ('Installed: ' + $Night) 'Green'
Say ("($linked files shared with Coast, $copied copied.)") 'DarkGray'
Say 'In Content Manager press F5, then pick "Coast Night" and set the time to night.'
Say 'The original Coast is unchanged. To remove Coast Night, double-click UNINSTALL.bat.'
Finish 0
