# Rust Code Raid Counter

A lightweight, always-on-top overlay for code raiding in Rust. Cycle through common 4-digit lock combinations hands-free using global hotkeys without alt-tabbing or managing spreadsheets.

[![Version](https://img.shields.io/badge/Version-v1.0.0-brightgreen.svg)](https://github.com/Welsonnot/rust-code-raider-widget/releases/tag/v1.0.0)
[![Platform](https://img.shields.io/badge/Platform-Windows_x64-blue.svg)](https://github.com/Welsonnot/rust-code-raider-widget)
[![Framework](https://img.shields.io/badge/Made_with-Flutter-02569B.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-PolyForm_Noncommercial-lightgrey.svg)](LICENSE)

<br />

<div align="center">
  <img src="screenshots/Screenshot%202026-10-07%20053113.png" width="460" alt="Rust Code Raid Counter v1.0.0" />
</div>

<br />

## Download (v1.0.0)

Grab the standalone build from the [Releases](https://github.com/Welsonnot/rust-code-raider-widget/releases) page:

**[Download Rust-Code-Raider-v1.0.0-Windows.zip](https://github.com/Welsonnot/rust-code-raider-widget/releases/download/v1.0.0/Rust-Code-Raider-v1.0.0-Windows.zip)**

1. Download and extract the .zip anywhere on your PC.
2. Run Rust Code Raider.exe.
3. Set Rust to **Borderless Windowed** mode so the overlay stays visible over your game.

---

## Features

- **Always-on-Top Mini Overlay**: Sits quietly in the corner of your screen without blocking your crosshair or inventory.
- **Global Hotkeys**: Cycle codes directly while holding your in-game lock menu open. Works even when Rust is focused.
- **Audio Feedback**: Subtle click sound on next/prev and a chime when marked solved, so you can focus on typing without staring at the widget. Can be muted at any time.
- **Multi-Base Tracking**: Save your spot across multiple targets (Base 1, Base 2, etc.). Automatically remembers where you left off between restarts.
- **Ordered Code List**: Comes pre-loaded with the top 10,000 most common Rust code lock combinations ordered by probability.
- **Customizable**: Dark / Light themes, widget scaling from 100% to 200%, custom keybinds, and screen snap presets (Top-Right, Top-Left, Bottom-Right, etc.).

---

## Default Controls

| Key | Action | Notes |
| :--- | :--- | :--- |
| F8 | Next Code | Advances to the next code and plays a click |
| F7 | Previous Code | Steps back one code |
| F9 | Mark Solved | Locks the winning code and plays victory chime |

Hotkeys can be rebound in the Settings menu (gear icon). Supports F-keys, Numpad, and standard navigation keys.

---

## Screenshots

<div align="center">

| Dark Theme | Light Theme |
| :---: | :---: |
| <img src="screenshots/Screenshot%202026-10-07%20053113.png" width="380" /> | <img src="screenshots/Screenshot%202026-10-07%20053120.png" width="380" /> |

<br />

| Solved State | Settings & Keybinds |
| :---: | :---: |
| <img src="screenshots/Screenshot%202026-10-07%20053129.png" width="380" /> | <img src="screenshots/Screenshot%202026-10-07%20053138.png" width="380" /> |

</div>

---

## Anti-Cheat / Safety Note

**Will this trigger Easy Anti-Cheat (EAC) or get you banned?**

No. This tool is completely external and acts just like Discord or OBS overlay:
- Does not inject into RustClient.exe.
- Does not read or write game memory.
- Does not hook into the DirectX or graphics pipeline.
- Does not modify game files or send automated keystrokes into the game (it does not auto-type codes for you; you enter the numbers manually).

It is simply a standalone Windows desktop app that registers standard global hotkeys via the Windows API.

---

## Custom Code Lists

The app loads codes from code.txt located in the same directory as the executable. 

If you want to use your own custom dictionary, simply replace or edit code.txt with one 4-digit code per line:

`	ext
1234
1111
0000
1212
...
`

---

## Building from Source

If you want to compile or modify the application yourself:

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install/windows) (3.9.0 or newer)
- Visual Studio with C++ desktop build tools

### Build
```bash
git clone https://github.com/Welsonnot/rust-code-raider-widget.git
cd rust-code-raider-widget

flutter pub get
flutter run -d windows
flutter build windows --release
```

The output executable will be in build\windows\x64\runner\Release\.

---

## License

This project is released under the **PolyForm Noncommercial License 1.0.0**. Free for personal and non-commercial use. See [LICENSE](LICENSE) for details.
