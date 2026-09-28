import re

with open("/tmp/wingui2/main.go", "r") as f:
    text = f.read()

# Add a function for updating
updater_code = """
func checkUpdate() {
    resp, err := http.Get("https://api.github.com/repos/wako69420/iso-compressor/releases/latest")
    if err != nil {
        zenity.Error("Failed to check for updates. Are you connected to the internet?", zenity.Title("Update Failed"))
        return
    }
    defer resp.Body.Close()
    
    body, _ := io.ReadAll(resp.Body)
    bodyStr := string(body)
    
    // Quick regex or string split to find tag_name
    idx := strings.Index(bodyStr, `"tag_name":`)
    if idx == -1 {
        return
    }
    tagStart := idx + 12
    tagEnd := strings.Index(bodyStr[tagStart:], `"`)
    latestVer := bodyStr[tagStart : tagStart+tagEnd]
    
    currentVer := "v1.4.3"
    
    if latestVer != "" && latestVer != currentVer {
        ans, _ := zenity.Question(fmt.Sprintf("A new version (%s) is available! (Current: %s)\n\nWould you like to auto-download and install it now?", latestVer, currentVer), zenity.Title("Update Available"))
        if ans == nil {
            zenity.Info("Downloading update... Please wait.", zenity.Title("Updating"))
            
            exePath, _ := os.Executable()
            tempPath := filepath.Join(os.TempDir(), "ISO_Compressor_Update.exe")
            
            err := downloadFile("https://github.com/wako69420/iso-compressor/releases/latest/download/ISO_Compressor_Windows.exe", tempPath)
            if err != nil {
                zenity.Error("Failed to download the update.", zenity.Title("Update Failed"))
                return
            }
            
            // Spawn a script to replace the exe and relaunch
            script := fmt.Sprintf(`
Start-Sleep -Seconds 2
Move-Item -Force "%s" "%s"
Start-Process "%s"
`, tempPath, exePath, exePath)
            
            cmd := exec.Command("powershell", "-WindowStyle", "Hidden", "-Command", script)
            cmd.Start()
            
            os.Exit(0)
        }
    } else {
        zenity.Info(fmt.Sprintf("You are already running the latest version (%s).", currentVer), zenity.Title("Up to Date"))
    }
}
"""

text = text.replace('func processFiles(', updater_code + '\nfunc processFiles(')

text = text.replace(
    'case "UPDATE":\n\t\t\tzenity.Info("Please download the latest Windows GUI from the GitHub Releases page.", zenity.Title("Auto-Update"))',
    'case "UPDATE":\n\t\t\tcheckUpdate()'
)

with open("/tmp/wingui2/main.go", "w") as f:
    f.write(text)
