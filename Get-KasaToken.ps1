# This script is used to request a token from the TP-Link Kasa API
# Written by Jake Weaver
# January 2019

# JSON that contains the login info
$params = "{
    'appType':'Kasa_Android',
    'cloudUserName':'your@email.com',
    'cloudPassword':'yourpassword',
    'terminalUUID':'your uuid',
    }"

# The request body we are going to send
$body = "{
    'method':'login',
    'params':$params
   }"

# Call the api and authenticate
$response = Invoke-RestMethod "https://wap.tplinkcloud.com" -Method POST -Body $body -ContentType application/json

# Extract the data we want from the response
$data = ($response.Result)

# Return the token to the pipeline
$data.token