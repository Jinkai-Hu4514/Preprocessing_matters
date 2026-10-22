param(
    [string[]]$RelativePath,
    [switch]$All,
    [string]$BackupRoot = 'F:\temp\Preprocessing_matters',
    [string]$RepositoryRoot = 'E:\py_code\bupt_hjk\sdp_test\My_sdp_test'
)
$ErrorActionPreference = 'Stop'
if (-not $All -and -not $RelativePath) { throw 'Specify -RelativePath (one or more manifest paths), or -All.' }
$repo = [IO.Path]::GetFullPath($RepositoryRoot)
$backup = [IO.Path]::GetFullPath((Join-Path $BackupRoot 'files'))
$manifest = @(Import-Csv -LiteralPath (Join-Path $PSScriptRoot 'deletion_manifest.csv') -Encoding utf8)
$selected = if ($All) { $manifest } else { @($manifest | Where-Object { $_.path -in $RelativePath }) }
if (-not $All) {
    foreach ($requested in $RelativePath) {
        if ($requested -notin $selected.path) { throw "Path not in deletion manifest: $requested" }
    }
}
function Assert-NoLink([string]$Path) {
    $current=$Path
    while ($current) {
        if ((Test-Path -LiteralPath $current) -and ((Get-Item -LiteralPath $current -Force).Attributes -band [IO.FileAttributes]::ReparsePoint)) { throw "Reparse point rejected: $current" }
        $current=[IO.Path]::GetDirectoryName($current)
    }
}
foreach ($entry in $selected) {
    if ([IO.Path]::IsPathRooted($entry.path) -or '..' -in ($entry.path -split '[\\/]')) { throw 'Invalid manifest path' }
    $src=[IO.Path]::GetFullPath((Join-Path $backup $entry.path))
    $dst=[IO.Path]::GetFullPath((Join-Path $repo $entry.path))
    if (-not $src.StartsWith($backup+'\',[StringComparison]::OrdinalIgnoreCase) -or -not $dst.StartsWith($repo+'\',[StringComparison]::OrdinalIgnoreCase)) { throw 'Path outside expected roots' }
    Assert-NoLink $src
    Assert-NoLink $dst
    if ((Get-FileHash -LiteralPath $src -Algorithm SHA256).Hash.ToLowerInvariant() -ne $entry.sha256) { throw "Backup hash mismatch: $($entry.path)" }
    if (Test-Path -LiteralPath $dst) {
        if ((Get-FileHash -LiteralPath $dst -Algorithm SHA256).Hash.ToLowerInvariant() -ne $entry.sha256) { throw "Existing destination differs; refusing overwrite: $($entry.path)" }
    } else {
        New-Item -ItemType Directory -Path ([IO.Path]::GetDirectoryName($dst)) -Force | Out-Null
        Copy-Item -LiteralPath $src -Destination $dst
        if ((Get-FileHash -LiteralPath $dst -Algorithm SHA256).Hash.ToLowerInvariant() -ne $entry.sha256) { throw "Restored hash mismatch: $($entry.path)" }
    }
}
Write-Output "Restored or confirmed $(@($selected).Count) files. Existing different files were not overwritten."
