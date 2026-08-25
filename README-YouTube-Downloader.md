# YouTube Playlist Downloader

A PowerShell wrapper around [`yt-dlp`](https://github.com/yt-dlp/yt-dlp) that downloads
your YouTube playlists into tidy, per-playlist folders. Safe to re-run — it only grabs
what's new.

## Quick start (Windows)

1. Open **PowerShell** in this folder.
2. If scripts are blocked, allow this session to run local scripts:
   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   ```
3. Run it:
   ```powershell
   .\Download-YouTubePlaylists.ps1
   ```

On first run it will install `yt-dlp` and `ffmpeg` for you via `winget` if they're
missing.

## Ways to run it

```powershell
# Pass one or more playlist URLs directly
.\Download-YouTubePlaylists.ps1 -Url "https://www.youtube.com/playlist?list=XXXX"

# Read URLs from playlists.txt (one per line) — just run with no arguments
.\Download-YouTubePlaylists.ps1

# Audio only, extracted to mp3
.\Download-YouTubePlaylists.ps1 -AudioOnly

# Cap quality (e.g. 1080p, 720p)
.\Download-YouTubePlaylists.ps1 -Quality 1080

# Choose where files go
.\Download-YouTubePlaylists.ps1 -OutputDir "D:\Media\YouTube"
```

## What you get

- One subfolder per playlist, named after the playlist. Single videos go in `Singles`.
- Files numbered by playlist position so they sort correctly.
- Embedded metadata + thumbnail, English subtitles (video mode), and an `.info.json` per video.
- A `downloaded.txt` archive in the output folder so re-runs skip anything already saved —
  run it again any time to "sync" new additions.

## Notes

- Private or removed videos are skipped with a warning; the rest still download.
- If YouTube changes and downloads start failing, the script auto-updates `yt-dlp` on each run,
  but you can also force it: `yt-dlp -U`.
- Only download content you have the right to download.
