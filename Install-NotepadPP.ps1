$targetPath = "C:\Program Files (x86)\Notepad++"
$installerName = "npp.8.8.2.Installer.x64.exe"
$installerFullPath = Join-Path $targetPath $installerName
$downloadUrl = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.8.2/npp.8.8.2.Installer.x64.exe"

# Check if the folder exists
if (-not (Test-Path -Path $targetPath)) {
    New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
    Write-Host "Created folder path: $targetPath"
} else {
    Write-Host "Folder already exists: $targetPath"
}

# Wait for 180 seconds
Write-Host "Waiting 180 seconds before downloading the installer..."
Start-Sleep -Seconds 180

# Download the installer with curl.exe
Write-Host "Downloading Notepad++ installer from $downloadUrl ..."
curl.exe -L -o $installerFullPath $downloadUrl

if (Test-Path $installerFullPath) {
    Write-Host "Downloaded Notepad++ installer to $installerFullPath"

    # Run the installer silently
    Write-Host "Installing Notepad++ silently..."
    $installProcess = Start-Process -FilePath $installerFullPath -ArgumentList "/S" -Wait -PassThru

    if ($installProcess.ExitCode -eq 0) {
        Write-Host "Notepad++ installation completed successfully."

        # Remove installer after successful install
        Remove-Item -Path $installerFullPath -Force
        Write-Host "Installer file removed."
    } else {
        Write-Warning "Installer exited with code $($installProcess.ExitCode). Installation may have failed."
    }
} else {
    Write-Warning "Failed to download the installer from $downloadUrl"
}