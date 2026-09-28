property appVersion : "v1.4.3"

on open droppedItems
	handleFiles(droppedItems)
end open

on run
	checkForUpdates(true)
	showMainMenu()
end run

on handleFiles(theFiles)
	set formatOptions to {"CUE/ISO -> CHD (PS1/PS2 Emulators)", "ISO -> CSO (PSP/PS2 Emulators)", "ISO -> ZSO (Real Hardware)", "CSO -> ZSO (Real Hardware)", "Decompress (CHD/CSO/ZSO -> CUE/ISO)", "View Space Saved Stats"}
	set formatChoice to choose from list formatOptions with prompt "QUICK COMPRESSION GUIDE:
• PS1 Games (.CUE) -> ONLY use CHD!
• PS2 Games (.ISO) -> CHD (Emulators) or ZSO (Real Hardware)
• PSP Games (.ISO) -> CSO (Emulators) or ZSO (Real Hardware)

Choose Conversion Target:" default items {"CUE/ISO -> CHD (PS1/PS2 Emulators)"}
	
	if formatChoice is false then return
	set formatChoice to item 1 of formatChoice
	
	if formatChoice is "View Space Saved Stats" then
		set statsFile to POSIX path of (path to home folder) & ".iso-compressor/stats.txt"
		set totalSaved to 0
		try
			set totalSaved to (do shell script "cat " & quoted form of statsFile) as integer
		end try
		if totalSaved < 1024 then
			set displaySaved to (totalSaved as string) & " B"
		else if totalSaved < 1048576 then
			set displaySaved to ((totalSaved / 1024.0 * 100) div 1 / 100.0 as string) & " KB"
		else if totalSaved < 1073741824 then
			set displaySaved to ((totalSaved / 1048576.0 * 100) div 1 / 100.0 as string) & " MB"
		else
			set displaySaved to ((totalSaved / 1073741824.0 * 100) div 1 / 100.0 as string) & " GB"
		end if
		display alert "Lifetime Space Saved" message "You have saved a total of " & displaySaved & " across all compressions!\n\n* Note: Decompressing a game does NOT subtract from your lifetime space saved stats, as this tracks the total theoretical space you have prevented from being wasted on your drives over the app's lifetime."
		return
	end if
	
	set formatFlag to "zso"
	set isChd to false
	
	if formatChoice is "CUE/ISO -> CHD (PS1/PS2 Emulators)" then
		set isChd to true
	else if formatChoice is "ISO -> CSO (PSP/PS2 Emulators)" then
		set formatFlag to "cso1"
	end if
	
	set enginePath to POSIX path of (path to resource "maxcso")
	
	set totalOrigSize to 0
	set totalNewSize to 0
	
	repeat with anItem in theFiles
		set filePath to POSIX path of anItem
		
		if formatChoice is not "Decompress (CHD/CSO/ZSO -> CUE/ISO)" then
			try
				set origSize to (do shell script "stat -f%z " & quoted form of filePath) as integer
				set totalOrigSize to totalOrigSize + origSize
			end try
		end if
		
		if formatChoice is "Decompress (CHD/CSO/ZSO -> CUE/ISO)" then
			do shell script "export PATH=\"/opt/homebrew/bin:/usr/local/bin:$PATH\"; if ! command -v chdman >/dev/null 2>&1; then osascript -e 'display alert \"chdman not found! Please use the Install CHDMAN option in the main menu.\"'; exit 1; fi; fpath=" & quoted form of filePath & "; outpath=" & quoted form of (text 1 thru -5 of filePath) & "; ext=\"${fpath##*.}\"; ext=$(echo \"$ext\" | tr '[:upper:]' '[:lower:]'); if [ \"$ext\" = \"chd\" ]; then if chdman extractcd -i \"$fpath\" -o \"${outpath}.cue\" >/dev/null 2>&1; then : ; else rm -f \"${outpath}.cue\" \"${outpath}\"*.bin 2>/dev/null; chdman extractdvd -i \"$fpath\" -o \"${outpath}.iso\"; fi; elif [ \"$ext\" = \"cso\" ] || [ \"$ext\" = \"zso\" ]; then \"" & enginePath & "\" --decompress \"$fpath\" -o \"${outpath}.iso\"; fi"
		else if isChd is true then
			set outFilePath to (text 1 thru -5 of filePath & ".chd")
			do shell script "export PATH=\"/opt/homebrew/bin:/usr/local/bin:$PATH\"; if ! command -v chdman >/dev/null 2>&1; then osascript -e 'display alert \"chdman not found! Please use the Install CHDMAN option in the main menu.\"'; exit 1; fi; fpath=" & quoted form of filePath & "; outpath=" & quoted form of outFilePath & "; ext=\"${fpath##*.}\"; ext=$(echo \"$ext\" | tr '[:upper:]' '[:lower:]'); if [ \"$ext\" = \"cue\" ]; then chdman createcd -i \"$fpath\" -o \"$outpath\"; else chdman createdvd -i \"$fpath\" -o \"$outpath\"; fi"
			try
				set newSize to (do shell script "stat -f%z " & quoted form of outFilePath) as integer
				set totalNewSize to totalNewSize + newSize
			end try
		else
			set ext to do shell script "f=" & quoted form of filePath & "; echo \"${f##*.}\""
			if formatFlag is "cso1" then
				set outFilePath to (text 1 thru -((length of ext) + 2) of filePath & ".cso")
			else
				set outFilePath to (text 1 thru -((length of ext) + 2) of filePath & ".zso")
			end if
			
			do shell script quoted form of enginePath & " --format=" & formatFlag & " " & quoted form of filePath
			try
				set newSize to (do shell script "stat -f%z " & quoted form of outFilePath) as integer
				set totalNewSize to totalNewSize + newSize
			end try
		end if
	end repeat
	
	if formatChoice is not "Decompress (CHD/CSO/ZSO -> CUE/ISO)" then
		if totalOrigSize > totalNewSize and totalNewSize > 0 then
			set savedBytes to (totalOrigSize - totalNewSize)
			
			-- Update stats file
			do shell script "mkdir -p ~/.iso-compressor; touch ~/.iso-compressor/stats.txt; curr=$(cat ~/.iso-compressor/stats.txt 2>/dev/null); curr=${curr:-0}; total=$((curr + " & savedBytes & ")); echo $total > ~/.iso-compressor/stats.txt"
			
			-- Format bytes for display
			set displayOrig to ""
			set displayNew to ""
			set displaySaved to ""
			
			if totalOrigSize > 1073741824 then
				set displayOrig to ((totalOrigSize / 1073741824.0 * 100) div 1 / 100.0 as string) & " GB"
			else
				set displayOrig to ((totalOrigSize / 1048576.0 * 100) div 1 / 100.0 as string) & " MB"
			end if
			
			if totalNewSize > 1073741824 then
				set displayNew to ((totalNewSize / 1073741824.0 * 100) div 1 / 100.0 as string) & " GB"
			else
				set displayNew to ((totalNewSize / 1048576.0 * 100) div 1 / 100.0 as string) & " MB"
			end if
			
			if savedBytes > 1073741824 then
				set displaySaved to ((savedBytes / 1073741824.0 * 100) div 1 / 100.0 as string) & " GB"
			else
				set displaySaved to ((savedBytes / 1048576.0 * 100) div 1 / 100.0 as string) & " MB"
			end if
			
			display notification "All selected games compressed." with title "ISO Compressor"
			display dialog "Success! Original: " & displayOrig & " -> New: " & displayNew & ".\n\nYou saved " & displaySaved & "!" buttons {"OK"} default button 1
		else
			display notification "All selected games compressed." with title "ISO Compressor"
			display dialog "Compression Complete!" buttons {"OK"} default button 1
		end if
	else
		display dialog "Decompression Complete!\n\n(Note: Decompressions do not affect your lifetime space saved stats)" buttons {"OK"} default button 1
	end if
end handleFiles

on showMainMenu()
	set menuOptions to {"Convert Single File...", "Convert Folder (Batch)...", "Install / Uninstall chdman (For PS1/PS2 Emulators)", "Auto-Update App", "About / Credits", "Quit"}
	set menuChoice to choose from list menuOptions with prompt "PS1, PS2 & PSP ISO Compressor " & appVersion & "
Please select an option:" default items {"Convert Single File..."}
	
	if menuChoice is false then return
	set menuChoice to item 1 of menuChoice
	
	if menuChoice is "Convert Single File..." then
		set theFiles to choose file with prompt "Select games to compress:" with multiple selections allowed
		if theFiles is not false then
			handleFiles(theFiles)
		end if
		showMainMenu()
		
	else if menuChoice is "Convert Folder (Batch)..." then
		set theFolder to choose folder with prompt "Select a Folder (Batch Compress):"
		if theFolder is not false then
			set folderPath to POSIX path of theFolder
			set foundFilesStr to do shell script "find " & quoted form of folderPath & " -maxdepth 1 -type f \\( -iname \"*.iso\" -o -iname \"*.cso\" -o -iname \"*.cue\" \\)"
			
			if foundFilesStr is "" then
				display alert "Batch Error" message "No valid game files (.iso, .cso, .cue, .chd, .zso) were found in this folder."
			else
				set foundFilesList to paragraphs of foundFilesStr
				set foundIso to false
				set foundCso to false
				set foundCue to false
				set aliasList to {}
				
				repeat with fpath in foundFilesList
					set fpathStr to fpath as string
					if fpathStr ends with ".iso" or fpathStr ends with ".ISO" then set foundIso to true
					if fpathStr ends with ".cso" or fpathStr ends with ".CSO" then set foundCso to true
					if fpathStr ends with ".cue" or fpathStr ends with ".CUE" then set foundCue to true
					set end of aliasList to (POSIX file fpathStr) as alias
				end repeat
				
				set typesCount to 0
				if foundIso then set typesCount to typesCount + 1
				if foundCso then set typesCount to typesCount + 1
				if foundCue then set typesCount to typesCount + 1
				
				if typesCount > 1 then
					display alert "Batch Error" message "The folder must contain only ONE file format to convert (e.g., only .iso OR only .cso).\n\nMixed formats were found. Please separate them."
				else
					handleFiles(aliasList)
				end if
			end if
		end if
		showMainMenu()
		
	else if menuChoice is "Install / Uninstall chdman (For PS1/PS2 Emulators)" then
		set chdmanCheck to do shell script "export PATH=\"/opt/homebrew/bin:/usr/local/bin:$PATH\"; command -v chdman || echo 'missing'"
		if chdmanCheck is "missing" then
			display dialog "CHD is the ultimate lossless compression format for PS1 and PS2 Emulators (DuckStation & PCSX2).

To create CHD files, this app needs a free tool called 'chdman'. 

Click 'Install' to automatically download and install chdman using Homebrew (requires an internet connection)." buttons {"Cancel", "Install"} default button "Install"
			
			if button returned of result is "Install" then
				try
					do shell script "export PATH=\"/opt/homebrew/bin:/usr/local/bin:$PATH\"; if ! command -v brew >/dev/null 2>&1; then osascript -e 'display alert \"Homebrew is not installed! You must install Homebrew (brew.sh) first to use this auto-installer.\"'; exit 1; fi; brew install rom-tools"
					display dialog "chdman installed successfully! You can now convert games to CHD." buttons {"Awesome"} default button 1
				on error errMsg
					display dialog "There was an error installing chdman. Ensure you have Homebrew installed and try again.

Error: " & errMsg buttons {"OK"} default button 1
				end try
			end if
		else
			display dialog "chdman is currently INSTALLED.

Do you want to uninstall and remove it?" buttons {"Cancel", "Uninstall"} default button "Uninstall"
			
			if button returned of result is "Uninstall" then
				try
					do shell script "export PATH=\"/opt/homebrew/bin:/usr/local/bin:$PATH\"; brew uninstall rom-tools"
					display dialog "chdman uninstalled successfully!" buttons {"OK"} default button 1
				on error errMsg
					display dialog "There was an error uninstalling chdman.\nError: " & errMsg buttons {"OK"} default button 1
				end try
			end if
		end if
		showMainMenu()
		
	else if menuChoice is "Auto-Update App" then
		checkForUpdates(false)
		showMainMenu()
		
	else if menuChoice is "About / Credits" then
		display dialog "PS1, PS2 & PSP ISO Compressor " & appVersion & "

A free, open-source tool for compressing massive PS1, PS2, and PSP games.

Credits:
- maxcso engine by unknownbrackets
- CHD format & chdman by MAME Team
- ZSO support (PSP) by ARK-5 Team
- ZSO support (PS2) by OPL Team" buttons {"Back"} default button "Back"
		showMainMenu()
	end if
end showMainMenu








on checkForUpdates(silentCheck)
	try
		set latestVer to do shell script "curl -m 2 -s https://api.github.com/repos/wako69420/iso-compressor/releases/latest | grep '\"tag_name\":' | sed -E 's/.*\"([^\"]+)\".*/\\1/'"
		if latestVer is "" or latestVer contains "API rate limit" then
			if silentCheck is false then
				display dialog "Could not connect to GitHub to check for updates." buttons {"OK"} default button 1
			end if
		else if latestVer is not appVersion then
			display dialog "A new version (" & latestVer & ") is available! (Current: " & appVersion & ")
Would you like to auto-download it?" buttons {"Skip", "Update Now"} default button "Update Now"
			
			if button returned of result is "Update Now" then
				do shell script "mkdir -p ~/Downloads/ISO_Compressor_Mac_Update && cd ~/Downloads/ISO_Compressor_Mac_Update && curl -sL -O https://github.com/wako69420/iso-compressor/releases/latest/download/ISO_Compressor_Mac.zip && unzip -o ISO_Compressor_Mac.zip"
				do shell script "open ~/Downloads/ISO_Compressor_Mac_Update"
				display dialog "The new version has been downloaded and opened in your Downloads folder! Please replace your old app with this new one." buttons {"Got it"} default button 1
			end if
		else
			if silentCheck is false then
				display dialog "You are already running the latest version (" & appVersion & ")." buttons {"OK"} default button 1
			end if
		end if
	on error
		if silentCheck is false then
			display dialog "Error checking for updates. Please check your internet connection." buttons {"OK"} default button 1
		end if
	end try
end checkForUpdates


