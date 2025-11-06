param(
    [string]$Command,
    [string]$RuntimeHint = "auto"
)

function Get-RuntimeEnvironment {
    $os = $PSVersionTable.Platform
    $shell = Split-Path -Leaf $PROFILE.CurrentUserAllHosts

    return @{
        OS = $os
        Shell = $shell
        IsWindows = $PSVersionTable.OS -match "Windows"
        IsPowerShell = $PSVersionTable.PSVersion.Major -ge 7
    }
}

function Initialize-AgentRuntime {
    $env = Get-RuntimeEnvironment

    if ($env.IsWindows) {
        Write-Host "[✓] Runtime: PowerShell Core on Windows"
        Set-Alias -Name bash -Value "wsl.exe" -Scope Global -Force -ErrorAction SilentlyContinue
    } else {
        Write-Host "[✓] Runtime: PowerShell on $($env.OS)"
    }

    return $true
}

function Invoke-AgentCommand {
    param(
        [string]$Command,
        [string]$RuntimeHint = "auto"
    )

    if ($RuntimeHint -eq "bash" -or -not $env:IsWindows) {
        # Execute via bash for Unix-like systems
        bash -c $Command
    } else {
        # Execute via PowerShell
        Invoke-Expression $Command
    }
}

# Main execution
Initialize-AgentRuntime
if ($Command) {
    Invoke-AgentCommand -Command $Command -RuntimeHint $RuntimeHint
}
