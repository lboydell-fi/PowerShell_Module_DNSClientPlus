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
    # IPv4 RegEx
    $regEx = '(?:25[0-5]|2[0-4]\d|[0-1]?\d{1,2})(?:\.(?:25[0-5]|2[0-4]\d|[0-1]?\d{1,2})){3}'
    $ObjColl += $([regex]::Matches($subcollection.Context.PostContext,$regEx)).Value
    
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
