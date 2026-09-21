property appVersion : "v1.4.2"

on open droppedItems
	handleFiles(droppedItems)
end open

on run
	checkForUpdates(true)
	showMainMenu()
end run

on handleFiles(theFiles)
	set formatOptions to {"CUE/ISO -> CHD (PS1/PS2 Emulators)", "ISO -> CSO (PSP/PS2 Emulators)", "ISO -> ZSO (Real Hardware)", "CSO -> ZSO (Real Hardware)"}
	set formatChoice to choose from list formatOptions with prompt "QUICK COMPRESSION GUIDE:
• PS1 Games (.CUE) -> ONLY use CHD!
• PS2 Games (.ISO) -> CHD (Emulators) or ZSO (Real Hardware)
• PSP Games (.ISO) -> CSO (Emulators) or ZSO (Real Hardware)

Choose Conversion Target:" default items {"CUE/ISO -> CHD (PS1/PS2 Emulators)"}
	
	if formatChoice is false then return
	set formatChoice to item 1 of formatChoice
	
	set formatFlag to "zso"
	set isChd to false
	
	if formatChoice is "CUE/ISO -> CHD (PS1/PS2 Emulators)" then
		set isChd to true
	else if formatChoice is "ISO -> CSO (PSP/PS2 Emulators)" then
		set formatFlag to "cso1"
	end if
	
	set enginePath to POSIX path of (path to resource "maxcso")
	
	repeat with anItem in theFiles
		set filePath to POSIX path of anItem
		if isChd is true then
			do shell script "export PATH=\"/opt/homebrew/bin:/usr/local/bin:$PATH\"; if ! command -v chdman >/dev/null 2>&1; then osascript -e 'display alert \"chdman not found! Please use the Install CHDMAN option in the main menu.\"'; exit 1; fi; fpath=" & quoted form of filePath & "; outpath=" & quoted form of (text 1 thru -5 of filePath & ".chd") & "; ext=\"${fpath##*.}\"; ext=$(echo \"$ext\" | tr '[:upper:]' '[:lower:]'); if [ \"$ext\" = \"cue\" ]; then chdman createcd -i \"$fpath\" -o \"$outpath\"; else chdman createdvd -i \"$fpath\" -o \"$outpath\"; fi"
		else
			do shell script quoted form of enginePath & " --format=" & formatFlag & " " & quoted form of filePath
		end if
	end repeat
	display notification "All selected games compressed." with title "ISO Compressor"
	display dialog "Compression Complete!" buttons {"OK"} default button 1
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
			set foundFilesStr to do shell script "find " & quoted form of folderPath & " -maxdepth 1 -type f \\( -iname \\"*.iso\\" -o -iname \\"*.cso\\" -o -iname \\"*.cue\\" \\)"
			
			if foundFilesStr is "" then
				display alert "Batch Error" message "No valid game files (.iso, .cso, .cue) were found in this folder."
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


