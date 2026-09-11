@echo off
title PSP Game Compressor (ZSO ^& CSO)
color 0B
setlocal EnableDelayedExpansion

if "%~1"=="" (
    goto menu
) else (
    goto fastconvert
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
echo Please choose an option:
echo.
echo  [1] ISO to CSO (For PPSSPP)
echo  [2] CSO to ZSO (For Real PSP)
echo  [3] ISO to ZSO (For Real PSP)
echo  [4] About / License
echo  [5] Exit
echo.
set /p choice="Type 1, 2, 3, 4, or 5 and press Enter: "

if "%choice%"=="1" (
    set format=cso
) else if "%choice%"=="2" (
    set format=zso
) else if "%choice%"=="3" (
    set format=zso
) else if "%choice%"=="4" (
    goto about
) else if "%choice%"=="5" (
    exit
) else (
    goto menu
)

:fastconvert
if not defined format (
    cls
    echo Please select the format for the dropped files:
    echo  [1] ZSO (For Real PSP Hardware)
    echo  [2] CSO (For PPSSPP Emulator)
    set /p fastchoice="Type 1 or 2: "
    if "!fastchoice!"=="2" (set format=cso) else (set format=zso)
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
exit

:about
cls
echo =======================================================
echo                 ABOUT ^& LICENSE
echo =======================================================
echo.
echo ISO/CSO Compressor v1.0
echo A free, open-source tool for compressing massive PSP games.
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
