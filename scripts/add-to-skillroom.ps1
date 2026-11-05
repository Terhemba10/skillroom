<#
  Adds a Mattermost user to the SkillRoom channels for their role.

    manager  -> skillroom-hiring and skillroom-interview
    graduate -> skillroom-interview only (never the hiring room, which shows the scoring guide)

  The person must have created their Mattermost account first (first screen of Mattermost).
  You sign in as yourself (an account that is already in both channels).

  Examples (PowerShell):
    .\scripts\add-to-skillroom.ps1 -User kannomaho -Role graduate
    .\scripts\add-to-skillroom.ps1 -User terhemba10 -Role manager -Url http://localhost:60024
#>
param(
  [Parameter(Mandatory = $true)] [string] $User,
  [Parameter(Mandatory = $true)] [ValidateSet("manager", "graduate")] [string] $Role,
  [string] $Url = "http://localhost:60024",
  [string] $Team = "switch",
  [string] $Prefix = "skillroom"
)

$ErrorActionPreference = "Stop"

# Sign in as yourself. The password is sent only to your own local Mattermost.
$me = Read-Host "Your Mattermost username"
$pw = Read-Host "Your Mattermost password" -AsSecureString
$plain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pw))

$login = Invoke-WebRequest -Method Post -Uri "$Url/api/v4/users/login" -ContentType "application/json" `
  -Body (@{ login_id = $me; password = $plain } | ConvertTo-Json) -UseBasicParsing
$headers = @{ Authorization = "Bearer $($login.Headers['Token'])" }

$teamObj = Invoke-RestMethod -Uri "$Url/api/v4/teams/name/$Team" -Headers $headers
$target  = Invoke-RestMethod -Uri "$Url/api/v4/users/username/$User" -Headers $headers

# Make sure the person is on the team first.
try {
  Invoke-RestMethod -Method Post -Uri "$Url/api/v4/teams/$($teamObj.id)/members" -Headers $headers `
    -ContentType "application/json" -Body (@{ team_id = $teamObj.id; user_id = $target.id } | ConvertTo-Json) | Out-Null
} catch { }

$channels = if ($Role -eq "manager") { @("$Prefix-hiring", "$Prefix-interview") } else { @("$Prefix-interview") }

foreach ($name in $channels) {
  $ch = Invoke-RestMethod -Uri "$Url/api/v4/teams/$($teamObj.id)/channels/name/$name" -Headers $headers
  Invoke-RestMethod -Method Post -Uri "$Url/api/v4/channels/$($ch.id)/members" -Headers $headers `
    -ContentType "application/json" -Body (@{ user_id = $target.id } | ConvertTo-Json) | Out-Null
  Write-Host "Added $User to $name"
}

Write-Host "Done. $User should refresh Mattermost (F5) to see the channels."
