if (-Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process PowerShell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Exit
}

try {
    Write-Host "Enabling SQL Server TCP/IP..."
    $protocol = Get-CimInstance -Namespace "root\Microsoft\SqlServer\ComputerManagement17" -ClassName ServerNetworkProtocol -Filter "ProtocolName='Tcp' and InstanceName='MSSQLSERVER'"
    Invoke-CimMethod -InputObject $protocol -MethodName SetEnable

    $prop = Get-CimInstance -Namespace "root\Microsoft\SqlServer\ComputerManagement17" -ClassName ServerNetworkProtocolProperty -Filter "ProtocolName='Tcp' and InstanceName='MSSQLSERVER' and IPAddressName='IPAll' and PropertyName='TcpPort'"
    Invoke-CimMethod -InputObject $prop -MethodName SetStringValue -Arguments @{StrValue="1433"}

    Write-Host "Restarting SQL Server..."
    Restart-Service -Name "MSSQLSERVER" -Force
    Write-Host "Done! SQL Server is now ready for Prisma."
} catch {
    Write-Host "Error: $_"
}
Read-Host -Prompt "Press Enter to exit"
