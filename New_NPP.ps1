# ================== CONFIGURATION ==================
$targetPath = "C:\temp\"
$installerName = "npp.8.8.2.Installer.x64.exe"
$installerFullPath = Join-Path $targetPath $installerName

# Expected Notepad++ install path (64-bit default)
$notepadPPPath = "C:\Program Files\Notepad++\notepad++.exe"

# Direct RAW GitHub download URL to installer
$downloadUrl = "https://raw.githubusercontent.com/0110tanush/Test/d79690659dd76dece83b7a877a06d0cce91ef6a6/npp_latest_x64.exe"

# ================== ENSURE FOLDER EXISTS ==================
if (-not (Test-Path -Path $targetPath)) {
    New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
    Write-Host "Created folder path: $targetPath"
} else {
    Write-Host "Folder already exists: $targetPath"
}

# ================== DOWNLOAD + INSTALL ==================
try {
    Write-Host "Downloading Notepad++ v8.8.2 installer..."
    Invoke-WebRequest -Uri $downloadUrl -OutFile $installerFullPath -UseBasicParsing
    Write-Host "Download completed: $installerFullPath"

    Write-Host "Installing Notepad++ silently..."
    $installProcess = Start-Process -FilePath $installerFullPath -ArgumentList "/S" -Wait -PassThru
    
    if ($installProcess.ExitCode -eq 0) {
        Write-Host "Notepad++ installation completed successfully."
    } else {
        Write-Warning "Installer exited with code $($installProcess.ExitCode) — Installation may have failed."
    }

    # Remove installer after install
    if (Test-Path $installerFullPath) {
        Remove-Item -Path $installerFullPath -Force
        Write-Host "Installer file removed."
    }
}
catch {
    Write-Error "Error during download or installation: $_"
    exit 1
}

# ================== VALIDATE NOTEPAD++ PATH ==================
if (Test-Path -Path $notepadPPPath) {
    Write-Host "Confirmed Notepad++ executable exists at: $notepadPPPath"
} else {
    Write-Warning "Notepad++ executable NOT found at expected path: $notepadPPPath"
}

# ================== ADD CONTEXT MENU "OPEN WITH NOTEPAD++" ==================
try {
    $contextMenuPath = "Registry::HKEY_CLASSES_ROOT\*\shell\NotepadPP"
    $commandPath = "$contextMenuPath\command"

    if (-not (Test-Path $contextMenuPath)) {
        # Create keys
        New-Item -Path $contextMenuPath -Force | Out-Null
        New-Item -Path $commandPath -Force | Out-Null
        
        # Set display name in context menu
        Set-ItemProperty -Path $contextMenuPath -Name "(Default)" -Value "Open with Notepad++"
        
        # Command to launch NPP with selected file
        Set-ItemProperty -Path $commandPath -Name "(Default)" -Value "`"$notepadPPPath`" `"%1`""
        
        Write-Host "Added 'Open with Notepad++' context menu entry."
    } else {
        Write-Host "'Open with Notepad++' context menu entry already exists."
    }
}
catch {
    Write-Warning "Failed to create context menu entry: $_"
}

Write-Host "Script execution completed."
