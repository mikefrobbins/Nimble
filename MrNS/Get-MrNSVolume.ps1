#Requires -Version 4.0 -Module TunableSSLValidator
function Get-MrNSVolume {

<#
.SYNOPSIS
    Retrieves information for volumes on a Nimble SAN.
 
.DESCRIPTION
    Get-MrNSVolume is an advanced function that retrieves information for volumes on a Nimble SAN.
    The TunableSSLValidator module is required since Nimble uses an untrusted SSL certificate. It can
    be found on GitHub: https://github.com/Jaykul/Tunable-SSL-Validator
 
.PARAMETER Group
    The DNS name or IP address of the Nimble group. The default is the group that you've already connected
    to using the Connect-MrNSGroup function.

.PARAMETER Port
    The port number for the Nimble REST API. The default value is 5392. This parameter is hidden and
    provided only as a means to easily change the port number if the API ever changes.
 
.PARAMETER Name
    Name of the volume.

.PARAMETER Id
    Identifier for the volume.
 
.EXAMPLE
     Get-MrNSVolume -Name Volume001

.EXAMPLE
     Get-MrNSVolume -Id '07204756105a0139c1000000000000000000000009'
 
.INPUTS
    None
 
.OUTPUTS
    MrNS.Volume
 
.NOTES
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>

    [CmdletBinding(DefaultParameterSetName='Name')]
    param (
        [Parameter(DontShow)]
        [ValidateNotNullOrEmpty()]
        [string]$Group = $array,

        [Parameter(DontShow)]
        [ValidateNotNullOrEmpty()]
        [int]$Port = 5392,

        [Parameter(ParameterSetName='Name')]
        [string]$Name,

        [Parameter(ParameterSetName='Id')]
        [string]$Id
    )

    $Uri = "https://$($Group):$($Port)"

    $Params = @{        
        Header = @{'X-Auth-Token' = $session_token}
        Method = 'Get'
        Insecure = $true
    }

    if ($PSBoundParameters.Name){
            
        $Params.Uri = "$Uri/v1/volumes?name=$Name"

    }
    elseif ($PSBoundParameters.Id) {
        
        $Params.Uri = "$Uri/v1/volumes?id=$Id"
    }
    else {

        $Params.Uri = "$Uri/v1/volumes"

    }    

    $Volumes = (TunableSSLValidator\Invoke-RestMethod @Params).data
            
    foreach ($Volume in $Volumes.id){  
  
        $Params.Uri = "$Uri/v1/volumes/$Volume"

        $Result = (TunableSSLValidator\Invoke-RestMethod @Params).data
        $Result.PSTypeNames.Insert(0,'MrNS.Volume')

        Write-Output $Result

    }

}
