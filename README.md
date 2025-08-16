# Backyard Movie Night
- OutsideMovieNightScript.ps1 (Required - Script to run movie night)
- MovieList.txt (Required - Text file containing all movie file names)
- VideoFormat.ps1 (Optional - Helper script for screen setup)

## Backyard Movie Night Automation Script

This PowerShell script automates a "Backyard Movie Night" using [MPC-HC](https://mpc-hc.org/) as the media player, along with webhook triggers for a smart home setup. It plays a playlist of movies, handles lighting cues, manages intermissions, and ensures a clean system shutdown.

### Features

- Reads a list of movie filenames from `MovieList.txt`
- Plays an intro clip, a main feature, and an end clip per movie
- Sends webhooks to a Home Assistant instance for light control and event tracking:
  - `BackyardMovieNightStart`
  - `BackyardMovieNightLightsOn`
  - `BackyardMovieNightLightsOff`
  - `BackyardMovieNightDoubleFeatureStart`
- Calculates and displays total playlist duration
- Automatically enters fullscreen mode in MPC-HC
- Displays a screensaver during intermission
- Schedules system shutdown after the final movie ends

### Configuration

- **Movie folders**:
  - Movies: `C:\Users\Schwoby\Videos\Movies`
  - Intro/Outro clips: `C:\Users\Schwoby\Videos\Videos`
- **Required files**:
  - `MovieList.txt`: One movie filename per line
  - Intro clip: `MovieNight.mp4`
  - End clips: `AfterParty.mp4`, `FerrisBueller.mp4`
- **Time settings**:
  - Lights-on offset: `300 seconds` before end of playback
  - Intermission: `600 seconds` between movies
- **Webhooks**:
  - Assumes Home Assistant is accessible at `http://192.168.144.13:8123`

### Dependencies

- [MPC-HC](https://mpc-hc.org/)
- PowerShell
- `curl.exe` (included with Windows or installable via [curl.se](https://curl.se/windows/))
- [Marine Aquarium screensaver](https://live.serenescreen.com/v2/) (`MarineAquarium3.scr`)

### Behavior Overview

1. Minimizes all windows.
2. Triggers the `BackyardMovieNightStart` webhook.
3. For each movie:
   - Plays the intro, main movie, and end clip.
   - Sends lighting webhooks based on whether the movie is last in the list.
   - Calculates the duration and turns on lights shortly before the movie ends.
   - Waits for the movie player to close.
   - Displays a screensaver for intermission.
   - Sends either a "LightsOff" or "DoubleFeatureStart" webhook.
4. After all movies are done:
   - Initiates system shutdown.

## Video List Text File

This text file contains one moive per line. Each line needs the entire file name (Movie Name.mp4). Spaces in the file name are accepted.

## Video Screenshot and Display Format Generator

This PowerShell script automates taking screenshots of videos using [MPC-HC](https://mpc-hc.org/), then analyzes the resulting images to determine maximum scaled dimensions, and finally generates a visual display format image with red borders indicating letterboxing/pillarboxing.

### Features

- Reads video filenames from `MovieList.txt`
- Launches each video in MPC-HC
- Takes a screenshot using simulated keyboard input
- Scales each screenshot to fit within 1920×1080 bounding box
- Tracks the maximum scaled width and height across all screenshots
- Generates a `DisplayFormat.png` with:
  - Green fill for active image area
  - Red borders for unused space (top, bottom, or sides)
- Deletes individual screenshots after analysis

### Configuration

- **Folders**:
  - Movie source: `C:\Users\Schwoby\Videos\Movies`
  - Working/output: `C:\Users\Schwoby\Videos`
- **Input**:
  - `MovieList.txt`: List of movie filenames, one per line
- **Output**:
  - Scaled screenshots: `Video1.png`, `Video2.png`, ...
  - Final output image: `DisplayFormat.png`

### Screenshot Workflow

1. Starts each video in MPC-HC
2. Waits for the window to be active
3. Simulates:
   - `Alt + I` to open the screenshot save dialog
   - Filename entry and PNG format selection
4. Saves screenshot to working folder
5. Terminates MPC-HC after screenshot is taken

### Image Analysis & Output

- Calculates scale factor for each screenshot to fit within 1920×1080
- Logs original and scaled dimensions
- Creates a green 1920×1080 image
- Fills unused space with red to visualize borders
- Saves result as `DisplayFormat.png`
- Cleans up all individual screenshots

### Dependencies

- [MPC-HC](https://mpc-hc.org/)
- PowerShell
- `System.Drawing` (GDI+)
- `System.Windows.Forms` (for SendKeys)

## Disclaimer
1. This is a personal project provided **"as-is"** with no warranty or guarantee of any kind. Use it at your own risk.
2. This project is not affiliated with, endorsed by, or sponsored by Twitch Interactive, Inc. Twitch and all related trademarks are the property of their respective owners. Use of Twitch services is subject to Twitch's terms of service and licensing agreements. Users are responsible for complying with Twitch's policies when using this software.
