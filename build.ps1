#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Build the technical reports: pdfLaTeX for English, XeLaTeX for Chinese.

.DESCRIPTION
    Builds both example reports (main-en, main-zh) unless -Job is given. -Job also
    takes any other report name: -Job report builds report.tex. The engine is read
    from the report's own \documentclass options ("zh" means XeLaTeX), so a Chinese
    report can be called anything. If TeX Live is not on PATH, pass -TeXBin or
    install a TeX distribution.

    This script is deliberately ASCII-only: Windows PowerShell 5.1 reads BOM-less
    files in the ANSI code page, and Chinese string literals in such a file break
    the parser. Keep it ASCII if you edit it.

.EXAMPLE
    .\build.ps1

.EXAMPLE
    .\build.ps1 -Job main-zh -Watch

.EXAMPLE
    .\build.ps1 -Job report -Clean

.EXAMPLE
    .\build.ps1 -Clean
#>
[CmdletBinding()]
param(
    # Any report name: 'main-en', 'main-zh', 'starter', or your own file.
    # 'all' builds the two example reports.
    [string]$Job = 'all',

    [switch]$Clean,
    [switch]$Watch,
    [string]$TeXBin = ''
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path

function Resolve-TeXBin {
    param([string]$Hint)

    if ($Hint) {
        if (Test-Path (Join-Path $Hint 'pdflatex.exe')) { return $Hint }
        throw "No pdflatex.exe under '$Hint'."
    }
    $cmd = Get-Command pdflatex -ErrorAction SilentlyContinue
    if ($cmd) { return (Split-Path $cmd.Source) }

    $candidates = @(
        'D:\texlive\2026\bin\windows',
        'C:\texlive\2026\bin\windows',
        'C:\texlive\2025\bin\windows',
        'C:\Program Files\MiKTeX\miktex\bin\x64'
    )
    foreach ($p in $candidates) {
        if (Test-Path (Join-Path $p 'pdflatex.exe')) { return $p }
    }
    throw 'pdflatex not found. Install TeX Live / MiKTeX, or pass -TeXBin <dir>.'
}

function Get-Engine {
    param([string]$Name, [string]$Dir)

    # Decide from the report itself. The class switches to the Chinese pipeline
    # with the "zh" option, and that option is exactly what forces XeLaTeX, so
    # reading it beats guessing from the file name: a Chinese report may be
    # called report.tex, and a file whose name contains "zh" may be English.
    $tex = Join-Path $Dir "$Name.tex"
    if (Test-Path $tex) {
        # Decode as UTF-8 explicitly: Windows PowerShell 5.1 would otherwise read
        # a BOM-less file in the ANSI code page and garble the Chinese text.
        $text = [System.IO.File]::ReadAllText($tex, [System.Text.Encoding]::UTF8)
        if ($text -match '\\documentclass\s*\[([^\]]*)\]') {
            if ($Matches[1] -match '(^|,)\s*zh\s*(,|$)') { return 'xelatex' }
            return 'pdflatex'
        }
    }

    # Fallback for a file without bracketed options; should not happen in practice.
    if ($Name -match 'zh' -or $Name -eq 'report') { return 'xelatex' }
    return 'pdflatex'
}

function Remove-Artifacts {
    param([string]$Name)

    $exts = 'aux', 'bbl', 'blg', 'log', 'out', 'toc', 'lof', 'lot', 'fls',
            'fdb_latexmk', 'synctex.gz', 'pdf'
    foreach ($ext in $exts) {
        $f = "$Name.$ext"
        if (Test-Path $f) { Remove-Item $f -Force }
    }
}

function Show-BuildFailure {
    param([string]$Log)

    if (-not (Test-Path $Log)) { return }
    Write-Host 'Build failed. First errors:' -ForegroundColor Red
    Select-String -Path $Log -Pattern '^!|^\./.*:[0-9]+:' -Context 0, 3 |
        Select-Object -First 4 |
        ForEach-Object { $_.Line; $_.Context.PostContext }
}

function Invoke-Tool {
    param(
        [Parameter(Mandatory)][string]$Tool,
        [string[]]$Arguments = @()
    )

    # Windows PowerShell 5.1 turns anything a native tool writes to stderr into an
    # error record, and with ErrorActionPreference=Stop that aborts the script --
    # latexmk's ordinary progress notes are enough to trigger it. Relax it here and
    # judge success by the exit code instead.
    $old = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        & $Tool @Arguments 2>&1 | ForEach-Object { Write-Host $_ }
        return $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $old
    }
}

$bin = Resolve-TeXBin $TeXBin
$env:Path = "$bin;$env:Path"

$names = if ($Job -eq 'all') { @('main-en', 'main-zh') } else { @($Job) }

if ($Clean) {
    Push-Location $root
    try {
        foreach ($name in $names) {
            if ($name -eq 'starter') {
                Push-Location (Join-Path $root 'starter')
                Remove-Artifacts 'report'
                Get-ChildItem 'sections' -Filter '*.aux' -ErrorAction SilentlyContinue |
                    Remove-Item -Force
                Pop-Location
            } else {
                Remove-Artifacts $name
            }
            Write-Host "[clean] $name" -ForegroundColor DarkGray
        }
    } finally { Pop-Location }
    return
}

if ($Watch -and $names.Count -gt 1) {
    throw 'Watch mode handles one report at a time. Add -Job.'
}

$hasLatexmk = [bool](Get-Command latexmk -ErrorAction SilentlyContinue)

foreach ($name in $names) {
    $workDir = if ($name -eq 'starter') { Join-Path $root 'starter' } else { $root }
    $file = if ($name -eq 'starter') { 'report' } else { $name }
    $engine = Get-Engine $file $workDir

    Push-Location $workDir
    $oldInputs = $env:TEXINPUTS
    try {
        # The starter borrows the class file from the repo root instead of keeping
        # a second copy of it.
        if ($name -eq 'starter') { $env:TEXINPUTS = "$root;$env:TEXINPUTS" }

        if (-not (Test-Path "$file.tex")) { throw "Cannot find $file.tex in $workDir" }

        Write-Host "[build] $name ($engine)" -ForegroundColor Cyan

        if ($hasLatexmk) {
            $mode = if ($engine -eq 'xelatex') { '-xelatex' } else { '-pdf' }
            $lmArgs = @($mode, '-bibtex', '-interaction=nonstopmode',
                        '-halt-on-error', '-file-line-error')
            if ($Watch) { $lmArgs += '-pvc' }
            $lmArgs += "$file.tex"

            $code = Invoke-Tool 'latexmk' $lmArgs
        } else {
            $code = Invoke-Tool $engine @('-interaction=nonstopmode', '-halt-on-error',
                                          '-file-line-error', "$file.tex")
            if ($code -eq 0 -and (Test-Path "$file.aux") -and
                (Select-String -Path "$file.aux" -Pattern '\\bibdata' -Quiet)) {
                Invoke-Tool 'bibtex' @($file) | Out-Null
            }
            if ($code -eq 0) {
                $code = Invoke-Tool $engine @('-interaction=nonstopmode', "$file.tex")
                $code = Invoke-Tool $engine @('-interaction=nonstopmode', "$file.tex")
            }
        }

        if ($code -ne 0) {
            Show-BuildFailure "$file.log"
            exit 1
        }

        if (-not $Watch) {
            $pdf = Get-Item "$file.pdf"
            $size = [math]::Round($pdf.Length / 1KB)
            $pages = ''
            if (Get-Command pdfinfo -ErrorAction SilentlyContinue) {
                $pages = (pdfinfo "$file.pdf" | Select-String '^Pages:') -replace '\s*Pages:\s*', ''
                $pages = " / $pages pages"
            }
            Write-Host ("[ok] {0}.pdf  {1} KB{2}" -f $file, $size, $pages) -ForegroundColor Green
        }
    } finally {
        $env:TEXINPUTS = $oldInputs
        Pop-Location
    }
}
