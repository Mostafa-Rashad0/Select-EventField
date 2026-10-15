
# Setup-EventField.ps1
# Creates a PowerShell profile and installs Select-EventField.

$ErrorActionPreference = 'Stop'

try {
    # Get the profile for the current PowerShell host and user
    $profilePath = $PROFILE

    # Create the profile directory if it doesn't exist
    $profileDirectory = Split-Path -Parent $profilePath

    if (-not (Test-Path -LiteralPath $profileDirectory)) {
        New-Item -Path $profileDirectory -ItemType Directory -Force |
            Out-Null
    }

    # Create the profile file if it doesn't exist
    if (-not (Test-Path -LiteralPath $profilePath)) {
        New-Item -Path $profilePath -ItemType File -Force |
            Out-Null
    }

    # Function to install
    $functionCode = @'

function Select-EventField {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Diagnostics.Eventing.Reader.EventLogRecord]$Event,

        [Parameter(Mandatory)]
        [string[]]$Fields
    )

    process {
        $xml = [xml]$Event.ToXml()
        $data = @{}

        foreach ($item in $xml.Event.EventData.Data) {
            $data[[string]$item.Name] = [string]$item.'#text'
        }

        $result = [ordered]@{
            TimeCreated = $Event.TimeCreated
            EventID     = $Event.Id
        }

        foreach ($field in $Fields) {
            $result[$field] = $data[$field]
        }

        [PSCustomObject]$result
    }
}
'@

    # Avoid installing the function more than once
    $profileContent = Get-Content -LiteralPath $profilePath -Raw

    if ($profileContent -match 'function\s+Select-EventField\b') {
        Write-Host "Select-EventField already exists in the profile." `
            -ForegroundColor Yellow
    }
    else {
        Add-Content -LiteralPath $profilePath -Value $functionCode
        Write-Host "Select-EventField installed successfully." `
            -ForegroundColor Green
    }

    # Load the updated profile into this session
    . $profilePath

    Write-Host "`n========== SETUP COMPLETE ==========" `
        -ForegroundColor Cyan

    Write-Host "Profile file: $profilePath"
    Write-Host "Profile directory: $profileDirectory"

    Write-Host "`nTo open and edit the profile:"
    Write-Host "  notepad `"$profilePath`""

    Write-Host "`nTo reload changes in the current session:"
    Write-Host "  . `"$profilePath`""

    Write-Host "`nTo verify the function:"
    Write-Host "  Get-Command Select-EventField"

    Write-Host "`nTo use the function:"
    Write-Host '  Get-WinEvent -Path "C:\path\Investigation-1.evtx" -FilterXPath "*/System/EventID=9" | Select-EventField -Fields Image, Device'
}
catch {
    Write-Error "Setup failed: $($_.Exception.Message)"
    exit 1
}
