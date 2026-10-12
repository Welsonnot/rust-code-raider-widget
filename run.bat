@echo off
title Rust Code Raider
cd /d "%~dp0"

if exist "build\windows\x64\runner\Release\rust_code_raid_counter.exe" (
    if exist "Rust Code Raider\" (
        copy /Y "build\windows\x64\runner\Release\rust_code_raid_counter.exe" "Rust Code Raider\Rust Code Raider.exe" >nul 2>&1
        xcopy /E /I /Y "build\windows\x64\runner\Release\data" "Rust Code Raider\data" >nul 2>&1
    )
    echo Starting Rust Code Raider (Release)...
    start "" "build\windows\x64\runner\Release\rust_code_raid_counter.exe"
) else if exist "Rust Code Raider\Rust Code Raider.exe" (
    echo Starting Rust Code Raider...
    start "" "Rust Code Raider\Rust Code Raider.exe"
) else (
    echo Building and running via Flutter...
    flutter run -d windows
)
