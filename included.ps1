$se = New-PSSession -ComputerName esflovian

Enter-PSSession $se
# Kann man PSCore nachinstallieren ?
Get-WindowsFeature -Name '*Power*'
Get-WindowsOptionalFeature -Online|where name -like '*po*'|select name
Get-WindowsOptionalFeature -Online|where name -like '*pw*'|select name
Get-WindowsCapability -Online |where name -like '*po*'|select name
Get-WindowsCapability -Online |where name -like '*pw*'|select name

# OpenSSH ?
Get-windowscapability -online -Name 'OpenSSH.Server~~~~0.0.1.0'
install-windowsfeature -Name 'OpenSSH.Server~~~~0.0.1.0' -Verbose

# The easy way ?
#choco install pwsh
#OpenSSH funktionierte nicht :-)



