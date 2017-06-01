﻿#Requires -Version 4.0 -Module TunableSSLValidator
function Connect-MrNSGroup {

<#
.SYNOPSIS
    Connects to a Nimble SAN.
 
.DESCRIPTION
    Connect-MrNSGroup is an advanced function that provides the initial connection to a Nimble SAN
    so that other subsequent commands can be run without having to each authenticate individually.
    The TunableSSLValidator module is required since Nimble uses an untrusted SSL certificate. It
    can be found on GitHub: https://github.com/Jaykul/Tunable-SSL-Validator
 
.PARAMETER Group
    The DNS name or IP address of the Nimble group.

.PARAMETER Port
    The port number for the Nimble REST API. The default value is 5392. This parameter is hidden and
    provided only as a means to easily change the port number if the API ever changes.

.PARAMETER Credential
    Specifies a user account that has permission to perform this action. Type a user name, such as User01
     or enter a PSCredential object, such as one generated by the Get-Credential cmdlet. If you type a
     user name, this function prompts you for a password.
 
.EXAMPLE
     Connect-MrNSGroup -Group nimblegroup.yourdns.local -Credential (Get-Credential)

.EXAMPLE
     Connect-MrNSGroup -Group 192.168.1.50 -Credential (Get-Credential)
 
.INPUTS
    None
 
.OUTPUTS
    None
 
.NOTES
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Group,

        [Parameter(DontShow)]
        [ValidateNotNullOrEmpty()]
        [int]$Port = 5392,

        [Parameter(Mandatory)]
        [System.Management.Automation.Credential()]$Credential
    )    

    $Uri = "https://$($Group):$($Port)"
    
    #Variables set to Global scope to make this function compatible with the functions in the NimblePowerShellToolKit module
    $Global:tokenData = TunableSSLValidator\Invoke-RestMethod -Uri "$Uri/v1/tokens" -InSecure -Method Post -Body ((@{data = @{username = $Credential.UserName;password = $Credential.GetNetworkCredential().password}}) | ConvertTo-Json)
    $Global:RestVersion = (TunableSSLValidator\Invoke-RestMethod -Uri "$Uri/versions" -Insecure).data.name
    $Global:session_token = $tokenData.data.session_token
    $Global:array = $Group
}