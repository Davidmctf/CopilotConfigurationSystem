# Filesystem Tools

Utilities for file system operations across platforms.

## Implementation

- **Bash**: `./filesystem.sh`
- **PowerShell**: `./filesystem.ps1`

## Operations

### List Directory
Lists files in a directory.

**Bash**:
```bash
./scripts/filesystem.sh list /path/to/dir
```

**PowerShell**:
```powershell
.\scripts\filesystem.ps1 -Operation List -Path C:\path\to\dir
```

### Read File
Reads file content.

**Bash**:
```bash
./scripts/filesystem.sh read /path/to/file
```

**PowerShell**:
```powershell
.\scripts\filesystem.ps1 -Operation Read -Path C:\path\to\file
```

### Search Files
Searches for files matching a pattern.

**Bash**:
```bash
./scripts/filesystem.sh search "*.md" /path/to/search
```

**PowerShell**:
```powershell
.\scripts\filesystem.ps1 -Operation Search -Pattern "*.md" -Path C:\path\to\search
```

### Write File
Creates or overwrites a file with content.

**Bash**:
```bash
./scripts/filesystem.sh write /path/to/file "content here"
```

**PowerShell**:
```powershell
.\scripts\filesystem.ps1 -Operation Write -Path C:\path\to\file -Content "content here"
```

### Count Files
Counts files in a directory.

**Bash**:
```bash
./scripts/filesystem.sh count /path/to/dir
```

**PowerShell**:
```powershell
.\scripts\filesystem.ps1 -Operation Count -Path C:\path\to\dir
```

## Environment Variables

Use environment variables for cross-platform paths:
- `$env:USERPROFILE` - User home directory (Windows)
- `$HOME` - User home directory (Linux/macOS)
- `$env:USERNAME` - Current username

Example:
```bash
./scripts/filesystem.sh list $HOME/Documents
```

```powershell
.\scripts\filesystem.ps1 -Operation List -Path $env:USERPROFILE\Documents
```
