Set oWS = WScript.CreateObject("WScript.Shell")
sLinkFile = oWS.CurrentDirectory & "\PSP ISO Compressor.lnk"
Set oLink = oWS.CreateShortcut(sLinkFile)
oLink.TargetPath = oWS.CurrentDirectory & "\Drag and Drop Games Here.bat"
oLink.IconLocation = oWS.CurrentDirectory & "\icon.ico"
oLink.Save
