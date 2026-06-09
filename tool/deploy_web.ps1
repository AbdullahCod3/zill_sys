# Publish the Flutter web app to the Dart Frog backend (what the tunnel serves).
#
# The tunnel/ngrok URL points at `dart_frog dev` (:8080), which serves the static
# snapshot in `backend/public/` — NOT your live source. That folder only updates
# when you rebuild and copy, which is exactly what this script does. Run it after
# any client change you want visible on the tunnel, then hard-reload the browser
# (Ctrl+Shift+R) so the cached service worker / main.dart.js is replaced.
#
# Usage (from the project root):  ./tool/deploy_web.ps1

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$pub  = Join-Path $root 'backend/public'

# --pwa-strategy=none disables the Flutter service worker so the tunnel always
# serves fresh code (the SW otherwise caches the old app in the browser and a
# hard-reload won't dislodge it).
Write-Host '==> flutter build web --pwa-strategy=none' -ForegroundColor Cyan
Push-Location $root
try { flutter build web --pwa-strategy=none } finally { Pop-Location }

Write-Host '==> clearing backend/public (keeping .gitkeep)' -ForegroundColor Cyan
Get-ChildItem -Path $pub -Force |
  Where-Object { $_.Name -ne '.gitkeep' } |
  Remove-Item -Recurse -Force

Write-Host '==> copying build/web -> backend/public' -ForegroundColor Cyan
Copy-Item -Path (Join-Path $root 'build/web/*') -Destination $pub -Recurse -Force

$built = (Get-Item (Join-Path $pub 'main.dart.js')).LastWriteTime
Write-Host "Done. Served main.dart.js: $built" -ForegroundColor Green
Write-Host 'Restart dart_frog dev if running, then hard-reload the tunnel URL (Ctrl+Shift+R).' -ForegroundColor Yellow
