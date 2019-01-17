# This script sets the state of TP-Link Kasa Smart Switches
# Written by Jake Weaver
# January 2019

param (
    # The device(s) to control
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string[]] $DeviceID,

    # The state to set the switches to
    [Parameter(Mandatory = $true)]
    [ValidateSet("On","Off")]
    [string] $State
)

# Get an API token
$token = .\Get-KasaToken.ps1

# Convert the State string to numerical values
$numericalState = switch ($State) {
    "On" { 1 }
    "Off" { 0 }
}

# Set up a variable to hold the output
$output =@()

# Loop through the devices that were passed on the pipeline
foreach ($id in $DeviceID) {

    # Build the request body in JSON
    # The API requires double quotes in the body so we have to do some odd escaping here
    $body = "{
                `"method`":`"passthrough`",
                `"params`":{
                    `"deviceId`":`"$id`",
                    `"requestData`":`"{\`"system\`":{\`"set_relay_state\`":{\`"state\`":$numericalState}}}`"
                }
            }"

    # Make the call to the API
    $response = Invoke-RestMethod  "https://use1-wap.tplinkcloud.com?token=$token" -Method POST -Body $body -ContentType application/json

    # We only care about the response error code so create a new PS Object to hold it and the DeviceID
    $output += [PSCustomObject]@{
        DeviceID = $id
        ErrorCode = $response.error_code
    }
}

# Drop the output on pipeline.
$output