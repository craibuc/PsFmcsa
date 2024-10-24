<#
.PARAMETER JWT
The java web token.

.PARAMETER RegistryID
The examiner's national registry #.

.EXAMPLE
Find-FmcsaExaminer -JWT [token] -RegistryID '0123456789'

.LINK
https://nationalregistry.fmcsa.dot.gov/home
#>
function Find-FmcsaExaminer {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$JWT,

        [string]$RegistryID,

        [string]$FirstName,
        [string]$LastName,
        [string]$BusinessName,
 
        [int]$Distance = 10,

        [ValidateSet('miles','kilometers')]
        [string]$Units = 'miles'
    )
    
    begin {
        $Headers = @{
            Accept = 'application/json'
            'cl_jw_token' = $JWT
        }
        $BaseUri = 'https://nrcme-prod-api.natss-aws.us/prod/search-medical-examiners/map'
    }
    
    process {

        $Query = @{
            advancedSearch = 1
            distance = $Distance
            unit = $Units
            nationalRegNumber = $RegistryID
            businessName = $BusinessName
            firstName = $FirstName
            lastName = $LastName
        }

        $QS=@()
        $QS += foreach($Q in $Query.GetEnumerator()) {
            "{0}={1}" -f $Q.Name, $Q.Value
        }

        $Uri = $QS.Length -gt 0 ? ( "{0}?{1}" -f $BaseUri, ($QS -join '&') ) : $BaseUri
        Write-Debug "Uri: $Uri"

        try {
            $Response = Invoke-WebRequest -Method Get -Uri $Uri -Headers $Headers
            if ($Response.Content) {
                ($Response.Content | ConvertFrom-Json).data
            }
        }
        catch {
            $_.Exception.Message
        }

    }
    
    end {}

}