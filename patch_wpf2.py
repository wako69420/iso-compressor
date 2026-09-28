with open("/tmp/wingui2/main.go", "r") as f:
    text = f.read()

# I need to fix the broken strings in main.go
import re
text = re.sub(r'zenity\.Error\(fmt\.Sprintf\("Failed to load UI: %v[^"]*"\), zenity\.Title\("Fatal Error"\)\)', 'zenity.Error(fmt.Sprintf("Failed to load UI: %v\\n%s", err, string(out)), zenity.Title("Fatal Error"))', text)

text = re.sub(r'zenity\.Error\(fmt\.Sprintf\("Failed to load Format UI: %v[^"]*"\), zenity\.Title\("Fatal Error"\)\)', 'zenity.Error(fmt.Sprintf("Failed to load Format UI: %v\\n%s", err, string(out)), zenity.Title("Fatal Error"))', text)

# Just fully replace the bad block if the above fails
with open("/tmp/wingui2/main.go", "w") as f:
    f.write(text)
