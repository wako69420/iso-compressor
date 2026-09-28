cat << 'EOF' > fix_chdman.go
package main

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
	"syscall"

	"github.com/ncruces/zenity"
)

func init() {
	runtime.LockOSThread()
}

func main() {
	if len(os.Args) > 1 {
		handleCompression(os.Args[1:])
	} else {
		showMainMenu()
	}
}

func showMainMenu() {
	for {
		script := `
Add-Type -AssemblyName PresentationFramework
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="ISO Compressor" Width="400" Height="340" WindowStartupLocation="CenterScreen" Background="#F3F3F3" ResizeMode="NoResize">
    <StackPanel Margin="20">
        <TextBlock Text="ISO Compressor" FontSize="24" FontWeight="Bold" Foreground="#333" HorizontalAlignment="Center"/>
        <TextBlock Text="PS1, PS2 &amp; PSP Game Compressor" FontSize="14" Foreground="#666" HorizontalAlignment="Center" Margin="0,0,0,20"/>
        
        <Button Name="btnCompress" Content="Compress Single File" Height="40" Margin="0,0,0,8" Background="#0078D7" Foreground="White" FontSize="14" FontWeight="SemiBold" BorderThickness="0" Cursor="Hand">
            <Button.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="4"/></Style></Button.Resources>
        </Button>
        <Button Name="btnBatch" Content="Compress Folder (Batch)" Height="40" Margin="0,0,0,8" Background="#0078D7" Foreground="White" FontSize="14" FontWeight="SemiBold" BorderThickness="0" Cursor="Hand">
            <Button.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="4"/></Style></Button.Resources>
        </Button>
        <Button Name="btnChdman" Content="Install / Uninstall CHDMAN" Height="35" Margin="0,0,0,8" Background="White" Foreground="#333" FontSize="14" BorderBrush="#CCC" Cursor="Hand"/>
        <Button Name="btnAbout" Content="About / License" Height="35" Margin="0,0,0,8" Background="White" Foreground="#333" FontSize="14" BorderBrush="#CCC" Cursor="Hand"/>
    </StackPanel>
</Window>
"@
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

$window.FindName("btnCompress").add_Click({ Write-Host "COMPRESS_FILE"; $window.Close() })
$window.FindName("btnBatch").add_Click({ Write-Host "COMPRESS_FOLDER"; $window.Close() })
$window.FindName("btnChdman").add_Click({ Write-Host "CHDMAN"; $window.Close() })
$window.FindName("btnAbout").add_Click({ Write-Host "ABOUT"; $window.Close() })

$window.ShowDialog() | Out-Null
`
		cmd := exec.Command("powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-WindowStyle", "Hidden", "-Command", "-")
		cmd.Stdin = strings.NewReader(script)
		cmd.SysProcAttr = &syscall.SysProcAttr{CreationFlags: 0x08000000} // CREATE_NO_WINDOW
		out, err := cmd.CombinedOutput()
		
		if err != nil {
			zenity.Error(fmt.Sprintf("Failed to load UI: %v\nOutput: %s", err, string(out)), zenity.Title("Fatal Error"))
			return
		}

		selection := strings.TrimSpace(string(out))

		if selection == "" {
			return
		}

		if selection == "COMPRESS_FILE" {
			selectedFile, err := zenity.SelectFile(zenity.Title("Select a Game File"))
			if err == nil && selectedFile != "" {
				handleCompression([]string{selectedFile})
			}
		} else if selection == "COMPRESS_FOLDER" {
			selectedFolder, err := zenity.SelectFile(zenity.Title("Select a Folder (Batch Compress)"), zenity.Directory())
			if err == nil && selectedFolder != "" {
				handleFolderCompression(selectedFolder)
			}
		} else if selection == "CHDMAN" {
			appData, _ := os.UserConfigDir()
			engineDir := filepath.Join(appData, "iso-compressor")
			chdmanPath := filepath.Join(engineDir, "chdman.exe")
			os.MkdirAll(engineDir, os.ModePerm)

			if _, err := os.Stat(chdmanPath); os.IsNotExist(err) {
				ans, _ := zenity.Question("CHDMAN is currently NOT installed.\n\nDo you want to download and install it now?", zenity.Title("Install CHDMAN"))
				if ans {
					zenity.Info("Downloading chdman.exe. Please wait...", zenity.Title("Downloading Engine"))
					err := downloadFile("https://raw.githubusercontent.com/wako69420/iso-compressor/master/CLI/windows/chdman.exe", chdmanPath)
					if err != nil {
						zenity.Error(fmt.Sprintf("Failed to install CHDMAN: %v", err), zenity.Title("Download Failed"))
					} else {
						zenity.Info("CHDMAN installed successfully!", zenity.Title("Success"))
					}
				}
			} else {
				ans, _ := zenity.Question("CHDMAN is currently INSTALLED.\n\nDo you want to uninstall and remove it?", zenity.Title("Uninstall CHDMAN"))
				if ans {
					err := os.Remove(chdmanPath)
					if err != nil {
						zenity.Error(fmt.Sprintf("Failed to uninstall CHDMAN: %v", err), zenity.Title("Error"))
					} else {
						zenity.Info("CHDMAN uninstalled successfully!", zenity.Title("Success"))
					}
				}
			}
		} else if selection == "ABOUT" {
			zenity.Info(
				"PS1, PS2 & PSP Game Compressor\nVersion: v1.4.1\nLicense: BSD 3-Clause\n\nCredits:\n- maxcso by unknownbrackets\n- chdman by MAME Team\n- ZSO by ARK-5 & OPL Teams",
				zenity.Title("About / License"),
				zenity.InfoIcon,
			)
		}
	}
}

func handleFolderCompression(folderPath string) {
	entries, err := os.ReadDir(folderPath)
	if err != nil {
		zenity.Error(fmt.Sprintf("Failed to read folder: %v", err), zenity.Title("Error"))
		return
	}

	var validFiles []string
	extMap := make(map[string]bool)

	for _, e := range entries {
		if e.IsDir() {
			continue
		}
		ext := strings.ToLower(filepath.Ext(e.Name()))
		if ext == ".iso" || ext == ".cso" || ext == ".cue" {
			extMap[ext] = true
			validFiles = append(validFiles, filepath.Join(folderPath, e.Name()))
		}
	}

	if len(validFiles) == 0 {
		zenity.Error("No valid game files (.iso, .cso, .cue) were found in this folder.", zenity.Title("Batch Error"))
		return
	}

	if len(extMap) > 1 {
		zenity.Error("The folder must contain only ONE file format to convert (e.g., only .iso OR only .cso).\n\nMixed formats were found. Please separate them.", zenity.Title("Batch Error"))
		return
	}

	handleCompression(validFiles)
}

func handleCompression(files []string) {
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

$window.FindName("btnCHD").add_Click({ Write-Host "CHD"; $window.Close() })
$window.FindName("btnCSO").add_Click({ Write-Host "CSO"; $window.Close() })
$window.FindName("btnZSO").add_Click({ Write-Host "ZSO"; $window.Close() })

$window.ShowDialog() | Out-Null
`
	cmd := exec.Command("powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-WindowStyle", "Hidden", "-Command", "-")
	cmd.Stdin = strings.NewReader(script)
	cmd.SysProcAttr = &syscall.SysProcAttr{CreationFlags: 0x08000000} // CREATE_NO_WINDOW
	out, err := cmd.CombinedOutput()
	
	if err != nil {
		zenity.Error(fmt.Sprintf("Failed to load Format UI: %v\nOutput: %s", err, string(out)), zenity.Title("Fatal Error"))
		return
	}

	formatSelection := strings.TrimSpace(string(out))

	if formatSelection == "" {
		return
	}

	format := ""
	if formatSelection == "CHD" {
		format = "chd"
	} else if formatSelection == "CSO" {
		format = "cso1"
	} else if formatSelection == "ZSO" {
		format = "zso"
	} else {
		return
	}

	appData, _ := os.UserConfigDir()
	engineDir := filepath.Join(appData, "iso-compressor")
	os.MkdirAll(engineDir, os.ModePerm)

	maxcsoPath := filepath.Join(engineDir, "maxcso.exe")
	if format == "cso1" || format == "zso" {
		if _, err := os.Stat(maxcsoPath); os.IsNotExist(err) {
			zenity.Info("Downloading maxcso.exe for the first time. Please wait...", zenity.Title("Downloading Engine"))
			err := downloadFile("https://raw.githubusercontent.com/wako69420/iso-compressor/master/CLI/windows/maxcso.exe", maxcsoPath)
			if err != nil {
				zenity.Error(fmt.Sprintf("Failed to download maxcso.exe: %v", err), zenity.Title("Download Failed"))
				return
			}
		}
	}

	chdmanPath := filepath.Join(engineDir, "chdman.exe")
	if format == "chd" {
		if _, err := os.Stat(chdmanPath); os.IsNotExist(err) {
			zenity.Info("Downloading chdman.exe for the first time. Please wait...", zenity.Title("Downloading Engine"))
			err := downloadFile("https://raw.githubusercontent.com/wako69420/iso-compressor/master/CLI/windows/chdman.exe", chdmanPath)
			if err != nil {
				zenity.Error(fmt.Sprintf("Failed to download chdman.exe: %v", err), zenity.Title("Download Failed"))
				return
			}
		}
	}

	for _, file := range files {
		ext := strings.ToLower(filepath.Ext(file))
		baseName := strings.TrimSuffix(file, ext)
		
		var termCmd *exec.Cmd
		if format == "chd" {
			outFile := baseName + ".chd"
			cmdStr := "createdvd"
			if ext == ".cue" {
				cmdStr = "createcd"
			}
			termCmd = exec.Command(chdmanPath, cmdStr, "-i", file, "-o", outFile)
		} else {
			termCmd = exec.Command(maxcsoPath, "--format="+format, file)
		}
		
		termCmd.SysProcAttr = &syscall.SysProcAttr{CreationFlags: 0x00000010}
		
		err = termCmd.Run()
		if err != nil {
			zenity.Error(fmt.Sprintf("Failed to compress %s.\nExit Status: %v\nMake sure the file isn't open in another program.", file, err), zenity.Title("Error"))
			return
		}
	}

	zenity.Info("Compression finished successfully!", zenity.Title("Success"))
}

func downloadFile(url string, dest string) error {
	resp, err := http.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	out, err := os.Create(dest)
	if err != nil {
		return err
	}
	defer out.Close()
	_, err = io.Copy(out, resp.Body)
	return err
}
EOF
mv fix_chdman.go /tmp/wingui2/main.go
cd /tmp/wingui2
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
GOOS=windows GOARCH=amd64 go build -ldflags "-H windowsgui" -o ISO_Compressor_Windows.exe
cp ISO_Compressor_Windows.exe ~/Library/Mobile\ Documents/com~apple~CloudDocs/ISO_Compressor_Windows.exe