@echo off
title Rust Code Raider
if exist "Rust Code Raider\Rust Code Raider.exe" (
    echo Starting Rust Code Raider...
    start "" "Rust Code Raider\Rust Code Raider.exe"
) else if exist "build\windows\x64\runner\Release\rust_code_raid_counter.exe" (
    echo Starting Rust Code Raider (Release)...
    start "" "build\windows\x64\runner\Release\rust_code_raid_counter.exe"
) else (
    echo Building and running via Flutter...
    flutter run -d windows
)
