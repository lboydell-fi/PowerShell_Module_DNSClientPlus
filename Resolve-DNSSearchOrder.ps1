function Resolve-DNSSearchOrder ([string]$ComputerName)
{
    # Save output from ipconfig /all legacy command
    if($ComputerName)
      {
        $collection = Invoke-Command -ComputerName $ComputerName -ScriptBlock {ipconfig /all}
      }
    else
      {
        $collection = ipconfig /all
      }

    # Extrapolate primary DNS server
    $primaryDNSServerIP = (($collection | Select-String -Pattern "DNS Servers").ToString().Split(":"))[-1].Trim()
    $primaryDNSServer = (Resolve-DnsName -Name $primaryDNSServerIP).NameHost

    # Get all DNS servers configured for the NIC
    $subcollection = $collection | Select-String -Pattern 'DNS Servers' -Context 8

    # Create a blank array
    $objColl = @()

    # Add the $primaryDNSServerIP
    $objColl += $primaryDNSServerIP

    # Add all matches from an IPv4 RegEx pattern to the collection
    $objColl += $([regex]::Matches($subcollection.Context.PostContext,"\d+\.\d+\.\d+\.\d+")).Value
    
    # Resolve IPs of DNS servers, returning host names
    $returnColl = @()
    foreach($obj in $objColl)
      {
        $returnColl += [PSCustomObject]@{
        DNSServer = (Resolve-DnsName -Name $obj -Server $primaryDNSServer).NameHost
        ComputerName = $(if($ComputerName){$ComputerName}else{$env:COMPUTERNAME})
        }
      }
    $returnColl
}