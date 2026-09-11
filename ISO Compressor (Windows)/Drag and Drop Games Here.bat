@echo off
title PSP Game Compressor (ZSO ^& CSO)
color 0B
setlocal EnableDelayedExpansion

if "%~1"=="" (
    echo =======================================================
    echo           PSP GAME COMPRESSOR (ZSO ^& CSO)
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
echo           PSP GAME COMPRESSOR (ZSO ^& CSO)
echo =======================================================
echo.
echo NOTE: 
echo - CSO format is for PPSSPP Emulators on PC/Mac/Phone.
echo - ZSO format is for ACTUAL PSP Hardware running ARK-5.
echo.
echo Please choose your conversion target:
echo.
echo  [1] ISO to CSO (For PPSSPP)
echo  [2] CSO to ZSO (For Real PSP)
echo  [3] ISO to ZSO (For Real PSP)
echo.
set /p choice="Type 1, 2, or 3 and press Enter: "

if "%choice%"=="1" (
    set format=cso
) else if "%choice%"=="2" (
    set format=zso
) else if "%choice%"=="3" (
    set format=zso
) else (
    goto menu
)

cls
echo =======================================================
echo               COMPRESSION IN PROGRESS
echo =======================================================
echo.

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
pause
