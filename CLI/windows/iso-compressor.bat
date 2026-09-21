@echo off
title PS1, PS2 ^& PSP Game Compressor (CHD, ZSO ^& CSO)
color 0B
setlocal EnableDelayedExpansion

set ENGINE_PATH=%LOCALAPPDATA%\iso-compressor\maxcso.exe
set APP_VERSION=v1.4.2


if not exist "%ENGINE_PATH%" (
    echo Error: maxcso.exe engine not found at %ENGINE_PATH%
    echo Please reinstall using the PowerShell command from GitHub.
    pause
    exit /b
)

echo Checking for updates...
for /f "delims=" %%A in ('powershell -Command "(Invoke-RestMethod -Uri 'https://api.github.com/repos/wako69420/iso-compressor/releases/latest' -TimeoutSec 2).tag_name" 2^>nul') do set "LATEST_VER=%%A"
if not "!LATEST_VER!"=="" if not "!LATEST_VER!"=="%APP_VERSION%" (
    echo =======================================================
    echo   UPDATE AVAILABLE: !LATEST_VER! ^(Current: %APP_VERSION%^)
    echo =======================================================
    set /p do_update="Would you like to update now? (y/n): "
    if /I "!do_update!"=="y" (
        powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/wako69420/iso-compressor/master/CLI/windows/iso-compressor.bat?t=' + [guid]::NewGuid().ToString() -OutFile '%LOCALAPPDATA%\iso-compressor\iso-compressor.bat'"
    echo Update complete. Please restart the tool.
        exit /b
    )
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

echo =======================================================
echo                  QUICK COMPRESSION GUIDE               
echo =======================================================
echo  . PS1 Games (.CUE) ---^> ONLY use CHD (For Emulators)
echo  . PS2 Games (.ISO) ---^> Use CHD (Emulation) or ZSO (Real Console)
echo  . PSP Games (.ISO) ---^> Use CSO (Emulation) or ZSO (Real Console)
echo =======================================================
echo  [1] CUE/ISO to CHD (For PS1/PS2 Emulators)
echo  [2] ISO to CSO (For PSP Emulators)
echo  [3] CSO to ZSO (For Real Hardware)
echo  [4] ISO to ZSO (For Real Hardware)
echo  [5] Batch Compress a Folder
echo  [6] Install / Uninstall CHDMAN (For PS1/PS2 Emulators)
echo  [7] Auto-Update CLI Tool
echo  [8] About / License
echo  [9] Uninstall CLI Tool
echo  [10] Exit
echo.
set /p choice="Type a number and press Enter: "

if "%choice%"=="1" (
    set format=chd
) else if "%choice%"=="2" (
    set format=cso1
) else if "%choice%"=="3" (
    set format=zso
) else if "%choice%"=="4" (
    set format=zso
) else if "%choice%"=="5" (
    goto batch_compress
) else if "%choice%"=="6" (
    goto manage_chdman
) else if "%choice%"=="7" (
    goto auto_update
) else if "%choice%"=="8" (
    goto about
) else if "%choice%"=="9" (
    goto uninstall
) else if "%choice%"=="10" (
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
    if not exist "%LOCALAPPDATA%\iso-compressor\chdman.exe" (
        echo Error: chdman.exe engine is not installed.
        echo Please use option [5] in the menu to install it.
        pause
        goto menu
    )
    for %%I in (%filepath%) do set "ext=%%~xI"
    for %%I in (%filepath%) do set "outfile=%%~dpnI.chd"
    if /I "!ext!"==".cue" (
        "%LOCALAPPDATA%\iso-compressor\chdman.exe" createcd -i %filepath% -o "!outfile!"
    ) else (
        "%LOCALAPPDATA%\iso-compressor\chdman.exe" createdvd -i %filepath% -o "!outfile!"
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

:batch_compress
cls
echo =======================================================
echo               BATCH COMPRESS A FOLDER
echo =======================================================
echo.
set /p folderpath="Drag and drop your folder here and press Enter: "
set "folderpath=!folderpath:"=!"

echo.
echo What format do you want to convert these games into?
echo [1] CHD (PS1/PS2 Emulators)
echo [2] CSO (PSP Emulators)
echo [3] ZSO (Real Hardware)
set /p batch_format_choice="Select format: "

set batch_format=
if "%batch_format_choice%"=="1" set batch_format=chd
if "%batch_format_choice%"=="2" set batch_format=cso1
if "%batch_format_choice%"=="3" set batch_format=zso

if "!batch_format!"=="" (
    echo Invalid choice.
    pause
    goto menu
)

if "!batch_format!"=="chd" (
    if not exist "%LOCALAPPDATA%\iso-compressor\chdman.exe" (
        echo Error: chdman.exe engine is not installed.
        pause
        goto menu
    )
)

echo.
echo =======================================================
echo               COMPRESSION IN PROGRESS
echo =======================================================
echo.

set valid_count=0
set ext_found=

for %%F in ("!folderpath!\*.iso" "!folderpath!\*.cso" "!folderpath!\*.cue") do (
    set "ext=%%~xF"
    if "!ext_found!"=="" (
        set "ext_found=!ext!"
    ) else if /i not "!ext_found!"=="!ext!" (
        echo Error: The folder must contain only ONE file format to convert ^(e.g., only .iso OR only .cso^).
        echo Mixed formats were found. Please separate them.
        pause
        goto menu
    )
    set /a valid_count+=1
)

if !valid_count!==0 (
    echo Error: No valid game files ^(.iso, .cso, .cue^) were found in this folder.
    pause
    goto menu
)

for %%F in ("!folderpath!\*.iso" "!folderpath!\*.cso" "!folderpath!\*.cue") do (
    echo Processing: %%~nxF
    if "!batch_format!"=="chd" (
        set "ext=%%~xF"
        if /I "!ext!"==".cue" (
            "%LOCALAPPDATA%\iso-compressor\chdman.exe" createcd -i "%%F" -o "%%~dpnF.chd"
        ) else (
            "%LOCALAPPDATA%\iso-compressor\chdman.exe" createdvd -i "%%F" -o "%%~dpnF.chd"
        )
    ) else (
        "%ENGINE_PATH%" --format=!batch_format! "%%F"
    )
)

echo.
echo =======================================================
echo                   ALL DONE!
echo =======================================================
pause
goto menu

:manage_chdman
cls
echo =======================================================
echo          INSTALL / UNINSTALL CHDMAN
echo =======================================================
echo.
if not exist "%LOCALAPPDATA%\iso-compressor\chdman.exe" (
    echo chdman is currently NOT installed.
    set /p confirm="Do you want to download and install it now? (y/n): "
    if /i "!confirm!"=="y" (
        echo Downloading chdman.exe engine from GitHub...
        curl -sL "https://raw.githubusercontent.com/wako69420/iso-compressor/master/CLI/windows/chdman.exe" -o "%LOCALAPPDATA%\iso-compressor\chdman.exe"
        if exist "%LOCALAPPDATA%\iso-compressor\chdman.exe" (
            echo Download complete! CHD format is now fully supported.
        ) else (
            echo Failed to download chdman.exe. Please check your internet connection.
        )
    )
) else (
    echo chdman is currently INSTALLED.
    set /p confirm="Do you want to uninstall and remove it? (y/n): "
    if /i "!confirm!"=="y" (
        del "%LOCALAPPDATA%\iso-compressor\chdman.exe"
        echo chdman uninstalled successfully!
    )
)
pause
goto menu

:auto_update
cls
echo =======================================================
echo                 AUTO-UPDATING TOOL
echo =======================================================
echo Fetching latest version from GitHub...
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/wako69420/iso-compressor/master/CLI/windows/iso-compressor.bat?t=' + [guid]::NewGuid().ToString() -OutFile '%LOCALAPPDATA%\iso-compressor\iso-compressor.bat'"
    echo Update complete. Please restart the tool.
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
    echo Uninstallation complete. You can close this window.
    start /b cmd /c "timeout /t 1 /nobreak >nul & rmdir /s /q ""%LOCALAPPDATA%\iso-compressor"""
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
echo PS1, PS2 ^& PSP Game Compressor %APP_VERSION%
echo A free, open-source tool for compressing massive PS1, PS2 ^& PSP games.
echo.
echo GitHub Repository: 
echo https://github.com/wako69420/iso-compressor
echo.
echo License: BSD 3-Clause License
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
