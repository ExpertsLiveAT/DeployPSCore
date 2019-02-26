#'Installing OpenSSH'
$Oshsourceuri = 'https://github.com/PowerShell/Win32-OpenSSH/releases/download/v7.9.0.0p1-Beta/OpenSSH-Win64.zip'
$oshfile = Split-path $Oshsourceuri -Leaf
$targetpath = 'c:\temp\'
#$Servers = 'esflovian.thegalaxy.local'
$Servers = 'oglaroon.thegalaxy.local'

foreach ($Server in $Servers) {
    $cs = New-pssession -ComputerName $Server
    Write-Verbose 'Installing OpenSSH'
    Invoke-command -Session $cs -ScriptBlock {
    Write-Verbose 'Test if target path exists, otherwise create'
    if (!(test-path $using:targetpath)) {
        New-Item -ItemType Directory -Path $using:targetpath -InformationAction SilentlyContinue
    }
    
    write-verbose 'Construct targetpath'
    $targetfilepath = $using:targetpath + $using:oshfile
    
        # DL and unblock File with webrequest
        if (!(Test-Path -Path $targetfilepath)) {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Invoke-WebRequest -Uri $using:oshsourceuri -OutFile $targetfilepath
            Unblock-File -Path $targetfilepath # -InformationAction SilentlyContinue
        }

        Write-verbose 'Install OpennSSH Daemon'
        $destpath = 'C:\Program Files\'
        #$instfilename = '.\install_sshd'
        Expand-Archive -Path $targetfilepath -DestinationPath $destpath -Force
        start-sleep 5
        #Set-Location "$destpath\OpenSSH-Win64"
        #get-location
        & "C:\Program Files\OpenSSH-Win64\install-sshd.ps1"

        start-service sshd
        start-sleep 5
        stop-service sshd

        
        # Backup SSH config file
        copy-item "C:\ProgramData\ssh\sshd_config" -Destination "C:\ProgramData\ssh\sshd_config_original"

        # Change PasswordAuthentication to yes
        $origfile = Get-content "C:\ProgramData\ssh\sshd_config_original"
        $origfile |ForEach-Object {
            if ($_ -eq "#PasswordAuthentication yes") {
                $_ -replace "#PasswordAuthentication yes", "PasswordAuthentication yes"} 
            else {$_} 
        } | Set-Content "C:\ProgramData\ssh\sshd_config" -Force

        # Change PublicKeyAuthentication to yes
        $origfile = Get-content "C:\ProgramData\ssh\sshd_config"
        $origfile |foreach-object {
            if ($_ -eq "#PubkeyAuthentication yes") {
                $_ -replace "#PubkeyAuthentication yes", "PubkeyAuthentication yes"} 
            else {$_} 
        } | Set-Content "C:\ProgramData\ssh\sshd_config" -Force

        # Create Symlink
        if (!(test-path 'c:\pwsh')) {
            New-Item -Path c:\pwsh -ItemType SymbolicLink -Value "C:\Program Files\PowerShell\6"
        }
        #$replacestring = 'Subsystem    powershell c:\pwsh\pwsh.exe -sshs -NoLogo -NoProfile'

        $origfile = Get-content "C:\ProgramData\ssh\sshd_config"
        $origfile |ForEach-Object {
            if ($_ -eq "Subsystem	sftp	sftp-server.exe") {
                $_ -replace "Subsystem	sftp	sftp-server.exe", "Subsystem    powershell c:\pwsh\pwsh.exe -sshs -NoLogo -NoProfile"} 
            else {$_} 
        } | Set-Content "C:\ProgramData\ssh\sshd_config" -Force

        Set-Service sshd -StartupType Automatic
        Restart-Service sshd
    }
}

<#
$origfile |foreach {if ($_ -eq "#PasswordAuthentication yes") {$_ -replace "#PasswordAuthentication yes", "PasswordAu
thentication yes"} else {$_} }|Set-Content .\ssh_confignew -Force
#>