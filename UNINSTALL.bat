@echo off
rem Restores the original lighting of Coast. Double-click me.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0installer\install.ps1" -Uninstall
