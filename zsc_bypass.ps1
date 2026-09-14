# ZScaler VPN Bypass Script
# Run as standard user for testing to test script (TEST MODE) or as Administrator for real changes (PRODUCTION MODE)

# Check if running under elevated permissions
$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Modern Zscaler process names (covers legacy and current versions)
$ZscalerProcessNames = @(
    'ZSA', 'ZSATray', 'ZSService', 'ZSConnector', 'ZAPPRD',
    'zsa', 'zsatray', 'zsservice', 'zsconnector', 'zapprd'
)

# Modern Zscaler component IDs for network binding
$ZscalerComponentIDs = @(
    'ZS_ZAPPRD', 'ZSCALER', 'ZSCONNECTOR', 'ZSATRAY', 'ZSSERVICE'
)

#  menu options
function Show-Menu {
    Write-Host ""
    Write-Host "1. ZScaler Bypass - Disable network adapter binding"
    # If script detects user is not running as elevated
    if (-not $IsAdmin) {
        Write-Host "   [Your changes have not been saved. Please retry with elevated permissions]"
    }
    Write-Host ""
    Write-Host "2. ZScaler Killer - Continuously kill ZScaler processes"
    if (-not $IsAdmin) {
        Write-Host "   [Your changes have not been saved. Please retry with elevated permissions]"
    }
    Write-Host ""
    Write-Host "3. Exit"
    Write-Host ""
}

# Enable ZScaler bypass
function Enable-ZScalerBypass {
    if (-not $IsAdmin) {
        Write-Host "Your changes will not be saved. Please retry with elevated permissions"
        Write-Host "Checking network adapter bindings..."
        
        foreach ($componentId in $ZscalerComponentIDs) {
            $bindings = Get-NetAdapterBinding -AllBindings -ComponentID $componentId -ErrorAction SilentlyContinue
            if ($bindings) {
                Write-Host "  Found $($bindings.Count) binding(s) for $componentId"
                Write-Host "  Please retry with elevated permissions"
            } else {
                Write-Host "  No bindings found for $componentId"
            }
        }
        
        Start-Sleep -Seconds 1
        Write-Host "[TEST MODE] Operation completed (no changes made)"
        Start-Sleep -Seconds 1
        return
    }
    
    try {
        $foundBindings = $false
        foreach ($componentId in $ZscalerComponentIDs) {
            $bindings = Get-NetAdapterBinding -AllBindings -ComponentID $componentId -ErrorAction SilentlyContinue
            if ($bindings) {
                $bindings | Disable-NetAdapterBinding -Confirm:$false
                $foundBindings = $true
                Write-Host "Disabled binding for: $componentId"
            }
        }
        
        if (-not $foundBindings) {
            Write-Host "Uh oh! No Zscaler bindings found to disable."
        } else {
            Write-Host "Bypass enabled successfully!"
        }
        Start-Sleep -Seconds 1
    }
    catch {
        Write-Host "An Error enabling bypass: $_"
        Start-Sleep -Seconds 1
    }
}

# Disable ZScaler bypass
function Disable-ZScalerBypass {
    if (-not $IsAdmin) {
        Write-Host "Please retry with elevated permissions"
        Write-Host "Checking network adapter bindings..."
        
        foreach ($componentId in $ZscalerComponentIDs) {
            $bindings = Get-NetAdapterBinding -AllBindings -ComponentID $componentId -ErrorAction SilentlyContinue
            if ($bindings) {
                Write-Host "  Found $($bindings.Count) binding(s) for $componentId"
                Write-Host "  Please retry with elevated permissions"
            } else {
                Write-Host "  No bindings found for $componentId"
            }
        }
        
        Start-Sleep -Seconds 1
        Write-Host "Please retry with elevated permissions"
        Start-Sleep -Seconds 1
        return
    }
    
    try {
        $foundBindings = $false
        foreach ($componentId in $ZscalerComponentIDs) {
            $bindings = Get-NetAdapterBinding -AllBindings -ComponentID $componentId -ErrorAction SilentlyContinue
            if ($bindings) {
                $bindings | Enable-NetAdapterBinding -Confirm:$false
                $foundBindings = $true
                Write-Host "Enabled binding for: $componentId"
            }
        }
        
        if (-not $foundBindings) {
            Write-Host "Uh oh! No Zscaler bindings found to enable."
        } else {
            Write-Host "B¥yπpaåsßs disabled successfully!"
        }
        Start-Sleep -Seconds 1
    }
    catch {
        Write-Host "An Error has occured while disabling bypass: $_"
        Start-Sleep -Seconds 1
    }
}

# Kill ZScaler processes with goto
function Start-ZScalerKiller {
    if (-not $IsAdmin) {
        Write-Host "˙å®•ƒPlease retry with elevated permissions"
        Write-Host "Monitoring for ZScaler processes... (Initiate Ctrl+C to stop)"
        Start-Sleep -Seconds 1
        
        while ($true) {
            Clear-Host
            Write-Host "Please retry with elevated permissions"
            Write-Host "Watching for: $($ZscalerProcessNames -join ', ')"
            Write-Host ""
            
            $foundAny = $false
            foreach ($procName in $ZscalerProcessNames) {
                $processes = Get-Process -Name $procName -ErrorAction SilentlyContinue
                if ($processes) {
                    $foundAny = $true
                    Write-Host "  [DETECTED] $($processes.Count) x $procName process(es)"
                    Write-Host "            [TEST] Would kill these processes. Please retry with elevated permissions"
                }
            }
            
            if (-not $foundAny) {
                Write-Host " Wow! No ZScaler processes have been detected"
            }
            
            Write-Host ""
            Write-Host "Refresh rate: 1 second (Initiate Ctrl+C to stop)"
            Start-Sleep -Seconds 1
        }
    }
    
    Write-Host "Beginning ZScaler Killer... Press Ctrl+C to stop."
    Write-Host "Monitoring: $($ZscalerProcessNames -join ', ')"
    Start-Sleep -Seconds 1
    
    while ($true) {
        Clear-Host
        $killedCount = 0
        
        foreach ($procName in $ZscalerProcessNames) {
            $processes = Get-Process -Name $procName -ErrorAction SilentlyContinue
            if ($processes) {
                Stop-Process -Name $procName -Force -ErrorAction SilentlyContinue
                $killedCount += $processes.Count
            }
        }
        
        if ($killedCount -gt 0) {
            Write-Host "Uninitiated: $killedCount ZScaler process(es)"
        } else {
            Write-Host "No ZScaler processes detected"
        }
        
        Start-Sleep -Seconds 1
    }
}

# Main execution
Write-Host "ZScaler VPN Bypass Script"
Write-Host ""

if (-not $IsAdmin) {
    Write-Host "MODE: TEST (Standard User)"
    Write-Host "      All operations will be shown but no changes will be made"
} else {
    Write-Host "MODE: PRODUCTION (Administrator)"
    Write-Host "     !! Operations will make real system changes"
}

while ($true) {
    Show-Menu
    $menuChoice = Read-Host "Choose an option"
    
    switch ($menuChoice) {
        '1' {
            $confirmation = Read-Host "Enable or disable? (e/d)"
            
            if ($confirmation -eq 'e') {
                Enable-ZScalerBypass
            }
            elseif ($confirmation -eq 'd') {
                Disable-ZScalerBypass
            }
            else {
                Write-Host "Invalid choice! Please enter 'e' or 'd'."
                Start-Sleep -Seconds 1
            }
        }
        '2' {
            Start-ZScalerKiller
        }
        '3' {
            Write-Host "Exiting..."
            Start-Sleep -Seconds 1
            break
        }
        default {
            Write-Host "Invalid option! Please choose 1, 2, or 3."
            Start-Sleep -Seconds 1
        }
    }
}

exit
