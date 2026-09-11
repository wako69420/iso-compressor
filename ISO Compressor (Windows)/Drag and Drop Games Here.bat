@echo off
setlocal
echo =======================================
echo PSP ISO Compressor by maxcso
echo =======================================
echo.
echo Please select the format you want to compress to:
echo [1] ZSO (For REAL Physical PSP Hardware with CFW)
echo [2] CSO (For PPSSPP Emulators on PC/Mac)
echo.
set /p choice="Enter 1 or 2: "
if "%choice%"=="2" (
    set format=cso
) else (
    set format=zso
)
echo.
:loop
if "%~1"=="" goto end
echo Compressing: %~1
"%~dp0maxcso.exe" --format=%format% "%~1"
shift
goto loop
:end
echo.
echo All conversions are complete!
pause
