# ================== CONFIGURATION ==================
$targetPath = "C:\temp\"
$installerName = "npp.8.8.2.Installer.x64.exe"
$installerFullPath = Join-Path $targetPath $installerName

# Direct download URL to your Notepad++ installer
# Must be public OR not requiring authentication
$downloadUrl = "https://raw.githubusercontent.com/0110tanush/Test/d79690659dd76dece83b7a877a06d0cce91ef6a6/npp_latest_x64.exe"

# ================== ENSURE FOLDER EXISTS ==================
if (-not (Test-Path -Path $targetPath)) {
    New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
    Write-Host "Created folder path: $targetPath"
} else {
    Write-Host "Folder already exists: $targetPath"
}

# ================== DOWNLOAD INSTALLER ==================
Write-Host "Downloading Notepad++ v8.8.2 installer..."
try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $installerFullPath -UseBasicParsing
    Write-Host "Download completed: $installerFullPath"
} catch {
    Write-Error "Failed to download installer: $_"
    exit 1
}

# ================== INSTALL NOTEPAD++ ==================
Write-Host "Installing Notepad++ silently..."
try {
    $installProcess = Start-Process -FilePath $installerFullPath -ArgumentList "/S" -Wait -PassThru
    if ($installProcess.ExitCode -eq 0) {
        Write-Host "Notepad++ installation completed successfully."

        # Remove installer file
        Remove-Item -Path $installerFullPath -Force
        Write-Host "Installer file removed."

        # Create/update readme.html with status
        $readmePath = Join-Path $targetPath "readme.html"
        $statusText = "<html><body><h3>Notepad++ v8.8.2 installed successfully on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</h3></body></html>"
        $statusText | Out-File -FilePath $readmePath -Encoding UTF8

        Write-Host "Installation status saved in $readmePath"
    } else {
        Write-Warning "Installer exited with code $($installProcess.ExitCode) — Installation may have failed."
    }
} catch {
    Write-Error "Error occurred during installation: $_"

}


