@echo off
REM Wrapper that bypasses the PowerShell execution policy (unsigned scripts are
REM blocked by default on Windows). Forwards every argument to build.ps1.
REM
REM Usage:
REM   build.cmd                  build both example reports
REM   build.cmd -Job main-zh     Chinese report only
REM   build.cmd -Clean
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0build.ps1" %*
if errorlevel 1 exit /b 1
