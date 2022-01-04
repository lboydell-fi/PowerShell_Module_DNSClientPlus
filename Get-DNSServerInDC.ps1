function Get-DNSServerInDC
{
<#
.Synopsis
   Return hostnames of all registered DNS servers in current domain
.DESCRIPTION
   Return hostnames of all registered DNS servers in current domain
.EXAMPLE
Get-DNSServerInDC

Returns all DNS servers in current domain
.NOTES
   Author: Logan Boydell (L-Bo)
#>
  $dnsRawOutput = ((nslookup $env:USERDNSDOMAIN) | Select-Object -Skip 3) -split "`n"
  $regEx = '(?:25[0-5]|2[0-4]\d|[0-1]?\d{1,2})(?:\.(?:25[0-5]|2[0-4]\d|[0-1]?\d{1,2})){3}'
  ([regex]::Matches($dnsRawOutput,$regEx)).value | ForEach-Object {
    $IP = $_
    Resolve-DnsName -Name $IP | Select @{l='DNSServer';e={$_.NameHost}},@{l='IPAddress';e={$IP}} -Unique
    }
}
