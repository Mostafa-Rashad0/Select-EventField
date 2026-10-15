# Select-EventField

A reusable PowerShell helper for extracting named fields from Windows Event Logs. The setup script installs `Select-EventField` in your PowerShell profile so you can reuse it across investigations and Windows VMs.

## Quick Installation

Run these commands in **PowerShell**, in order.

### 1. Download the setup script

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Mostafa-Rashad0/Select-EventField/main/Setup-EventField.ps1" -OutFile "$HOME\Desktop\Setup-EventField.ps1"
```

### 2. Allow scripts for this session only

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

This setting applies only to the current PowerShell process. If your organization manages execution policy through Group Policy, follow its approved process instead of trying to bypass it.

### 3. Run the setup script

```powershell
& "$HOME\Desktop\Setup-EventField.ps1"
```

### 4. Load the profile and verify

```powershell
. $PROFILE
Get-Command Select-EventField
```

If `Get-Command` displays `Select-EventField`, the function is available in the current session. The profile should load automatically in new sessions for the same user and PowerShell host.

> **Note:** Network access, repository contents, profile restrictions, or organizational policy may prevent installation.

## Usage

### Extract fields from Sysmon Event ID 9

```powershell
Get-WinEvent -Path "C:\path\Investigation-1.evtx" `
    -FilterXPath '*/System/EventID=9' |
Select-EventField -Fields Image, Device
```

### Extract registry information from Sysmon Event ID 13

```powershell
Get-WinEvent -Path "C:\path\Investigation-1.evtx" `
    -FilterXPath '*/System/EventID=13' |
Select-EventField -Fields Image, TargetObject, Details
```

Replace the example path with the actual `.evtx` path. Field names must match the names in the event XML.

## Profile Management

Show the profile path:

```powershell
$PROFILE
```

Open the profile:

```powershell
notepad $PROFILE
```

Reload it after editing:

```powershell
. $PROFILE
```

The profile is specific to the current user and PowerShell host/version. Run setup separately for other accounts or PowerShell versions where you need the function.

## Troubleshooting

- **The script path cannot be found:** `cd` is for directories, not files. Run the script with `& "$HOME\Desktop\Setup-EventField.ps1"`.
- **Scripts are disabled:** In a permitted environment, run the process-scoped execution-policy command above in the same PowerShell window, then retry. Group Policy may override it.
- **The function is not recognized:** Run `. $PROFILE`, then `Get-Command Select-EventField`.
- **Download fails:** Check network access and confirm `Setup-EventField.ps1` is uploaded to the repository's `main` branch at the URL above.

## Project Structure

```text
Select-EventField/
├── README.md
└── Setup-EventField.ps1
```
