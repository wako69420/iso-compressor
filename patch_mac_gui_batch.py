with open("mac_script.applescript", "r") as f:
    text = f.read()

text = text.replace(
    'set foundFilesStr to do shell script "find " & quoted form of folderPath & " -maxdepth 1 -type f \\\\( -iname \\\\\"*.iso\\\\\" -o -iname \\\\\"*.cso\\\\\" -o -iname \\\\\"*.cue\\\\\" \\\\)"',
    'set foundFilesStr to do shell script "find " & quoted form of folderPath & " -maxdepth 1 -type f \\\\( -iname \\\\\"*.iso\\\\\" -o -iname \\\\\"*.cso\\\\\" -o -iname \\\\\"*.cue\\\\\" -o -iname \\\\\"*.chd\\\\\" -o -iname \\\\\"*.zso\\\\\" \\\\)"'
)
text = text.replace(
    'display alert "Batch Error" message "No valid game files (.iso, .cso, .cue) were found in this folder."',
    'display alert "Batch Error" message "No valid game files (.iso, .cso, .cue, .chd, .zso) were found in this folder."'
)

with open("mac_script.applescript", "w") as f:
    f.write(text)
