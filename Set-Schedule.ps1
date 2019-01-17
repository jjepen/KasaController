# This script sets scheduled tasks based on sunrise and sunset
# Written by Jake Weaver
# January 2019

# This funtion converts from UTC time to local time.
Function Get-LocalTime($UTCTime)
{
    $strCurrentTimeZone = (Get-WmiObject win32_timezone).StandardName
    $TZ = [System.TimeZoneInfo]::FindSystemTimeZoneById($strCurrentTimeZone)
    $LocalTime = [System.TimeZoneInfo]::ConvertTimeFromUtc($UTCTime, $TZ)
    Return $LocalTime
}

# The lat/long of the location you want to get the sunset & sunrise times for
$lattitude = "46.76717"
$longitude = "-120.68725"

# Get tomorrow's sunrise & sunset times
# Api documentation can be found here:
# https://sunrise-sunset.org/api
$response = Invoke-RestMethod "https://api.sunrise-sunset.org/json?lat=$lattitude&lng=$longitude&date=tomorrow&format=0" -Method GET

# Parse the response from the API and convert to DateTime objects
$sunrise = Get-LocalTime([datetime]::Parse($response.results.sunrise))
$sunset = Get-LocalTime([datetime]::Parse($response.results.sunset))

# Create new triggers for the sceduled tasks
$sunriseTaskTime = New-ScheduledTaskTrigger -at ($sunrise).AddHours(.5) -Daily
$sunsetTastTime = New-ScheduledTaskTrigger -at ($sunset).AddHours(-.5) -Daily

# The password for the account that runs the scheduled task is stored in a text file.  This code reads the encrypted password
# and converts it into an object we can pass when we update the scheduled task.
# To save the password, run the two commented lines below ON THE MACHINE where this task will run
# $credential = Get-Credential
# $credential.Password | ConvertFrom-SecureString | Set-Content <path_to_password_file.txt>
$password = Get-Content .\password.txt | ConvertTo-SecureString
$password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

# Update the scheduled tasks with the new triggers.
Set-ScheduledTask -TaskName "\Scripts\Outdoor Lights - Sunrise" -Trigger $sunriseTaskTime -User "Administrator" -Password $password
Set-ScheduledTask -TaskName "\Scripts\Outdoor Lights - Sunset" -Trigger $sunsetTastTime -User "Administrator" -Password $password
