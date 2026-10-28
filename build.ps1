#requires -Version 5.1
<#
    Build the reference report (sample/main.tex) and drop the PDF next to it.
    Usage:
        .\build.ps1            build
        .\build.ps1 -Clean     remove build artefacts first
#>
[CmdletBinding()]
param(
    [switch]$Clean
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$sample = Join-Path $root 'sample'

if (-not (Get-Command latexmk -ErrorAction SilentlyContinue)) {
    throw 'latexmk was not found on PATH. Install a TeX distribution (TeX Live or MiKTeX) first.'
}

Push-Location $sample
try {
    if ($Clean) {
        & latexmk -C main.tex | Out-Null
    }
    & latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex
    if ($LASTEXITCODE -ne 0) {
        throw "latexmk failed with exit code $LASTEXITCODE. See sample/main.log."
    }
    $pdf = Join-Path $sample 'main.pdf'
    if (-not (Test-Path $pdf)) { throw 'main.pdf was not produced.' }
    $pages = (Select-String -Path (Join-Path $sample 'main.log') -Pattern 'Output written.*\((\d+) page' |
              Select-Object -First 1).Matches.Groups[1].Value
    Write-Host "built: $pdf${($pages ? " ($pages pages)" : '')}"
}
finally {
    Pop-Location
}
