#Requires -Version 4.0 -Module TunableSSLValidator
function Get-MrNSToken {

<#
.SYNOPSIS
    List user session tokens.
 
.DESCRIPTION
    Get-MrNSToken is an advanced function that lists user session tokens for the specified Nimble SAN.
    The TunableSSLValidator module is required since Nimble uses an untrusted SSL certificate. It can
    be found on GitHub: https://github.com/Jaykul/Tunable-SSL-Validator
 
.PARAMETER Group
    The DNS name or IP address of the Nimble group. The default is the group that you've already connected
    to using the Connect-MrNSGroup function.

.PARAMETER Port
    The port number for the Nimble REST API. The default value is 5392. This parameter is hidden and
    provided only as a means to easily change the port number if the API ever changes.
 
.EXAMPLE
     Get-NStoken

.EXAMPLE
     Get-NStoken -Group 192.168.1.50
 
.INPUTS
    None
 
.OUTPUTS
    MrNS.Token
 
.NOTES
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>

    [CmdletBinding()]
    param (
        [Parameter(DontShow)]
        [ValidateNotNullOrEmpty()]
        [string]$Group = $array,

        [Parameter(DontShow)]
        [ValidateNotNullOrEmpty()]
        [int]$Port = 5392
    )

    $Uri = "https://$($Group):$($Port)"

    $Header = @{'X-Auth-Token' = $session_token}

    $Tokens = TunableSSLValidator\Invoke-RestMethod -Uri "$Uri/v1/tokens" -Method Get -Header $Header -Insecure

    foreach ($Token in $Tokens.data.id){  
  
        $TokenUri = "$Uri/v1/tokens/$Token"

        $Result = (TunableSSLValidator\Invoke-RestMethod -Uri $TokenUri -Method Get -Header $header -Insecure).data
        $Result.PSTypeNames.Insert(0,'MrNS.Token')

        Write-Output $Result
    }  

}