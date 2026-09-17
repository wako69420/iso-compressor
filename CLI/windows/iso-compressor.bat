@echo off
title PS1, PS2 ^& PSP Game Compressor (CHD, ZSO ^& CSO)
color 0B
setlocal EnableDelayedExpansion

set ENGINE_PATH=%LOCALAPPDATA%\iso-compressor\maxcso.exe

if not exist "%ENGINE_PATH%" (
    echo Error: maxcso.exe engine not found at %ENGINE_PATH%
    echo Please reinstall using the PowerShell command from GitHub.
    pause
    exit /b
)

:menu
cls
echo =======================================================
echo           PS1, PS2 ^& PSP GAME COMPRESSOR (CHD, ZSO, CSO)
echo =======================================================
echo.
echo NOTE:
echo - CHD format is the ultimate standard for PS1 ^& PS2 Emulators (Requires chdman).
echo - CSO format is for Emulators (PPSSPP ^& PCSX2) on PC/Mac/Phone.
echo - ZSO format is for ACTUAL PSP (ARK-5) ^& PS2 (OPL) Hardware.
echo.
echo Please choose an option:
echo.
echo  [1] CUE/ISO to CHD (For PS1/PS2 Emulators)
echo  [2] ISO to CSO (For PSP Emulators)
echo  [3] CSO to ZSO (For Real Hardware)
echo  [4] ISO to ZSO (For Real Hardware)
echo  [5] Install CHDMAN (For CHD Support)
echo  [6] Auto-Update CLI Tool
echo  [7] About / License
echo  [8] Uninstall CLI Tool
echo  [9] Exit
echo.
set /p choice="Type 1, 2, 3, 4, 5, 6, 7, 8, or 9 and press Enter: "

if "%choice%"=="1" (
    set format=chd
) else if "%choice%"=="2" (
    set format=cso
) else if "%choice%"=="3" (
    set format=zso
) else if "%choice%"=="4" (
    set format=zso
) else if "%choice%"=="5" (
    goto install_chdman
) else if "%choice%"=="6" (
    goto auto_update
) else if "%choice%"=="7" (
    goto about
) else if "%choice%"=="8" (
    goto uninstall
) else if "%choice%"=="9" (
    exit
) else (
    goto menu
)

echo.
set /p filepath="Drag and drop your .ISO, .CSO, or .CUE file here and press Enter: "

cls
echo =======================================================
echo               COMPRESSION IN PROGRESS
echo =======================================================
echo.
if "%format%"=="chd" (
    where chdman >nul 2>nul
    if %errorlevel% neq 0 (
        echo Error: chdman is not installed or not in PATH.
        echo Please use option [5] in the menu to install it.
        pause
        goto menu
    )
    for %%I in (%filepath%) do set "ext=%%~xI"
    for %%I in (%filepath%) do set "outfile=%%~dpnI.chd"
    if /I "!ext!"==".cue" (
        chdman createcd -i %filepath% -o "!outfile!"
    ) else (
        chdman createdvd -i %filepath% -o "!outfile!"
    )
) else (
    "%ENGINE_PATH%" --format=%format% %filepath%
)

echo.
echo =======================================================
echo                   ALL DONE!
echo =======================================================
pause
goto menu

:install_chdman
cls
echo =======================================================
echo                   INSTALL CHDMAN
echo =======================================================
echo.
echo CHD is the ultimate lossless compression format for PS1 and PS2 Emulators.
echo To create CHD files, this app needs a free tool called 'chdman'.
echo.
echo Attempting to install via winget (MAME package)...
winget install -e --id mamedev.MAME
echo.
echo Note: If winget fails, please download MAME manually from mamedev.org and add it to your PATH.
pause
goto menu

:auto_update
cls
echo =======================================================
echo                 AUTO-UPDATING TOOL
echo =======================================================
echo Fetching latest version from GitHub...
powershell -Command "irm https://raw.githubusercontent.com/wako69420/iso-compressor/master/CLI/install_win.ps1 | iex"
exit /b


:uninstall
cls
echo =======================================================
echo                   UNINSTALL TOOL
echo =======================================================
echo This will completely remove the CLI tool and its backend files from your system.
set /p confirm="Are you sure you want to uninstall? (y/n): "
if /i "%confirm%"=="y" (
    echo Removing backend engine...
    rmdir /s /q "%LOCALAPPDATA%\iso-compressor"
    echo Uninstallation complete. Please close this window.
    pause
    exit /b
) else (
    echo Uninstallation cancelled.
    pause
    goto menu
)

:about
cls
echo =======================================================
echo                 ABOUT ^& LICENSE
echo =======================================================
echo.
echo PS1, PS2 ^& PSP ISO Compressor v1.4.0
echo A free, open-source tool for compressing massive PS1, PS2 ^& PSP games.
echo.
echo GitHub Repository: 
echo https://github.com/wako69420/iso-compressor
echo.
echo License: MIT License
echo.
echo Credits:
echo - maxcso engine by unknownbrackets
echo - CHD format ^& chdman by MAME Team
echo - ZSO support (PSP) by ARK-5 Team
echo - ZSO support (PS2) by OPL Team
echo.
echo =======================================================
pause
goto menu
