Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Installing PS1, PS2 & PSP ISO Compressor (Win TUI)" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

$installDir = "$env:LOCALAPPDATA\iso-compressor"
New-Item -ItemType Directory -Force -Path $installDir | Out-Null

Write-Host "Downloading core engine..."
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/wako69420/iso-compressor/master/CLI/windows/maxcso.exe" -OutFile "$installDir\maxcso.exe"

Write-Host "Downloading TUI wrapper..."
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/wako69420/iso-compressor/master/CLI/windows/iso-compressor.bat" -OutFile "$installDir\iso-compressor.bat"

Write-Host "Adding to system PATH..."
$envPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($envPath -notmatch [regex]::Escape($installDir)) {
    [Environment]::SetEnvironmentVariable("PATH", "$envPath;$installDir", "User")
    $env:PATH = "$env:PATH;$installDir"
}

Write-Host ""
Write-Host "Success! You can now launch the interactive menu from any Command Prompt or PowerShell window by typing:" -ForegroundColor Green
Write-Host "iso-compressor" -ForegroundColor Yellow
