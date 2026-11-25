# Coast (T-180) - Night Dark : installer / uninstaller
# Run it by double-clicking INSTALL.bat or UNINSTALL.bat. ASCII only on purpose (Windows PowerShell 5.1).
param([switch]$Uninstall, [switch]$NoPause, [string]$TrackPath = '')
$ErrorActionPreference = 'Stop'
# first 16 hex of sha256: the shipped v0.2 file, and the same file made dark
$FILES = @(
    @{ rel = 'extension\ext_config.ini';           orig = '811035A31821D440'; dark = '240C5EF64F272F52' },
    @{ rel = 'skins\cm_skins\Gold\ext_config.ini'; orig = 'B3E0D8A71A8A8106'; dark = 'F3FE29CE9940A771' },
    @{ rel = 'skins\cm_skins\Fuji\ext_config.ini'; orig = 'B3E0D8A71A8A8106'; dark = 'F3FE29CE9940A771' }
)
$SUFFIX = '.before-night-dark'
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
Say ('Found the track: ' + $TrackPath)

if ($Uninstall) {
    $n = 0
    foreach ($f in $FILES) {
        $cfg = Join-Path $TrackPath $f.rel; $bak = $cfg + $SUFFIX
        if (Test-Path -LiteralPath $bak) {
            Copy-Item -LiteralPath $bak -Destination $cfg -Force; Remove-Item -LiteralPath $bak -Force; $n++
        }
    }
    if ($n -eq 0) { Say 'Night Dark does not look installed (no backups found). Nothing was changed.' 'Yellow'; Finish 1 }
    Say 'Removed. Coast has its original lighting back.' 'Green'; Finish 0
}

# check everything before changing anything
$todo = @()
foreach ($f in $FILES) {
    $cfg = Join-Path $TrackPath $f.rel
    if (-not (Test-Path -LiteralPath $cfg)) { Say ('Skipping (not present): ' + $f.rel) 'DarkGray'; continue }
    $now = ShortSha $cfg
    if ($now -eq $f.dark) { Say ('Already dark: ' + $f.rel) 'DarkGray'; continue }
    if ($now -ne $f.orig) {
        Say ('This file is not the version this was made for (Coast v0.2): ' + $f.rel) 'Yellow'
        Say ('(found ' + $now + ', expected ' + $f.orig + '). Nothing was changed.') 'Yellow'; Finish 1
    }
    $todo += $f
}
if ($todo.Count -eq 0) { Say 'Night Dark is already installed. Nothing to do.' 'Green'; Finish 0 }
$done = @()
try {
    foreach ($f in $todo) {
        $cfg = Join-Path $TrackPath $f.rel
        Copy-Item -LiteralPath $cfg -Destination ($cfg + $SUFFIX) -Force
        $done += $f
        Copy-Item -LiteralPath (Join-Path $Payload $f.rel) -Destination $cfg -Force
        if ((ShortSha $cfg) -ne $f.dark) { throw ('did not copy correctly: ' + $f.rel) }
    }
} catch {
    Say ('Failed: ' + $_.Exception.Message) 'Red'
    foreach ($f in $done) {
        $cfg = Join-Path $TrackPath $f.rel
        Copy-Item -LiteralPath ($cfg + $SUFFIX) -Destination $cfg -Force; Remove-Item -LiteralPath ($cfg + $SUFFIX) -Force
    }
    Say 'Everything was put back the way it was. Close the game and Content Manager, then try again.' 'Yellow'; Finish 1
}
Say ''; Say 'Installed! Set the time to night and race.' 'Green'
Say 'To put the original lighting back, double-click UNINSTALL.bat.'
Finish 0
