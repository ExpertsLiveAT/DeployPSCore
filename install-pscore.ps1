$Servers = Get-ADComputer -SearchBase 'OU=Servers,OU=Hardware,DC=thegalaxy,DC=local' -Filter '*' |select -expandproperty DNSHostname
# add comment
$sourcepath = '\\teles\install\Microsoft\PowerShell\PowerShell-6.1.2-win-x64.msi'
$targetpath = 'c:\temp\'
$Servername = 'Teles.thegalaxy.local'

$cs = New-pssession -ComputerName $Servername

Write-Verbose 'Installing PSCore'
invoke-command -Session $cs -ScriptBlock {
    Write-Verbose 'Test if target path exists, otherwise create'
    if (!(test-path $using:targetpath)) {
        New-Item -ItemType Directory -Path $using:targetpath -InformationAction SilentlyContinue
    }
    
    write-verbose 'Construct targetpath'
    $filename = split-path $using:sourcepath -Leaf
    $filepath = $using:targetpath + $filename
    
    Write-Verbose 'Copy and unblock File'
    if (!(Test-Path -Path $filepath)) {
        Copy-Item -Path $using:Sourcepath -Destination $using:targetpath -InformationAction SilentlyContinue
        Unblock-File -Path $filepath -InformationAction SilentlyContinue
    }

    write-verbose "install-remote via MSI"
    (Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $filepath /quiet /qn /norestart /log $using:targetpath\install.log" -Wait -Passthru).ExitCode
    
}





# $msiguid = '65276649-728D-4AB9-AAEC-6EFF860B11EC'
Remove-PSSession -Session $cs