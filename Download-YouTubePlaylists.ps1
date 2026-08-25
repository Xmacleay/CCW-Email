<#
.SYNOPSIS
    Downloads one or more YouTube playlists (or single videos) using yt-dlp.

.DESCRIPTION
    A wrapper around yt-dlp that:
      * checks for yt-dlp and ffmpeg, and offers to install them via winget if missing
      * downloads each playlist into its own folder, named after the playlist
      * skips videos you've already downloaded (safe to re-run to "sync")
      * keeps a download archive so re-runs are fast
      * saves thumbnails, metadata, and (when available) subtitles

.PARAMETER Url
    One or more playlist or video URLs. If omitted, you'll be prompted,
    or the script reads URLs from playlists.txt next to the script.

.PARAMETER OutputDir
    Where to save everything. Defaults to a "YouTube" folder in your
    Videos directory.

.PARAMETER AudioOnly
    Download audio only (extracted to mp3) instead of full video.

.PARAMETER Quality
    Max video height, e.g. 1080, 720, 480. Default is "best".

.EXAMPLE
    .\Download-YouTubePlaylists.ps1 -Url "https://www.youtube.com/playlist?list=XXXX"

.EXAMPLE
    .\Download-YouTubePlaylists.ps1        # reads playlists.txt or prompts

.EXAMPLE
    .\Download-YouTubePlaylists.ps1 -AudioOnly -Quality 720
#>

[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Url,

    [string]$OutputDir = (Join-Path ([Environment]::GetFolderPath('MyVideos')) 'YouTube'),

    [switch]$AudioOnly,

    [string]$Quality = 'best',

    # For private playlists (e.g. "Liked Music", list=LM) yt-dlp must be logged in.
    # Pass the browser you're signed into YouTube with: chrome, edge, firefox, brave.
    [ValidateSet('chrome', 'edge', 'firefox', 'brave', 'chromium', 'opera', 'vivaldi', 'safari')]
    [string]$CookiesFromBrowser
)

$ErrorActionPreference = 'Stop'

function Test-Command($name) {
    return [bool](Get-Command $name -ErrorAction SilentlyContinue)
}

function Install-WithWinget($id, $friendlyName) {
    if (-not (Test-Command 'winget')) {
        Write-Warning "$friendlyName is not installed, and winget isn't available to install it automatically."
        Write-Host "Please install $friendlyName manually, then re-run this script." -ForegroundColor Yellow
        exit 1
    }
    Write-Host "Installing $friendlyName via winget..." -ForegroundColor Cyan
    winget install --id $id --accept-source-agreements --accept-package-agreements -e
    # Refresh PATH for the current session so the new tool is found immediately.
    $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [System.Environment]::GetEnvironmentVariable('Path', 'User')
}

# --- Ensure dependencies -----------------------------------------------------

if (-not (Test-Command 'yt-dlp')) {
    Write-Host "yt-dlp not found." -ForegroundColor Yellow
    Install-WithWinget 'yt-dlp.yt-dlp' 'yt-dlp'
    if (-not (Test-Command 'yt-dlp')) {
        Write-Warning "yt-dlp still not found after install. Open a new terminal and try again."
        exit 1
    }
} else {
    # Keep yt-dlp current; YouTube changes often and an old yt-dlp breaks.
    Write-Host "Updating yt-dlp to the latest version..." -ForegroundColor Cyan
    try { yt-dlp -U } catch { Write-Warning "Could not auto-update yt-dlp (continuing anyway): $_" }
}

if (-not (Test-Command 'ffmpeg')) {
    Write-Host "ffmpeg not found (needed to merge video/audio and extract mp3)." -ForegroundColor Yellow
    Install-WithWinget 'Gyan.FFmpeg' 'ffmpeg'
}

# --- Gather URLs -------------------------------------------------------------

if (-not $Url -or $Url.Count -eq 0) {
    $listFile = Join-Path $PSScriptRoot 'playlists.txt'
    if (Test-Path $listFile) {
        Write-Host "Reading playlist URLs from $listFile" -ForegroundColor Cyan
        $Url = Get-Content $listFile |
               Where-Object { $_.Trim() -and -not $_.Trim().StartsWith('#') }
    }
}

if (-not $Url -or $Url.Count -eq 0) {
    Write-Host "Paste a YouTube playlist or video URL (or press Enter to finish):" -ForegroundColor Cyan
    $collected = @()
    while ($true) {
        $line = Read-Host 'URL'
        if ([string]::IsNullOrWhiteSpace($line)) { break }
        $collected += $line.Trim()
    }
    $Url = $collected
}

if (-not $Url -or $Url.Count -eq 0) {
    Write-Warning "No URLs provided. Nothing to do."
    exit 0
}

# --- Build yt-dlp arguments --------------------------------------------------

New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
$archive = Join-Path $OutputDir 'downloaded.txt'

$modeText = if ($AudioOnly) { 'Audio only (mp3)' } else { 'Video' }
Write-Host ""
Write-Host "Output folder : $OutputDir" -ForegroundColor Green
Write-Host "Mode          : $modeText" -ForegroundColor Green
Write-Host "Quality       : $Quality" -ForegroundColor Green
Write-Host "Playlists     : $($Url.Count)" -ForegroundColor Green
Write-Host ""

# Each playlist goes in its own subfolder; single videos land in "Singles".
# playlist_index is zero-padded so files sort in playlist order.
$outputTemplate = Join-Path $OutputDir '%(playlist_title|Singles)s\%(playlist_index>03d|)s - %(title)s [%(id)s].%(ext)s'

$common = @(
    '--ignore-errors'                 # keep going if one video is unavailable
    '--download-archive', $archive    # remember what we've already grabbed
    '--no-overwrites'
    '--continue'                      # resume partial downloads
    '--restrict-filenames'            # safe, Windows-friendly filenames
    '--windows-filenames'
    '--embed-metadata'
    '--embed-thumbnail'
    '--write-thumbnail'
    '--write-info-json'
    '--sponsorblock-mark', 'all'      # marks chapters; remove if unwanted
    '--retries', '10'
    '--fragment-retries', '10'
    '--concurrent-fragments', '4'
    '-o', $outputTemplate
)

# Log in via your browser's cookies so private playlists (Liked Music, etc.) work.
if ($CookiesFromBrowser) {
    Write-Host "Using $CookiesFromBrowser cookies for authentication." -ForegroundColor Cyan
    $common += @('--cookies-from-browser', $CookiesFromBrowser)
}

if ($AudioOnly) {
    $format = @(
        '--extract-audio'
        '--audio-format', 'mp3'
        '--audio-quality', '0'
    )
} else {
    if ($Quality -eq 'best') {
        $format = @('-f', 'bv*+ba/b', '--merge-output-format', 'mp4')
    } else {
        $format = @('-f', "bv*[height<=$Quality]+ba/b[height<=$Quality]", '--merge-output-format', 'mp4')
    }
    # Subtitles only make sense for video downloads.
    $format += @('--write-subs', '--write-auto-subs', '--sub-langs', 'en.*', '--embed-subs')
}

# --- Download ----------------------------------------------------------------

$failed = @()
foreach ($u in $Url) {
    Write-Host ""
    Write-Host "==> Downloading: $u" -ForegroundColor Magenta
    try {
        yt-dlp @common @format -- $u
        if ($LASTEXITCODE -ne 0) { $failed += $u }
    } catch {
        Write-Warning "Error while downloading $u : $_"
        $failed += $u
    }
}

Write-Host ""
if ($failed.Count -eq 0) {
    Write-Host "All done. Files are in: $OutputDir" -ForegroundColor Green
} else {
    Write-Warning "Finished, but these URLs had errors (some videos may be private/removed):"
    $failed | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow }
    Write-Host "Re-running the script will retry only what's missing." -ForegroundColor Yellow
}
