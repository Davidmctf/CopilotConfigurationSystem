<#
.SYNOPSIS
    Filesystem operations wrapper for PowerShell
.DESCRIPTION
    Provides file system utilities for prompts and instructions
.EXAMPLE
    .\filesystem.ps1 -Operation List -Path .
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('List', 'Read', 'Search', 'Write', 'Count')]
    [string]$Operation = 'List',
    
    [Parameter(Mandatory=$false)]
    [string]$Path = '.',
    
    [Parameter(Mandatory=$false)]
    [string]$Pattern = '*',
    
    [Parameter(Mandatory=$false)]
    [string]$Content = ''
)

function List-Directory {
    param([string]$Path)
    Get-ChildItem -Path $Path -ErrorAction SilentlyContinue | Select-Object Name, Mode
}

function Read-FileContent {
    param([string]$FilePath)
    if (Test-Path $FilePath) {
        Get-Content -Path $FilePath
    } else {
        Write-Error "File not found: $FilePath"
    }
}

function Search-Files {
    param([string]$Pattern, [string]$Path)
    Get-ChildItem -Path $Path -Filter $Pattern -Recurse -ErrorAction SilentlyContinue | Select-Object FullName
}

function Write-FileContent {
    param([string]$FilePath, [string]$Content)
    $Directory = Split-Path -Parent $FilePath
    if (-not (Test-Path $Directory)) {
        New-Item -ItemType Directory -Path $Directory -Force | Out-Null
    }
    $Content | Set-Content -Path $FilePath
    Write-Host "File written: $FilePath"
}

function Count-Files {
    param([string]$Path)
    (Get-ChildItem -Path $Path -File -Recurse -ErrorAction SilentlyContinue).Count
}

# Main dispatcher
switch ($Operation) {
    'List'   { List-Directory -Path $Path }
    'Read'   { Read-FileContent -FilePath $Path }
    'Search' { Search-Files -Pattern $Pattern -Path $Path }
    'Write'  { Write-FileContent -FilePath $Path -Content $Content }
    'Count'  { Count-Files -Path $Path }
}
