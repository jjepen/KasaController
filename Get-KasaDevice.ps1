# This script gets the state of a TP-Link Kasa Device
# Written by Jake Weaver
# January 2019

param (
    # The device(s) to query
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string[]] $DeviceID
)

# Get an API token
$token = .\Get-KasaToken.ps1

# Loop through the DeviceID's that were passed to the script from the pipeline.
foreach ($id in $DeviceID){

    # JSON that makes up the request body
    # The API requires double quotes in the body so we have to do some odd escaping here
    $body = "{
        `"method`":`"passthrough`",
        `"params`":{
            `"deviceId`":`"$id`",
            `"requestData`":`"{\`"system\`":{\`"get_sysinfo\`":null},\`"emeter\`":{\`"get_realtime\`":null}}`"
        }
    }"

    # Make the call to the API
    $response = Invoke-RestMethod  "https://wap.tplinkcloud.com?token=$token" -Method POST -Body $body -ContentType application/json

    # Extract the data we care about.  This round about conversion from and then back to JSON is because of the nested nature
    # of the response and powershell not properly parsing it through all the levels
    $data = $response.result.responseData | ConvertFrom-Json
    $system = ConvertTo-Json $data.system
    $temp = $system | ConvertFrom-Json
    $device = $temp.get_sysinfo
    
    # Output the device as a PS Object on the pipeline
    $device
}