package main

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"syscall"
	"runtime"

	"github.com/ncruces/zenity"
)

func init() {
	runtime.LockOSThread()
}

func getAppDataDir() string {
	appData, _ := os.UserConfigDir()
	dir := filepath.Join(appData, "iso-compressor")
	os.MkdirAll(dir, os.ModePerm)
	return dir
}

func getStats() (int64, string) {
    statsFile := filepath.Join(getAppDataDir(), "stats.txt")
    b, err := os.ReadFile(statsFile)
    if err != nil {
        return 0, "0.00 MB"
    }
    var bytes int64
    fmt.Sscanf(strings.TrimSpace(string(b)), "%d", &bytes)
    return bytes, formatBytes(bytes)
}

func updateStats(saved int64) {
    statsFile := filepath.Join(getAppDataDir(), "stats.txt")
    current, _ := getStats()
    total := current + saved
    os.WriteFile(statsFile, []byte(fmt.Sprintf("%d", total)), 0666)
}

func formatBytes(b int64) string {
    const unit = 1024
    if b < unit {
        return fmt.Sprintf("%d B", b)
    }
    div, exp := int64(unit), 0
    for n := b / unit; n >= unit; n /= unit {
        div *= unit
        exp++
    }
    return fmt.Sprintf("%.2f %cB", float64(b)/float64(div), "KMGTPE"[exp])
}

func main() {
	defer func() {
		if r := recover(); r != nil {
			os.WriteFile(filepath.Join(os.TempDir(), "iso-crash.txt"), []byte(fmt.Sprintf("%v", r)), 0666)
			zenity.Error(fmt.Sprintf("Crash: %v", r), zenity.Title("Fatal Error"))
		}
	}()
	if len(os.Args) > 1 {
		processFiles(os.Args[1:], false)
	} else {
		showMainMenu()
	}
}

func showMainMenu() {
	for {
        _, statsStr := getStats()
		script := `
Add-Type -AssemblyName PresentationFramework
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="ISO Compressor" Width="420" Height="518" WindowStartupLocation="CenterScreen" Background="#F3F3F3" ResizeMode="NoResize">
    <StackPanel Margin="20">
        <TextBlock Text="ISO Compressor" FontSize="24" FontWeight="Bold" Foreground="#333" HorizontalAlignment="Center"/>
        <TextBlock Text="PS1, PS2 &amp; PSP Game Compressor" FontSize="14" Foreground="#666" HorizontalAlignment="Center" Margin="0,0,0,20"/>
        
        <Button Name="btnCompress" Content="Compress Single File" Height="40" Margin="0,0,0,8" Background="#0078D7" Foreground="White" FontSize="14" FontWeight="SemiBold" BorderThickness="0" Cursor="Hand">
            <Button.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="4"/></Style></Button.Resources>
        </Button>
        <Button Name="btnBatch" Content="Compress Folder (Batch)" Height="40" Margin="0,0,0,8" Background="#0078D7" Foreground="White" FontSize="14" FontWeight="SemiBold" BorderThickness="0" Cursor="Hand">
            <Button.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="4"/></Style></Button.Resources>
        </Button>
        <Button Name="btnDecompressFile" Content="Decompress Single File" Height="40" Margin="0,0,0,8" Background="#28A745" Foreground="White" FontSize="14" FontWeight="SemiBold" BorderThickness="0" Cursor="Hand">
            <Button.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="4"/></Style></Button.Resources>
        </Button>
        <Button Name="btnDecompressBatch" Content="Decompress Folder (Batch)" Height="40" Margin="0,0,0,8" Background="#28A745" Foreground="White" FontSize="14" FontWeight="SemiBold" BorderThickness="0" Cursor="Hand">
            <Button.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="4"/></Style></Button.Resources>
        </Button>
        <Button Name="btnStats" Content="Lifetime Space Saved: ` + statsStr + `" Height="40" Margin="0,0,0,8" Background="#6F42C1" Foreground="White" FontSize="14" FontWeight="SemiBold" BorderThickness="0" Cursor="Hand">
            <Button.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="4"/></Style></Button.Resources>
        </Button>
        <Button Name="btnChdman" Content="Install / Uninstall CHDMAN" Height="35" Margin="0,0,0,8" Background="White" Foreground="#333" FontSize="14" BorderBrush="#CCC" Cursor="Hand"/>
        <Button Name="btnUpdate" Content="Auto-Update App" Height="35" Margin="0,0,0,8" Background="White" Foreground="#333" FontSize="14" BorderBrush="#CCC" Cursor="Hand"/>
        <Button Name="btnAbout" Content="About / License" Height="35" Margin="0,0,0,8" Background="White" Foreground="#333" FontSize="14" BorderBrush="#CCC" Cursor="Hand"/>
    </StackPanel>
</Window>
"@
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)
$window.FindName("btnCompress").add_Click({ $global:selection = "COMPRESS_FILE"; $window.Close() })
$window.FindName("btnBatch").add_Click({ $global:selection = "COMPRESS_FOLDER"; $window.Close() })
$window.FindName("btnDecompressFile").add_Click({ $global:selection = "DECOMPRESS_FILE"; $window.Close() })
$window.FindName("btnDecompressBatch").add_Click({ $global:selection = "DECOMPRESS_BATCH"; $window.Close() })
$window.FindName("btnStats").add_Click({ $global:selection = "STATS"; $window.Close() })
$window.FindName("btnChdman").add_Click({ $global:selection = "CHDMAN"; $window.Close() })
$window.FindName("btnUpdate").add_Click({ $global:selection = "UPDATE"; $window.Close() })
$window.FindName("btnAbout").add_Click({ $global:selection = "ABOUT"; $window.Close() })
$window.ShowDialog() | Out-Null
Write-Output $global:selection
`
		tmpScript := filepath.Join(os.TempDir(), "iso-ui.ps1")
		os.WriteFile(tmpScript, []byte(script), 0666)
		cmd := exec.Command("powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-WindowStyle", "Hidden", "-File", tmpScript)
		cmd.SysProcAttr = &syscall.SysProcAttr{CreationFlags: 0x08000000}
		out, err := cmd.CombinedOutput()
		if err != nil {
			zenity.Error(fmt.Sprintf("Failed to load UI: %v\n%s", err, string(out)), zenity.Title("Fatal Error"))
			return
		}
		
		selection := strings.TrimSpace(string(out))
		if selection == "" {
			return
		}

		switch selection {
		case "COMPRESS_FILE":
			file, err := zenity.SelectFile(zenity.Title("Select a Game File to Compress"))
			if err == nil && file != "" {
				processFiles([]string{file}, false)
			}
		case "COMPRESS_FOLDER":
			folder, err := zenity.SelectFile(zenity.Title("Select a Folder (Batch Compress)"), zenity.Directory())
			if err == nil && folder != "" {
				var validFiles []string
				entries, _ := os.ReadDir(folder)
				for _, e := range entries {
					if e.IsDir() { continue }
					ext := strings.ToLower(filepath.Ext(e.Name()))
					if ext == ".iso" || ext == ".cso" || ext == ".cue" {
						validFiles = append(validFiles, filepath.Join(folder, e.Name()))
					}
				}
				if len(validFiles) > 0 {
					processFiles(validFiles, false)
				} else {
					zenity.Error("No valid game files (.iso, .cso, .cue) found in this folder.", zenity.Title("Batch Error"))
				}
			}
		case "DECOMPRESS_FILE":
			file, err := zenity.SelectFile(zenity.Title("Select File to Decompress"))
			if err == nil && file != "" {
				processFiles([]string{file}, true)
			}
		case "DECOMPRESS_BATCH":
			folder, err := zenity.SelectFile(zenity.Title("Select Folder to Decompress"), zenity.Directory())
			if err == nil && folder != "" {
				var validFiles []string
				entries, _ := os.ReadDir(folder)
				for _, e := range entries {
					if !e.IsDir() {
						ext := strings.ToLower(filepath.Ext(e.Name()))
						if ext == ".cso" || ext == ".zso" || ext == ".chd" {
							validFiles = append(validFiles, filepath.Join(folder, e.Name()))
						}
					}
				}
				if len(validFiles) > 0 {
					processFiles(validFiles, true)
				} else {
					zenity.Error("No valid compressed files (.chd, .cso, .zso) found in this folder.", zenity.Title("Batch Error"))
				}
			}
		case "STATS":
            _, statsStr := getStats()
            msg := fmt.Sprintf("Lifetime Space Saved: %s\n\n* Note: Decompressing a game does NOT subtract from your lifetime space saved stats, as this tracks the total theoretical space you have prevented from being wasted on your drives over the app's lifetime.", statsStr)
            zenity.Info(msg, zenity.Title("Space Saved Stats"))
		case "CHDMAN":
            chdmanPath := filepath.Join(getAppDataDir(), "chdman.exe")
            if _, err := os.Stat(chdmanPath); os.IsNotExist(err) {
                err := zenity.Question("CHDMAN is currently NOT installed.\n\nDo you want to download and install it now?", zenity.Title("Install CHDMAN"))
                if err == nil {
                    zenity.Info("Downloading chdman.exe...", zenity.Title("Downloading Engine"))
                    err := downloadFile("https://raw.githubusercontent.com/wako69420/iso-compressor/master/CLI/windows/chdman.exe", chdmanPath)
                    if err != nil {
                        zenity.Error(fmt.Sprintf("Failed to download chdman.exe: %v", err), zenity.Title("Download Failed"))
                    } else {
                        zenity.Info("CHDMAN installed successfully!", zenity.Title("Success"))
                    }
                }
            } else {
                err := zenity.Question("CHDMAN is currently INSTALLED.\n\nDo you want to uninstall and remove it?", zenity.Title("Uninstall CHDMAN"))
                if err == nil {
                    os.Remove(chdmanPath)
                    zenity.Info("CHDMAN uninstalled successfully.", zenity.Title("Success"))
                }
            }
		case "UPDATE":
			checkUpdate()
		case "ABOUT":
			zenity.Info("ISO Compressor\nVersion: v1.4.3\nLicense: BSD 3-Clause\n\nCredits:\n- maxcso by unknownbrackets\n- chdman by MAME Team\n- ZSO by ARK-5 & OPL Teams", zenity.Title("About"))
		}
	}
}


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
        errUpdate := zenity.Question(fmt.Sprintf("A new version (%s) is available! (Current: %s)\n\nWould you like to auto-download and install it now?", latestVer, currentVer), zenity.Title("Update Available"))
        if errUpdate == nil {
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

func processFiles(files []string, isDecompress bool) {
	appData := getAppDataDir()
	maxcsoPath := filepath.Join(appData, "maxcso.exe")
	chdmanPath := filepath.Join(appData, "chdman.exe")
	
	if !isDecompress {
		script := `
Add-Type -AssemblyName PresentationFramework
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Select Format" Width="400" Height="300" WindowStartupLocation="CenterScreen" Background="#F3F3F3" ResizeMode="NoResize">
    <StackPanel Margin="20">
        <TextBlock Text="Compression Format" FontSize="20" FontWeight="Bold" Foreground="#333" HorizontalAlignment="Center"/>
        <TextBlock Text="Choose a format for your game:" FontSize="13" Foreground="#666" HorizontalAlignment="Center" Margin="0,0,0,20"/>
        
        <Button Name="btnCHD" Content="CHD (PS1 / PS2 Emulators)" Height="40" Margin="0,0,0,8" Background="White" Foreground="#333" FontSize="14" Cursor="Hand"/>
        <Button Name="btnCSO" Content="CSO (PSP Emulators)" Height="40" Margin="0,0,0,8" Background="White" Foreground="#333" FontSize="14" Cursor="Hand"/>
        <Button Name="btnZSO" Content="ZSO (Real Console)" Height="40" Margin="0,0,0,8" Background="White" Foreground="#333" FontSize="14" Cursor="Hand"/>
    </StackPanel>
</Window>
"@
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)
$window.FindName("btnCHD").add_Click({ $global:selection = "chd"; $window.Close() })
$window.FindName("btnCSO").add_Click({ $global:selection = "cso1"; $window.Close() })
$window.FindName("btnZSO").add_Click({ $global:selection = "zso"; $window.Close() })
$window.ShowDialog() | Out-Null
Write-Output $global:selection
`
		tmpScript := filepath.Join(os.TempDir(), "iso-format.ps1")
		os.WriteFile(tmpScript, []byte(script), 0666)
		cmd := exec.Command("powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-WindowStyle", "Hidden", "-File", tmpScript)
		cmd.SysProcAttr = &syscall.SysProcAttr{CreationFlags: 0x08000000}
		out, _ := cmd.CombinedOutput()
		format := strings.TrimSpace(string(out))
		if format == "" { return }
		
        if format == "cso1" || format == "zso" {
            if _, err := os.Stat(maxcsoPath); os.IsNotExist(err) {
                zenity.Info("Downloading maxcso.exe for the first time. Please wait...", zenity.Title("Downloading Engine"))
                downloadFile("https://raw.githubusercontent.com/wako69420/iso-compressor/master/CLI/windows/maxcso.exe", maxcsoPath)
            }
        }
        if format == "chd" {
            if _, err := os.Stat(chdmanPath); os.IsNotExist(err) {
                zenity.Info("Downloading chdman.exe for the first time. Please wait...", zenity.Title("Downloading Engine"))
                downloadFile("https://raw.githubusercontent.com/wako69420/iso-compressor/master/CLI/windows/chdman.exe", chdmanPath)
            }
        }

        var totalOrig int64 = 0
        var totalNew int64 = 0
        scriptBlocks := []string{`Write-Host "Starting Compression Batch..."`}

		for _, file := range files {
			ext := strings.ToLower(filepath.Ext(file))
			baseName := file[:len(file)-len(ext)]
            
            origInfo, err := os.Stat(file)
            if err == nil {
                totalOrig += origInfo.Size()
            }
			
            var outFile string
			if format == "chd" {
				outFile = baseName + ".chd"
				cmdStr := "createdvd"
				if ext == ".cue" { cmdStr = "createcd" }
                scriptBlocks = append(scriptBlocks, fmt.Sprintf(`Write-Host "Compressing '%s' to CHD..."; & "%s" "%s" "-i" "%s" "-o" "%s"`, filepath.Base(file), chdmanPath, cmdStr, file, outFile))
			} else {
                outFile = baseName + "." + format
                if format == "cso1" { outFile = baseName + ".cso" }
                scriptBlocks = append(scriptBlocks, fmt.Sprintf(`Write-Host "Compressing '%s' to %s..."; & "%s" "--format=%s" "%s"`, filepath.Base(file), strings.ToUpper(format), maxcsoPath, format, file))
			}

            // After each file in powershell, we don't have its new size yet. We'll measure sizes from Go after PS exits!
		}
		
        scriptBlocks = append(scriptBlocks, `Write-Host "Done!"; Start-Sleep -Seconds 2`)
		fullScript := strings.Join(scriptBlocks, "\n")
		
		pcmd := exec.Command("powershell", "-NoProfile", "-Command", fullScript)
		pcmd.Run()

        // Measure compressed sizes
        for _, file := range files {
            ext := strings.ToLower(filepath.Ext(file))
			baseName := file[:len(file)-len(ext)]
            var outFile string
            if format == "chd" {
                outFile = baseName + ".chd"
            } else if format == "cso1" {
                outFile = baseName + ".cso"
            } else {
                outFile = baseName + ".zso"
            }
            newInfo, err := os.Stat(outFile)
            if err == nil {
                totalNew += newInfo.Size()
            }
        }

        if totalNew > 0 && totalOrig > totalNew {
            saved := totalOrig - totalNew
            updateStats(saved)
            msg := fmt.Sprintf("Success! Original: %s -> New: %s.\n\nYou saved %s!", formatBytes(totalOrig), formatBytes(totalNew), formatBytes(saved))
            zenity.Info(msg, zenity.Title("Compression Complete"))
        } else {
            zenity.Info("Compression finished!", zenity.Title("Complete"))
        }

	} else {
		// DECOMPRESS LOGIC
		scriptBlocks := []string{`Write-Host "Starting Decompression Batch..."`}
		for _, file := range files {
			ext := strings.ToLower(filepath.Ext(file))
			baseName := file[:len(file)-len(ext)]
			
			if ext == ".cso" || ext == ".zso" {
				outFile := baseName + ".iso"
				scriptBlocks = append(scriptBlocks, fmt.Sprintf(`
Write-Host "Decompressing '%s' to ISO..."
& "%s" --decompress "%s" -o "%s"
				`, filepath.Base(file), maxcsoPath, file, outFile))
			} else if ext == ".chd" {
				outCue := baseName + ".cue"
				outIso := baseName + ".iso"
				scriptBlocks = append(scriptBlocks, fmt.Sprintf(`
Write-Host "Decompressing CHD '%s'..."
$p = Start-Process -FilePath "%s" -ArgumentList "extractcd", "-i", "%s", "-o", "%s" -Wait -NoNewWindow -PassThru
if ($p.ExitCode -ne 0) {
	Write-Host "Not a CD (CUE). Attempting DVD (ISO) extraction..."
	if (Test-Path "%s") { Remove-Item "%s" }
	$p2 = Start-Process -FilePath "%s" -ArgumentList "extractdvd", "-i", "%s", "-o", "%s" -Wait -NoNewWindow -PassThru
}
				`, filepath.Base(file), chdmanPath, file, outCue, outCue, outCue, chdmanPath, file, outIso))
			}
		}
		scriptBlocks = append(scriptBlocks, `Write-Host "Done!"; Start-Sleep -Seconds 2`)
		
		fullScript := strings.Join(scriptBlocks, "\n")
		pcmd := exec.Command("powershell", "-NoProfile", "-Command", fullScript)
		pcmd.Run()

        zenity.Info("Decompression finished successfully!\n\n(Note: Decompressions do not affect your lifetime space saved stats)", zenity.Title("Decompression Complete"))
	}
}

func downloadFile(url string, dest string) error {
	resp, err := http.Get(url)
	if err != nil { return err }
	defer resp.Body.Close()
	out, err := os.Create(dest)
	if err != nil { return err }
	defer out.Close()
	_, err = io.Copy(out, resp.Body)
	return err
}
