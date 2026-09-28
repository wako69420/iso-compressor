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
	"github.com/ncruces/zenity"
)

func main() {
	if len(os.Args) > 1 {
		processFiles(os.Args[1:], false)
	} else {
		showMainMenu()
	}
}

func getAppDataDir() string {
	appData, _ := os.UserConfigDir()
	dir := filepath.Join(appData, "iso-compressor")
	os.MkdirAll(dir, os.ModePerm)
	return dir
}

func showMainMenu() {
	for {
		script := `
Add-Type -AssemblyName PresentationFramework
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="ISO Compressor" Width="400" Height="430" WindowStartupLocation="CenterScreen" Background="#F3F3F3" ResizeMode="NoResize">
    <StackPanel Margin="20">
        <TextBlock Text="ISO Compressor" FontSize="24" FontWeight="Bold" Foreground="#333" HorizontalAlignment="Center"/>
        <TextBlock Text="PS1, PS2 &amp; PSP Game Compressor" FontSize="14" Foreground="#666" HorizontalAlignment="Center" Margin="0,0,0,20"/>
        
        <Button Name="btnCompress" Content="Compress Single File" Height="40" Margin="0,0,0,8" Background="#0078D7" Foreground="White" FontSize="14" FontWeight="SemiBold" BorderThickness="0" Cursor="Hand">
            <Button.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="4"/></Style></Button.Resources>
        </Button>
        <Button Name="btnBatch" Content="Compress Folder (Batch)" Height="40" Margin="0,0,0,8" Background="#0078D7" Foreground="White" FontSize="14" FontWeight="SemiBold" BorderThickness="0" Cursor="Hand">
            <Button.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="4"/></Style></Button.Resources>
        </Button>
        <Button Name="btnDecompress" Content="Decompress File / Folder" Height="40" Margin="0,0,0,8" Background="#28A745" Foreground="White" FontSize="14" FontWeight="SemiBold" BorderThickness="0" Cursor="Hand">
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
$window.FindName("btnCompress").add_Click({ Write-Host "COMPRESS_FILE"; $window.Close() })
$window.FindName("btnBatch").add_Click({ Write-Host "COMPRESS_FOLDER"; $window.Close() })
$window.FindName("btnDecompress").add_Click({ Write-Host "DECOMPRESS"; $window.Close() })
$window.FindName("btnChdman").add_Click({ Write-Host "CHDMAN"; $window.Close() })
$window.FindName("btnUpdate").add_Click({ Write-Host "UPDATE"; $window.Close() })
$window.FindName("btnAbout").add_Click({ Write-Host "ABOUT"; $window.Close() })
$window.ShowDialog() | Out-Null
`
		cmd := exec.Command("powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-WindowStyle", "Hidden", "-Command", "-")
		cmd.Stdin = strings.NewReader(script)
		cmd.SysProcAttr = &syscall.SysProcAttr{CreationFlags: 0x08000000} // CREATE_NO_WINDOW
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
					if e.IsDir() {
						continue
					}
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
		case "DECOMPRESS":
			fileOrFolder, err := zenity.SelectFile(zenity.Title("Select File or Folder to Decompress")) // Wait, zenity.SelectFile only selects files unless Directory() is passed. Let's ask them.
			// Actually, let's just use zenity.SelectFile for files for simplicity, or we can do a prompt. Let's assume file for now, but we want folder support.
			// To support both, we can't easily with standard open dialog. We'll ask if they want file or folder.
			ans, _ := zenity.List("What do you want to decompress?", []string{"A Single File", "An Entire Folder (Batch)"}, zenity.Title("Decompress"))
			if ans == "A Single File" {
				file, err := zenity.SelectFile(zenity.Title("Select File to Decompress"))
				if err == nil && file != "" {
					processFiles([]string{file}, true)
				}
			} else if ans == "An Entire Folder (Batch)" {
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
			}
		case "CHDMAN":
			// chdman logic
			zenity.Info("CHDMAN logic handled here (simplified for this rebuild).", zenity.Title("Info"))
		case "UPDATE":
			zenity.Info("Updater logic triggered.", zenity.Title("Info"))
		case "ABOUT":
			zenity.Info("ISO Compressor\nVersion: v1.4.3\nLicense: BSD 3-Clause", zenity.Title("About"))
		}
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
$window.FindName("btnCHD").add_Click({ Write-Host "chd"; $window.Close() })
$window.FindName("btnCSO").add_Click({ Write-Host "cso1"; $window.Close() })
$window.FindName("btnZSO").add_Click({ Write-Host "zso"; $window.Close() })
$window.ShowDialog() | Out-Null
`
		cmd := exec.Command("powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-WindowStyle", "Hidden", "-Command", "-")
		cmd.Stdin = strings.NewReader(script)
		cmd.SysProcAttr = &syscall.SysProcAttr{CreationFlags: 0x08000000}
		out, _ := cmd.CombinedOutput()
		format := strings.TrimSpace(string(out))
		if format == "" { return }
		
		// In original, it spawns terminal directly.
		zenity.Info(fmt.Sprintf("Ready to compress to %s! (Terminal spawn goes here)", format), zenity.Title("Compress"))
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
		scriptBlocks = append(scriptBlocks, `Write-Host "Done!"; Start-Sleep -Seconds 3`)
		
		fullScript := strings.Join(scriptBlocks, "\n")
		// Launch in visible powershell
		cmd := exec.Command("powershell", "-NoExit", "-Command", fullScript)
		cmd.Run()
	}
}
