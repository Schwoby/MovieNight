# Backyard Movie Night Scripts

This repository contains a set of PowerShell scripts designed to automate an outdoor movie night experience.
They handle playlist creation, video playback, lighting controls, intermissions, and video formatting for consistent display.

---

## 📂 Files Overview

### 1. `_OutsideMovieNightScript.ps1`
Main automation script for running the movie night.

- **Lighting Control Hooks**
  - `$CurlRun1`, `$CurlRun2`, `$CurlRun3Option1`, `$CurlRun3Option2` are placeholders for Home Assistant (or other smart lighting) webhooks.
  - They can be defined in `Variables.ps1` to control lights before, during, and after movies.

- **Variable Loading**
  - Loads external settings from `Variables.ps1`.

- **Window Management**
  - Minimizes all windows before playback using `Shell.Application`.

- **Movie & Clip Selection**
  - Reads lists of intro, intermission, and end clips from text files.
  - Randomly selects one clip from each category if available.
  - Builds a playlist with:
    - An intro clip (optional)
    - The main movie
    - Either an intermission clip or end clip depending on movie position

- **Media Player Integration**
  - Launches `mpc-hc64` with a playlist in fullscreen mode.
  - Calculates total playlist duration by reading metadata from the files.
  - Adjusts sleep timers with an offset (`$MovieTimeOffSet`) to trigger lighting events before playback ends.
  - Waits for MPC-HC to fully exit before continuing.

- **Intermission Handling**
  - Optionally plays a Marine Aquarium screensaver between movies.
  - Runs `$CurlRun3` (lighting control) at intermission or final movie.

- **Error Handling**
  - Displays error messages if a movie fails to load or process.
  - Pauses for user input if a fatal error occurs.

- **Shutdown Option**
  - If `$EndOfNightShutDown` is set, the system shuts down after the last movie.

---

### 2. `Variables.ps1`
Central configuration file for the movie night scripts.

- **Folder Paths**
  - `$rootFolder` → Main directory (`D:\MovieNight`)
  - `$movieFolder` → Movies folder
  - `$clipsFolder` → Clips folder
  - Paths for text lists: `MovieList.txt`, `_IntroClips.txt`, `_IntermissionClips.txt`, `_EndClips.txt`

- **Playback Timing**
  - `$MovieTimeOffSet` → Time (in seconds) before movie end to trigger `$CurlRun2`
  - `$Intermission` → Duration of intermission (in seconds)

- **Optional Shutdown**
  - `$EndOfNightShutDown` can be uncommented to enable auto-shutdown after all movies.

- **Lighting Controls**
  - Example curl webhooks are provided for integration with Home Assistant:
    - `$CurlRun1` → Pre-movie lighting
    - `$CurlRun2` → Post-movie lighting
    - `$CurlRun3Option1` → End-of-night lights off
    - `$CurlRun3Option2` → Intermission lights

---

### 3. `MovieList.txt`
These are plain text files that define the playlist content for the movie night. Each file should list one filename per line.

- **`MovieList.txt`** → The main list of movies to be played in order. *(Required: file must exist and contain at least one entry)*

---

### 4. `_IntroClips.txt`, `_IntermissionClips.txt`, `_EndClips.txt`
These are plain text files that define the playlist content for the movie night. Each file should list one filename per line.

- **`_IntroClips.txt`** → A list of optional intro clips shown before each movie. *(Required as a text file, but video entries inside are optional)*
- **`_IntermissionClips.txt`** → A list of optional intermission clips shown between movies. *(Required as a text file, but video entries inside are optional)*
- **`_EndClips.txt`** → A list of optional closing clips shown after the final movie. *(Required as a text file, but video entries inside are optional)*

⚠️ Even if you don’t plan to use intro, intermission, or end clips, the corresponding text files must still exist (they can be empty).

---

### 5. `_VideoFormat.ps1`
Script to generate a **display format reference** for all listed movies.
This script is **optional** and primarily assists with **projector aiming and screen setup** before movie night.

- **Dependencies**
  - Loads paths from `Variables.ps1`.
  - Uses `mpc-hc64` for video playback and screenshots.
  - Requires `System.Windows.Forms` and `System.Drawing`.

- **Process**
  1. Reads `MovieList.txt` for all movies.
  2. Opens each movie in MPC-HC and saves a screenshot.
  3. Analyzes image dimensions to calculate max scaled size that fits within a 1920x1080 box.
  4. Generates a reference image (`_DisplayFormat.png`) with red/green borders showing safe display dimensions.
  5. Deletes temporary screenshots after processing.

- **Use Case**
  - Ensures all movies display properly on the screen without uneven scaling or cropping.
  - Provides a **visual guide** to help align the projector and verify aspect ratio before starting the event.

---

## 🎬 Typical Flow
1. Run `_OutsideMovieNightScript.ps1`.
2. Script loads movie list and optional intro/intermission/end clips.
3. Plays intro → movie → intermission (or end clip).
4. Lighting webhooks (`CurlRunX`) run at predefined times.
5. Intermissions may show a screensaver.
6. System optionally shuts down after the final movie.

---

## ✅ Requirements
- Windows environment
- [MPC-HC](https://mpc-hc.org/) (`mpc-hc64.exe` in PATH or same folder)
- PowerShell 5+
- Optional: Home Assistant (or equivalent) for lighting webhooks

## Disclaimer
1. This is a personal project provided **"as-is"** with no warranty or guarantee of any kind. Use it at your own risk.
2. This project is not affiliated with, endorsed by, or sponsored by any movie studios, film producers, distributors, or other entities involved in the creation or distribution of films. All movies, clips, and related media are the property of their respective owners. Users are responsible for ensuring they have the proper rights and licenses to play any content with this software.
