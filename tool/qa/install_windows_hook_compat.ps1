<#
Install a user-local shell bridge and launch Orca with a private PATH prefix.
No plugin commands, scripts, trust hashes, or machine/user PATH are changed.
Existing Orca Desktop/Start Menu/pinned shortcuts are backed up then pointed at
the launcher. A running Orca is left running; its current arg0 is also repaired.
#>
[CmdletBinding()]
param(
    [string]$OrcaExe = "$env:LOCALAPPDATA\Programs\orca\Orca.exe"
)
$ErrorActionPreference = 'Stop'
$compatRoot = Join-Path $env:USERPROFILE '.codex\windows-hook-compat'
$compatBin = Join-Path $compatRoot 'bin'
$pythonExe = (& python -c 'import sys; print(sys.executable)').Trim()
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $pythonExe)) { throw 'Working Python is required' }
$gitBash = Join-Path $env:ProgramFiles 'Git\bin\bash.exe'
$gitSh = Join-Path $env:ProgramFiles 'Git\usr\bin\sh.exe'
foreach ($requiredPath in @($OrcaExe, $gitBash, $gitSh)) {
    if (-not (Test-Path -LiteralPath $requiredPath -PathType Leaf)) { throw "Missing: $requiredPath" }
}
$pluginBase = Join-Path $env:USERPROFILE '.codex\plugins\cache\claude-plugins-official'
$scripts = @()
foreach ($entry in @(@('security-guidance', 'hooks\sg-python.sh'), @('claude-security', 'hooks\hooks.sh'))) {
    $pluginDir = Join-Path $pluginBase $entry[0]
    if (Test-Path -LiteralPath $pluginDir) {
        foreach ($versionDir in Get-ChildItem -LiteralPath $pluginDir -Directory) {
            $script = Join-Path $versionDir.FullName $entry[1]
            if (Test-Path -LiteralPath $script -PathType Leaf) { $scripts += $script }
        }
    }
}
if ($scripts.Count -eq 0) { throw 'Expected installed plugin scripts were not found' }
New-Item -ItemType Directory -Path $compatBin -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'windows_hook_compat.py') -Destination (Join-Path $compatRoot 'windows_hook_compat.py')
@{bash=$gitBash; sh=$gitSh; plugin_scripts=$scripts} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $compatRoot 'config.json') -Encoding UTF8
# Python's JSON reader accepts the UTF-8 BOM via utf-8-sig below.
$configPath = Join-Path $compatRoot 'config.json'
[IO.File]::WriteAllText($configPath, [IO.File]::ReadAllText($configPath), (New-Object Text.UTF8Encoding($false)))
foreach ($shellName in @('bash', 'sh')) {
    $cmdText = "@echo off`r`n`"$pythonExe`" -X utf8 `"$compatRoot\windows_hook_compat.py`" $shellName %*`r`nexit /b %errorlevel%`r`n"
    [IO.File]::WriteAllText((Join-Path $compatBin "$shellName.cmd"), $cmdText, (New-Object Text.UTF8Encoding($false)))
}
# Git Bash needs an extensionless Python launcher to avoid Windows Store stubs.
$posixPython = $pythonExe.Replace('\', '/').Replace("'", "'\''")
$pythonShim = "#!/bin/sh`nexec '$posixPython' -X utf8 `"`$@`"`n"
[IO.File]::WriteAllText((Join-Path $compatBin 'python3'), $pythonShim, (New-Object Text.UTF8Encoding($false)))
$pythonWindowExe = Join-Path (Split-Path -Parent $pythonExe) 'pythonw.exe'
if (-not (Test-Path -LiteralPath $pythonWindowExe -PathType Leaf)) { throw 'pythonw.exe is required for the Orca shortcut' }
$jsonExe = ConvertTo-Json -InputObject $OrcaExe -Compress
$jsonBin = ConvertTo-Json -InputObject $compatBin -Compress
$launch = @"
import os
import subprocess
import sys
env = os.environ.copy()
key = next((k for k in env if k.casefold() == 'path'), 'PATH')
env[key] = $jsonBin + ';' + env.get(key, '')
if sys.argv[1:] == ['--check']:
    raise SystemExit(subprocess.call([env.get('COMSPEC', 'cmd.exe'), '/d', '/c', 'bash --version'], env=env))
subprocess.Popen([$jsonExe, *sys.argv[1:]], env=env)
"@
$launcherPath = Join-Path $compatRoot 'Launch-Orca.pyw'
[IO.File]::WriteAllText($launcherPath, $launch, (New-Object Text.UTF8Encoding($false)))
$shortcutRoots = @(
    [Environment]::GetFolderPath('Desktop'),
    (Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs'),
    (Join-Path $env:APPDATA 'Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar')
)
$wscriptShell = New-Object -ComObject WScript.Shell
$backups = Join-Path $compatRoot 'shortcut-backups'
New-Item -ItemType Directory -Path $backups -Force | Out-Null
$changed = @()
foreach ($shortcutRoot in $shortcutRoots) {
    if (-not (Test-Path -LiteralPath $shortcutRoot)) { continue }
    foreach ($link in Get-ChildItem -LiteralPath $shortcutRoot -Filter '*Orca*.lnk' -File) {
        $shortcut = $wscriptShell.CreateShortcut($link.FullName)
        if ($shortcut.TargetPath -ne $OrcaExe) { continue }
        $backupName = ([Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($link.FullName))).Replace('/', '_').Replace('+', '-') + '.lnk'
        $backup = Join-Path $backups $backupName
        if (-not (Test-Path -LiteralPath $backup)) { Copy-Item -LiteralPath $link.FullName -Destination $backup }
        $priorArgs = $shortcut.Arguments
        $shortcut.TargetPath = $pythonWindowExe
        $shortcut.Arguments = "`"$launcherPath`"" + $(if ($priorArgs) { " $priorArgs" } else { '' })
        $shortcut.IconLocation = "$OrcaExe,0"
        $shortcut.Save()
        $changed += @{path=$link.FullName; backup=$backup}
    }
}
if ($changed.Count -gt 0) {
    $changed | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $compatRoot 'shortcuts.json') -Encoding UTF8
}
# The current process snapshot already prefixes this transient arg0 directory.
# Repair only that exact existing directory, never enumerate/modify other sessions.
$currentArg0 = @($env:Path.Split(';') | Where-Object {
    $_ -match '\\codex-runtime-home\\home\\tmp\\arg0\\codex-arg0[^\\]+$' -and (Test-Path -LiteralPath $_ -PathType Container)
})
foreach ($arg0Path in $currentArg0) {
    foreach ($shim in @('bash.cmd', 'sh.cmd', 'python3')) {
        Copy-Item -LiteralPath (Join-Path $compatBin $shim) -Destination (Join-Path $arg0Path $shim)
    }
}
Write-Output "Installed private bridge: $compatRoot"
Write-Output "Updated Orca shortcuts: $($changed.Count); repaired active runtime directories: $($currentArg0.Count)"
Write-Output 'A running Orca was preserved. Future launches through the updated shortcuts inherit the private shell bridge.'
