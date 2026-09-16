@echo off
title PS1, PS2 ^& PSP Game Compressor (ZSO ^& CSO)
color 0B
setlocal EnableDelayedExpansion

set ENGINE_PATH=%LOCALAPPDATA%\psp-compressor\maxcso.exe

if not exist "%ENGINE_PATH%" (
    echo Error: maxcso.exe engine not found at %ENGINE_PATH%
    echo Please reinstall using the PowerShell command from GitHub.
    pause
    exit /b
)

:menu
cls
echo =======================================================
echo           PS1, PS2 ^& PSP GAME COMPRESSOR (ZSO ^& CSO)
echo =======================================================
echo.
echo NOTE:
- CHD format is the ultimate standard for PS1 & PS2 Emulators (Requires chdman).
echo - CSO format is for Emulators (PPSSPP & PCSX2) on PC/Mac/Phone.
echo - ZSO format is for ACTUAL PSP (ARK-5) & PS2 (OPL) Hardware.
echo.
echo Please choose an option:
echo.
echo  [1] ISO to CHD (For PS1/PS2 Emulators)
 [2] ISO to CSO (For PSP Emulators)
echo  [3] CSO to ZSO (For Real Hardware)
echo  [4] ISO to ZSO (For Real Hardware)
echo  [5] About / License
echo  [6] Exit
echo.
set /p choice="Type 1, 2, 3, 4, 5, or 6 and press Enter: "

if "%choice%"=="1" (
    set format=chd
) else if "%choice%"=="6" (
    set format=cso
) else if "%choice%"=="6" (
    set format=zso
) else if "%choice%"=="6" (
    set format=zso
) else if "%choice%"=="6" (
    goto about
) else if "%choice%"=="6" (
    exit
) else (
    goto menu
)

echo.
set /p filepath="Drag and drop your .ISO or .CSO file here and press Enter: "

cls
echo =======================================================
echo               COMPRESSION IN PROGRESS
echo =======================================================
echo.
if "%format%"=="chd" (
    where chdman >nul 2>nul
    if %errorlevel% neq 0 (
        echo Error: chdman is not installed or not in PATH.
        echo Please download chdman.exe or install MAME.
        pause
        exit /b
    )
    for %%I in (%filepath%) do set "outfile=%%~dpnI.chd"
    chdman createdvd -i %filepath% -o "!outfile!"
) else (
    "%ENGINE_PATH%" --format=%format% %filepath%
)

echo.
echo =======================================================
echo                   ALL DONE!
echo =======================================================
pause
exit /b

:about
cls
echo =======================================================
echo                 ABOUT ^& LICENSE
echo =======================================================
echo.
echo ISO/CSO Compressor v1.0
echo A free, open-source tool for compressing massive PSP & PS2 games.
echo.
echo GitHub Repository: 
echo https://github.com/wako69420/psp-iso-compressor
echo.
echo License: MIT License
echo.
echo Credits:
echo - maxcso engine by unknownbrackets
echo - ZSO support powered by ARK-5 Team
echo.
echo =======================================================
pause
goto menu
