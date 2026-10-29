# Build and package Nexora Suite for Windows (run on Windows PowerShell)
$ErrorActionPreference = "Stop"
$version = "26.10.29"

flutter pub get
flutter build windows --release

$src = "build\windows\x64\release\bundle"
$dst = "NexoraSuite-$version-windows"
if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
New-Item -ItemType Directory -Path $dst | Out-Null
Copy-Item "$src\*" $dst -Recurse -Force
Copy-Item "assets\icons\Logo-Launcher.png" "$dst\nexora-suite.png"

Compress-Archive -Path $dst -DestinationPath "NexoraSuite-$version-windows.zip" -Force
Write-Host "Created NexoraSuite-$version-windows.zip"
