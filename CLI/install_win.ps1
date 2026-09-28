Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Installing PS1, PS2 & PSP ISO Compressor (Win TUI)" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

$installDir = "$env:LOCALAPPDATA\iso-compressor"
New-Item -ItemType Directory -Force -Path $installDir | Out-Null

Write-Host "Downloading core engine..."
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/wako69420/iso-compressor/master/CLI/windows/maxcso.exe?t=$([guid]::NewGuid().ToString())" -OutFile "$installDir\maxcso.exe"

Write-Host "Downloading TUI wrapper..."

    
$batPath = "$installDir\iso-compressor.bat"
$tmpBat = "$installDir\iso-compressor.bat.new"

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/wako69420/iso-compressor/master/CLI/windows/iso-compressor.bat?t=$([guid]::NewGuid().ToString())" -OutFile $tmpBat

if (Test-Path $batPath) {
    Remove-Item "$installDir\iso-compressor.old.bat" -Force -ErrorAction SilentlyContinue
    Rename-Item -Path $batPath -NewName "iso-compressor.old.bat" -Force -ErrorAction SilentlyContinue
}

Move-Item -Path $tmpBat -Destination $batPath -Force

Write-Host "Update installed! Relaunching..." -ForegroundColor Green
Start-Sleep -Seconds 1

Start-Process "cmd.exe" -ArgumentList "/c title ISO Compressor & `"$batPath`""

# Kill the parent CMD process so the old loop dies
try {
    $parent = (Get-CimInstance Win32_Process -Filter "ProcessId=$PID").ParentProcessId
    if ($parent) { Stop-Process -Id $parent -Force -ErrorAction SilentlyContinue }
} catch {}

Stop-Process -Id $PID -Force
