
$Servers = 'server1, server2'

foreach ($Server in $Servers) {
    # UNInstalling PSCore
    $cs = New-pssession -ComputerName $Server
    invoke-command -Session $cs -ScriptBlock {
        $pwshmsi = 'c:\temp\PowerShell-6.1.3-win-x64.msi'
        if (test-path c:\temp\uninstall.log) {
            Remove-Item -Path c:\temp\uninstall.log -Force
        }
        (Start-Process -Filepath "msiexec.exe" -Argumentlist "/x $pwshmsi /quiet /qn /norestart /log c:\temp\uninstall.log").ExitCode
    }
}
