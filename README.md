# ZScaler Bypass/Killer Script

Modern PowerShell script for bypassing or killing ZScaler with full support for both standard users (Test Mode) and administrators (Production Mode).

## Features

- **Dual-Mode Operation**: Automatically detects privilege level and runs in appropriate mode
- **Standard User Support**: Full UI/UX testing without admin rights
- **Modern Zscaler Compatibility**: Supports legacy and current Zscaler versions
- **Multiple Process Targets**: Handles all known Zscaler process names
- **Multiple Component IDs**: Works with various Zscaler network binding components

## Requirements

### Test Mode (Standard User)
- No special privileges required
- Can be run by any user to test the interface and workflow
- Shows real-time process detection and component scanning
- No system changes are made

### Production Mode (Administrator)
- Administrator privileges required
- Performs actual Zscaler bypass and process termination
- Makes permanent changes to network adapter bindings

## Options

The script provides 3 options:

### 1. ZScaler Bypass
Disables/enables binding to network adapters for Zscaler components.
- **Duration**: Permanent (works even after closing the script)
- **Test Mode**: Scans all component IDs, shows what would be changed
- **Production Mode**: Actually disables/enables network bindings

### 2. ZScaler Killer
Continuously monitors and kills Zscaler processes.
- **Duration**: Only while the script is running
- **Test Mode**: Real-time process monitoring, shows detected processes
- **Production Mode**: Actively terminates Zscaler processes

### 3. Exit
Close the script

## Supported Zscaler Components

### Process Names (Killer Mode)
- `ZSA` - Legacy Zscaler Agent
- `ZSATray` - Zscaler Agent Tray
- `ZSService` - Zscaler Service
- `ZSConnector` - Zscaler Connector
- `ZAPPRD` - Zscaler App Protection Daemon
- Lowercase variants of all above

### Network Component IDs (Bypass Mode)
- `ZS_ZAPPRD` - Legacy component
- `ZSCALER` - Generic Zscaler
- `ZSCONNECTOR` - Zscaler Connector
- `ZSATRAY` - Zscaler Tray
- `ZSSERVICE` - Zscaler Service

## Usage

### Running as Standard User (Test Mode)
Simply execute the script without elevation:
```powershell
.\zsc_bypass.ps1
```

The script automatically runs in **TEST MODE** when executed as a standard user:
- All menu options are accessible
- Real process/component detection is performed
- Detailed output shows what would happen in production
- No system changes are made
- Perfect for testing the UI flow and understanding the script behavior

### Running as Administrator (Production Mode)
Right-click on the script and select "Run with PowerShell" as Administrator, or run from an elevated PowerShell prompt:
```powershell
Start-Process powershell -Verb RunAs -File ".\zsc_bypass.ps1"
```

In this mode, the script performs actual Zscaler bypass/killer operations.

### Execution Policy
If you encounter execution policy errors, run the following command in PowerShell (no admin privileges needed):
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Alternative: Simple Killer (Batch File)

If you have admin privileges but PowerShell is blocked, use `simple_killer.bat`:
```batch
simple_killer.bat
```
This batch file kills Zscaler processes in a loop and must run continuously.

## Notes

- The script automatically detects whether it's running as admin or standard user
- Test Mode provides full visibility into what the script does without making changes
- Production Mode should only be used when you intend to actually bypass Zscaler
- All banner art and visual elements have been preserved
- Console appearance is optimized for readability
- Error handling prevents crashes on non-interactive systems
