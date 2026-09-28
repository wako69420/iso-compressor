@echo off
title PS1, PS2 ^& PSP Game Compressor (CHD, ZSO ^& CSO)
color 0B
setlocal EnableDelayedExpansion

set ENGINE_PATH=%LOCALAPPDATA%\iso-compressor\maxcso.exe
set APP_VERSION=v1.4.3


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
echo  [6] Decompress (CHD/CSO/ZSO -^> CUE/ISO)
echo  [7] Install / Uninstall CHDMAN (For PS1/PS2 Emulators)
echo  [8] Space Saved Stats
echo  [9] Auto-Update CLI Tool
echo  [10] About / License
echo  [11] Uninstall CLI Tool
echo  [12] Exit
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
    goto decompress
) else if "%choice%"=="7" (
    goto manage_chdman
) else if "%choice%"=="8" (
    goto stats
) else if "%choice%"=="9" (
    goto auto_update
) else if "%choice%"=="10" (
    goto about
) else if "%choice%"=="11" (
    goto uninstall
) else if "%choice%"=="12" (
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
        for %%S in (%filepath%) do echo %%~zS >> "%TEMP%\iso_orig.txt"
        "%LOCALAPPDATA%\iso-compressor\chdman.exe" createcd -i %filepath% -o "!outfile!"
        for %%S in ("!outfile!") do echo %%~zS >> "%TEMP%\iso_new.txt"
    ) else (
        for %%S in (%filepath%) do echo %%~zS >> "%TEMP%\iso_orig.txt"
        "%LOCALAPPDATA%\iso-compressor\chdman.exe" createdvd -i %filepath% -o "!outfile!"
        for %%S in ("!outfile!") do echo %%~zS >> "%TEMP%\iso_new.txt"
    )
) else (
    for %%S in (%filepath%) do echo %%~zS >> "%TEMP%\iso_orig.txt"
        "%ENGINE_PATH%" --format=%format% %filepath%
        for %%S in ("!outfile!") do echo %%~zS >> "%TEMP%\iso_new.txt"
)

echo.
echo =======================================================
echo                   ALL DONE!
echo =======================================================
pause
goto menu

:decompress
cls
echo =======================================================
echo               DECOMPRESS (CHD/CSO/ZSO -^> ISO/CUE)
echo =======================================================
echo.
set /p filepath="Drag and drop a .CHD, .CSO, or .ZSO file here and press Enter: "
if "%filepath%"=="" goto menu
set "filepath=%filepath:"=%"

if not exist "%filepath%" (
    echo File does not exist.
    pause
    goto menu
)

set "ext=%filepath:~-4%"
if /I not "%ext%"==".chd" if /I not "%ext%"==".cso" if /I not "%ext%"==".zso" (
    echo Error: Only .chd, .cso, and .zso files are supported for decompression.
    pause
    goto menu
)

if /I "%ext%"==".cso" goto decompress_maxcso
if /I "%ext%"==".zso" goto decompress_maxcso
if /I "%ext%"==".chd" goto decompress_chd

:decompress_maxcso
if not exist "%ENGINE_PATH%" (
    echo Downloading maxcso.exe for the first time. Please wait...
    powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/wako69420/iso-compressor/master/CLI/windows/maxcso.exe' -OutFile '%ENGINE_PATH%'"
)
echo.
echo Decompressing...
"%ENGINE_PATH%" --decompress "%filepath%"
echo.
echo Decompression complete!
pause
goto menu

:decompress_chd
if not exist "%LOCALAPPDATA%\iso-compressor\chdman.exe" (
    echo Downloading chdman.exe for the first time. Please wait...
    powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/wako69420/iso-compressor/master/CLI/windows/chdman.exe' -OutFile '%LOCALAPPDATA%\iso-compressor\chdman.exe'"
)
echo.
echo Decompressing CHD...
powershell -NoProfile -Command "$f='%filepath%'; $o=$f.Substring(0, $f.Length-4)+'.cue'; $p = Start-Process -FilePath '%LOCALAPPDATA%\iso-compressor\chdman.exe' -ArgumentList 'extractcd', '-i', \"`$f\", '-o', \"`$o\" -Wait -NoNewWindow -PassThru; if ($p.ExitCode -ne 0) { Write-Host 'Not a CD (CUE). Attempting DVD (ISO) extraction...'; if (Test-Path `$o) { Remove-Item `$o }; $o2=$f.Substring(0, $f.Length-4)+'.iso'; Start-Process -FilePath '%LOCALAPPDATA%\iso-compressor\chdman.exe' -ArgumentList 'extractdvd', '-i', \"`$f\", '-o', \"`$o2\" -Wait -NoNewWindow }"
echo.
echo Decompression complete!
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
            echo %%~zF >> "%TEMP%\iso_orig.txt"
            "%LOCALAPPDATA%\iso-compressor\chdman.exe" createcd -i "%%F" -o "%%~dpnF.chd"
            for %%S in ("%%~dpnF.chd") do echo %%~zS >> "%TEMP%\iso_new.txt"
        ) else (
            echo %%~zF >> "%TEMP%\iso_orig.txt"
            "%LOCALAPPDATA%\iso-compressor\chdman.exe" createdvd -i "%%F" -o "%%~dpnF.chd"
            for %%S in ("%%~dpnF.chd") do echo %%~zS >> "%TEMP%\iso_new.txt"
        )
    ) else (
        echo %%~zF >> "%TEMP%\iso_orig.txt"
            "%ENGINE_PATH%" --format=!batch_format! "%%F"
            for %%S in ("%%~dpnF.!batch_format!") do echo %%~zS >> "%TEMP%\iso_new.txt"
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

:stats
cls
echo.
echo ==================================================
echo               LIFETIME SPACE SAVED
echo ==================================================
echo.
powershell -NoProfile -Command "$f='%LOCALAPPDATA%\iso-compressor\stats.txt'; [long]$t=0; if (Test-Path $f) { $t=[long](Get-Content $f) }; $mb=$t/1MB; $gb=$t/1GB; if ($gb -ge 1) { Write-Host ('You have saved a total of {0:N2} GB across all compressions!' -f $gb) -ForegroundColor Green } else { Write-Host ('You have saved a total of {0:N2} MB across all compressions!' -f $mb) -ForegroundColor Green }"
echo.
echo * Note: Decompressing a game does NOT subtract from your 
echo lifetime space saved stats, as this tracks the total 
echo theoretical space you have prevented from being wasted 
echo on your drives over the app's lifetime.
echo.
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
