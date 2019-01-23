Write-Verbose 'Installing OpenSSH'
$Oshsourcepath = '\\teles\install\Microsoft\OpenSSH\OpenSSH-Win64.zip'
$oshfile = Split-path $Oshsourcepath -Leaf
$targetpath = 'c:\temp\'
$Servername = 'Teles.thegalaxy.local'

$cs = New-pssession -ComputerName $Servername

Write-Verbose 'Installing OpenSSH'
Invoke-command -Session $cs -ScriptBlock {
    Write-Verbose 'Test if target path exists, otherwise create'
    if (!(test-path $using:targetpath)) {
        New-Item -ItemType Directory -Path $using:targetpath -InformationAction SilentlyContinue
    }
    
    write-verbose 'Construct targetpath'
    $filename = split-path $using:Oshsourcepath -Leaf
    $filepath = $using:Oshsourcepath + $filename
    
    Write-Verbose 'Copy and unblock File'
    if (!(Test-Path -Path $filepath)) {
        Copy-Item -Path $using:Sourcepath -Destination $using:targetpath -InformationAction SilentlyContinue
        Unblock-File -Path $filepath -InformationAction SilentlyContinue
    }

    Write-verbose 'Install OpennSH Daemon'
    $destpath = 'C:\Program Files\'
    $instfilename = '.\install_sshd'
    Expand-Archive -Path $filepath -DestinationPath $destpath -Force
    Set-Loction $destpath
    .\install_openssh.ps1

    start-service sshd
    stop-service sshd

    $programdatapath = 'c:\programdata'
    copy-item "$programdata\sshd_config" -Destination "$programdata\sshd_config_original"

    # Change PasswordAuthentication to yes
    $origfile = Get-content "$programdatapath\sshd_config"
    $origfile |foreach {
        if ($_ -eq "#PasswordAuthentication yes") {
            $_ -replace "#PasswordAuthentication yes", "PasswordAuthentication yes"} 
        else {$_} 
    } | Set-Content .\ssh_confignew -Force

    # Change PublicKeyAuthentication to yes
    $origfile = Get-content "$programdatapath\sshd_config"
    $origfile |foreach {
        if ($_ -eq "#PublicKeyAuthentication yes") {
            $_ -replace "#PublicKeyAuthentication yes", "PublicKeyAuthentication yes"} 
        else {$_} 
    } | Set-Content .\ssh_confignew -Force

    # Create Symlink
    mklink /D c:\pwsh "C:\Program Files\PowerShell\6"
    $replacestring = 'Subsystem    powershell c:\pwsh\pwsh.exe -sshs -NoLogo -NoProfile'

    $origfile = Get-content "$programdatapath\sshd_config"

    $origfile |foreach {
        if ($_ -eq "Subsystem	sftp	sftp-server.exe") {
            $_ -replace "Subsystem	sftp	sftp-server.exe", "Subsystem    powershell c:\pwsh\pwsh.exe -sshs -NoLogo -NoProfile"} 
        else {$_} 
    } | Set-Content .\ssh_confignew -Force

    Start-Service sshd
}



$origfile |foreach {if ($_ -eq "#PasswordAuthentication yes") {$_ -replace "#PasswordAuthentication yes", "PasswordAu
thentication yes"} else {$_} }|Set-Content .\ssh_confignew -Force