@echo off
title PSP ISO/CSO Compressor - by maxcso
color 0B
setlocal EnableDelayedExpansion

:: Check if files were dropped onto the script
if "%~1"=="" (
    echo =======================================================
    echo           PSP ISO COMPRESSOR (ZSO ^& CSO)
    echo =======================================================
    echo.
    echo  ERROR: You opened the script directly!
    echo.
    echo  HOW TO USE:
    echo  Do not double-click this file. Instead, highlight your
    echo  .ISO or .CSO games, drag them with your mouse, and
    echo  DROP them directly on top of this script icon!
    echo.
    echo =======================================================
    pause
    exit /b
)

:menu
cls
echo =======================================================
echo           PSP ISO COMPRESSOR (ZSO ^& CSO)
echo =======================================================
echo.
echo Please choose your target console/emulator:
echo.
echo  [1] ZSO Format (For REAL Physical PSP Hardware with CFW)
echo      - Uses ultra-fast LZ4 compression to stop lag spikes.
echo.
echo  [2] CSO Format (For PPSSPP Emulators on PC/Mac/Phone)
echo      - The classic format. PPSSPP does not support ZSO yet.
echo.
set /p choice="Type 1 or 2 and press Enter: "

if "%choice%"=="1" (
    set format=zso
) else if "%choice%"=="2" (
    set format=cso
) else (
    goto menu
)

cls
echo =======================================================
echo               COMPRESSION IN PROGRESS
echo =======================================================
echo.

:: Loop through all dragged files
:loop
if "%~1"=="" goto end
echo Processing: "%~nx1"
"%~dp0maxcso.exe" --format=%format% "%~1"
echo.
shift
goto loop

:end
echo =======================================================
echo                   ALL DONE!
echo =======================================================
echo.
echo Your compressed games have been placed in the exact same 
echo folder as your original games. 
echo.
echo You can now close this window.
pause
