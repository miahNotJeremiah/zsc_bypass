# Zscaler Bypass Research Tool

> **⚠️ WARNING: SECURITY RESEARCH ONLY**  
> This tool is intended **strictly for educational and security research purposes** on systems you own or have explicit written authorization to test.  
> - **Unauthorized use** against corporate, government, or third-party systems is illegal and violates computer misuse laws (e.g., CFAA in the US).  
> - Disabling security controls like Zscaler may expose systems to threats, violate organizational policies, and trigger legal consequences.  
> - The authors assume **no liability** for misuse, damages, or legal actions resulting from the use of this tool.  
> - Use only in isolated lab environments or with explicit written permission from system owners.

---

## Overview

This PowerShell script demonstrates how Zscaler Client Connector components interact with the Windows network stack and process model. It is designed for **security researchers** studying:
- Windows network binding mechanisms
- Security product process protection
- Privilege separation in endpoint security tools
- Windows 11 security architecture limitations

### Key Capabilities
- **Test Mode**: Runs as a standard user to simulate all operations safely (no system changes)
- **Production Mode**: Executes actual network binding modifications and process monitoring when run as Administrator
- **Modern Zscaler Support**: Compatible with current Zscaler Client Connector versions on Windows 11

---

## How It Works

### 1. Test Mode (Standard User)
When executed without administrative privileges:
- Scans registered network component IDs used by Zscaler
- Monitors running Zscaler-related processes in real-time
- Simulates disable/enable operations with detailed output
- **Makes no actual changes** to the system
- Ideal for UI/UX flow testing and understanding script behavior

### 2. Production Mode (Administrator)
When executed with elevated privileges:
- Directly modifies network binding states via Windows Registry
- Actively monitors and terminates Zscaler processes
- Bypasses Zscaler network interception temporarily
- Requires disabling Windows Defender Real-Time Protection first

---

## Step-by-Step Function Breakdown

### `Set-ConsoleAppearance`
**Purpose**: Configures the console window for consistent output display.  
**Actions**:
1. Sets console title to "Zscaler Bypass Research"
2. Adjusts window size to 80x30 characters
3. Positions window at screen coordinates (100,100)
4. Silently fails if running in non-interactive environments (e.g., CI/CD pipelines)

### `Show-Banner`
**Purpose**: Displays tool identification and current execution mode.  
**Actions**:
1. Prints tool name and version
2. Detects administrative privileges
3. Shows either "[TEST MODE]" or "[PRODUCTION MODE]" indicator
4. Warns about simulation-only behavior in Test Mode

### `Show-Menu`
**Purpose**: Presents interactive options to the user.  
**Actions**:
1. Displays three numbered options:
   - Option 1: Enable bypass (disable network bindings)
   - Option 2: Disable bypass (restore network bindings)
   - Option 3: Start continuous process monitor
2. Prompts for user selection
3. Validates input and loops until valid choice entered

### `Enable-ZScalerBypass`
**Purpose**: Disables Zscaler network filtering components.  
**Actions**:
1. Defines list of Zscaler component IDs:
   - `ZS_ZAPPRD`: Core application protection driver
   - `ZSCALER`: Primary network filter
   - `ZSCONNECTOR`: Client connector service binding
   - `ZSATRAY`: System tray component binding
   - `ZSSERVICE`: Background service binding
2. **In Test Mode**: 
   - Checks registry existence of each component
   - Reports what *would* be changed (Registry path, Current Value, New Value)
   - No actual registry modifications performed
3. **In Production Mode**:
   - Sets `RefCount` DWORD value to `0` for each component
   - Forces Windows to unload the network filter drivers
   - Requires admin rights to modify `HKLM\SYSTEM\CurrentControlSet\Services\...`

### `Disable-ZScalerBypass`
**Purpose**: Restores Zscaler network filtering components.  
**Actions**:
1. Uses same component ID list as Enable function
2. **In Test Mode**:
   - Simulates restoration process
   - Shows expected registry changes (Value: `2` = Auto-start)
3. **In Production Mode**:
   - Deletes custom `RefCount` values
   - Allows Windows Service Control Manager to restore default binding states
   - Triggers automatic re-initialization of Zscaler filters

### `Start-ZScalerKiller`
**Purpose**: Continuously monitors and terminates Zscaler processes.  
**Actions**:
1. Defines target process names:
   - `ZSA`, `ZSATray`, `ZSService`, `ZSConnector`, `ZAPPRD`
   - Lowercase variants: `zsa`, `zsatray`, etc.
2. Enters infinite loop with 2-second intervals
3. **In Test Mode**:
   - Detects running processes matching names
   - Reports PID and executable path
   - Logs "Would terminate" messages without killing
4. **In Production Mode**:
   - Forcefully terminates matching processes using `Stop-Process -Force`
   - Immediately restarts monitoring after termination
   - Continues until user presses Ctrl+C

### `Main Script Flow`
**Purpose**: Orchestrates tool execution.  
**Actions**:
1. Calls `Set-ConsoleAppearance` (non-fatal if fails)
2. Displays banner with mode detection
3. Enters menu loop:
   - Shows options via `Show-Menu`
   - Executes selected function
   - Pauses for user acknowledgment after operations
   - Exits cleanly on user request

---

## Usage Instructions

### Prerequisites
- Windows 10/11 with PowerShell 5.1+
- Zscaler Client Connector installed (for meaningful results)
- **Administrator rights** required for Production Mode
- Windows Defender Real-Time Protection disabled (Production Mode only)

### Running the Script

#### As Standard User (Test Mode)
```powershell
# No elevation needed - safe simulation
.\zsc_bypass.ps1
```
**Expected Behavior**:
- All operations simulated with detailed output
- No system modifications occur
- Perfect for testing UI flow and understanding logic

#### As Administrator (Production Mode)
```powershell
# Right-click PowerShell > "Run as Administrator"
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\zsc_bypass.ps1
```
**Expected Behavior**:
- Actual network bindings modified
- Processes actively terminated
- Zscaler protection temporarily bypassed

### Disabling Windows Defender (Required for Production Mode)
```powershell
# Run in separate Admin PowerShell session
Set-MpPreference -DisableRealtimeMonitoring $true
```
> ⚠️ Re-enable after research: `Set-MpPreference -DisableRealtimeMonitoring $false`

---

## Technical Details

### Supported Zscaler Components
| Component ID | Purpose | Registry Path |
|--------------|---------|---------------|
| `ZS_ZAPPRD` | Application protection driver | `HKLM\SYSTEM\CurrentControlSet\Services\ZS_ZAPPRD\NetworkProvider` |
| `ZSCALER` | Primary network filter | `HKLM\SYSTEM\CurrentControlSet\Services\ZSCALER\NetworkProvider` |
| `ZSCONNECTOR` | Client connector binding | `HKLM\SYSTEM\CurrentControlSet\Services\ZSCONNECTOR\NetworkProvider` |
| `ZSATRAY` | System tray integration | `HKLM\SYSTEM\CurrentControlSet\Services\ZSATRAY\NetworkProvider` |
| `ZSSERVICE` | Background service | `HKLM\SYSTEM\CurrentControlSet\Services\ZSSERVICE\NetworkProvider` |

### Target Processes
- `ZSA.exe` / `zsa.exe`: Core agent
- `ZSATray.exe` / `zsatray.exe`: System tray application
- `ZSService.exe` / `zsservice.exe`: Background service host
- `ZSConnector.exe` / `zsconnector.exe`: Network connector
- `ZAPPRD.exe` / `zapprd.exe`: Application protection module

### Windows Security Limitations
Standard users cannot perform Production Mode actions due to:
1. **Registry Permissions**: `HKLM\SYSTEM` requires `SeTakeOwnershipPrivilege`
2. **Process Termination**: Protected Process Light (PPL) blocks non-admin kills
3. **Service Control**: SC Manager denies binding changes to non-admins
4. **Driver Loading**: Kernel-mode drivers require signed binaries and admin approval

---

## Ethical Guidelines
1. **Authorization First**: Never test on systems without explicit written permission
2. **Isolated Environments**: Prefer VMs or dedicated lab machines
3. **Minimal Impact**: Use Test Mode whenever possible
4. **Restore Systems**: Always run "Disable Bypass" after research
5. **Document Everything**: Record findings for defensive improvements

---

## Disclaimer
This tool exposes inherent limitations in Windows privilege separation when security products rely solely on OS-level protections. Organizations should implement defense-in-depth strategies including:
- Application allowlisting
- Behavioral monitoring
- Network segmentation
- Privileged access management

The existence of this tool does not indicate a vulnerability in Zscaler itself, but rather demonstrates the importance of layered security controls.

---

## License
Provided for educational purposes only. No warranty expressed or implied.
