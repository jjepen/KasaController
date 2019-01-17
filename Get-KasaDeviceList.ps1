# This script gets a list of devices associated with a TP-Link Kasa account
# Written by Jake Weaver
# January 2019

# Get an API token
$token = .\Get-KasaToken.ps1

# The JSON body that tells the API to run the getDeviceList method
$body = "{'method':'getDeviceList'}"

# Make the request to the API
$response = Invoke-RestMethod "https://wap.tplinkcloud.com?token=$token" -Method POST -Body $body -ContentType application/json

# Extract the data we want from the response
$devices = $response.Result

# Pass the device list out to the pipeline
$devices.deviceList