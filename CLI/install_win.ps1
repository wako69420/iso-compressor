Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Installing PSP ISO Compressor (Win CLI)" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Downloading engine..."
$dest = "$env:LOCALAPPDATA\Microsoft\WindowsApps\psp-compressor.exe"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/wako69420/psp-iso-compressor/master/ISO%20Compressor%20(Windows)/maxcso.exe" -OutFile $dest
Write-Host ""
Write-Host "Success! You can now use the tool from any Command Prompt or PowerShell window." -ForegroundColor Green
Write-Host "Usage: psp-compressor --format=zso `"C:\path\to\game.iso`"" -ForegroundColor Yellow
