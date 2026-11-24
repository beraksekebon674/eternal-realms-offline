# Eternal Realms: Offline RPG

An original, early Godot 4 pixel-art RPG prototype. It is not a clone of Lumivara Online.

## Current prototype
- Small top-down meadow
- Player movement (keyboard in desktop testing; basic touch input on mobile)
- Slime enemy and proximity attack
- EXP, levels, gold, and local save file

## Android export
Open this project in Godot 4.4.1, install the matching Android export templates, configure Android SDK/JDK paths, create an Android export preset, then export a debug APK.

The GitHub Actions workflow in `.github/workflows/android.yml` is a starting point and may need adjustment for the Godot export preset and Android signing configuration. A successful workflow run has not yet been verified.
