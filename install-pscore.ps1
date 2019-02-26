$ServersAD = Get-ADComputer -SearchBase 'OU=Servers,OU=Hardware,DC=thegalaxy,DC=local' -Filter '*' |select-object -expandproperty DNSHostname

$Servers = 'esflovian.thegalaxy.local' ,'oglaroon.thegalaxy.local'
$Servers = 'esflovian.thegalaxy.local'
$Servers = 'oglaroon.thegalaxy.local'

$msiurl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.1.3/PowerShell-6.1.3-win-x64.msi'
$sourcefilename = Split-Path $msiurl -Leaf
#$sourcefilepath = 'c:\temp\' + $sourcefilename
$targetpath = 'c:\temp\'

foreach ($Server in $Servers) {
    # Installing PSCore
    $cs = New-pssession -ComputerName $Server
    invoke-command -Session $cs -ScriptBlock {
        # First test if installed already
        if (!(Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |Where-Object DisplayName -like '*PowerShell 6*'| Select-Object -expandproperty DisplayVersion) -eq '6.1.3.0') {
            # Test if target path exists, otherwise create
            if (!(test-path $using:targetpath)) {
                New-Item -ItemType Directory -Path $using:targetpath -InformationAction SilentlyContinue
            }

            # Construct targetfilepath in session
            $targetfilepath = $using:targetpath + $using:sourcefilename
            # DL and unblock File with webrequest
            if (!(Test-Path -Path $targetfilepath)) {
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                Invoke-WebRequest -Uri $using:msiurl -OutFile $targetfilepath
                Unblock-File -Path $targetfilepath # -InformationAction SilentlyContinue
            }

            # install-remote via MSI
            Write-Host "INSTALLING"
            #Test-path $targetfilepath
            (Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $targetfilepath /quiet /qn /norestart /log c:\temp\install.log" -Wait -Passthru).ExitCode
            #remove-item $targetfilepath
        }
    }
    Remove-PSSession -Session $cs
}

