import re

with open("CLI/windows/iso-compressor.bat", "r") as f:
    text = f.read()

# Add to the menu
text = text.replace('echo  [7] Install / Uninstall CHDMAN', 'echo  [7] Install / Uninstall CHDMAN\\necho  [8] Space Saved Stats')
text = text.replace('echo  [8] Auto-Update', 'echo  [9] Auto-Update')
text = text.replace('echo  [9] About', 'echo  [10] About')
text = text.replace('echo  [10] Uninstall', 'echo  [11] Uninstall')
text = text.replace('echo  [11] Exit', 'echo  [12] Exit')

# Shift IF choice logic at the bottom again
def inc_choice(m):
    return m.group(1) + str(int(m.group(2)) + 1) + m.group(3)

text = re.sub(r'^(if "%choice%"==")([8-9]|10|11)(" goto )', inc_choice, text, flags=re.MULTILINE)

new_case_8 = """if "%choice%"=="8" goto stats
"""
text = text.replace('if "%choice%"=="9" goto update', new_case_8 + 'if "%choice%"=="9" goto update')

new_stats_block = """
:stats
cls
echo.
echo ==================================================
echo               LIFETIME SPACE SAVED
echo ==================================================
echo.
powershell -NoProfile -Command "$f='%LOCALAPPDATA%\\iso-compressor\\stats.txt'; [long]$t=0; if (Test-Path $f) { $t=[long](Get-Content $f) }; $mb=$t/1MB; $gb=$t/1GB; if ($gb -ge 1) { Write-Host ('You have saved a total of {0:N2} GB across all compressions!' -f $gb) -ForegroundColor Green } else { Write-Host ('You have saved a total of {0:N2} MB across all compressions!' -f $mb) -ForegroundColor Green }"
echo.
echo * Note: Decompressing a game does NOT subtract from your 
echo lifetime space saved stats, as this tracks the total 
echo theoretical space you have prevented from being wasted 
echo on your drives over the app's lifetime.
echo.
pause
goto menu

"""
text = text.replace(':update', new_stats_block + ':update')


# Now, inject the size tracking into the compression loops!
# We can inject a powershell command at the end of every format block.
# Wait, it's easier to just track total size before, and total size after at the batch level!
# In the single file compression:
# `set "orig_file=%filepath%"`
# Before compression: `powershell -NoProfile -Command "$orig=(Get-Item '!orig_file!').Length; Set-Content '%TEMP%\\orig_size.txt' $orig"`
# After compression: read the new file size, compute, add.

# Actually, the batch has a loop. It's much faster to just use a wrapper powershell script at the end of the script!
# Wait, I can just replace the success message!
old_success = "echo Compression complete!"
new_success = """powershell -NoProfile -Command "$orig=0; $new=0; foreach ($f in Get-ChildItem '%TEMP%\\iso_orig_*.txt') { $orig += [long](Get-Content $f.FullName); Remove-Item $f.FullName }; foreach ($f in Get-ChildItem '%TEMP%\\iso_new_*.txt') { $new += [long](Get-Content $f.FullName); Remove-Item $f.FullName }; if ($orig -gt $new -and $new -gt 0) { $saved = $orig - $new; $sf='%LOCALAPPDATA%\\iso-compressor\\stats.txt'; [long]$t=0; if (Test-Path $sf) { $t=[long](Get-Content $sf) }; $t += $saved; Set-Content $sf $t; $gbO=$orig/1GB; $gbN=$new/1GB; $gbS=$saved/1GB; if ($orig -ge 1GB) { Write-Host ('Success! Original: {0:N2} GB -^> New: {1:N2} GB. You saved {2:N2} GB!' -f $gbO, $gbN, $gbS) -ForegroundColor Green } else { Write-Host ('Success! You saved {0:N2} MB!' -f ($saved/1MB)) -ForegroundColor Green } } else { Write-Host 'Compression complete!' -ForegroundColor Green }"
"""
# And I just need to record the sizes during the loops.
# Let's inject size recording for `chd`, `cso`, `zso` output in single/batch
# Before engine execution: powershell -NoProfile -Command "(Get-Item '%%F').Length | Out-File -Append '%TEMP%\iso_orig_tmp.txt'"
# Wait, inside a cmd FOR loop, running powershell is incredibly slow (spawns a new PS process per file!).
# What if we use a VBScript or just native CMD file sizes? `%%~zF` gives the file size natively without spawning a process!
# Since it's limited to 32-bit (2GB) for math, we can just WRITE the raw string sizes into a text file, and let PowerShell do the math ONCE at the end!
# Yes! `echo %%~zF >> "%TEMP%\iso_orig.txt"`! File size strings can be written natively!

# Let's write the injections.
