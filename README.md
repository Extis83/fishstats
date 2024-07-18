# FishStats Addon for HorizonXI

FishStats version 1.0, authored by Extis

This addon displays fishing statistics in a movable window.

## Installation

### Download and Extract:

1. Download the FishStats zip file.
2. Extract the contents of the zip file.

### Copy to Addons Directory:

1. Copy and paste the extracted fishstats folder into the addons folder in your HorizonXI directory.
   - Example path: `C:\Program Files (x86)\HorizonXI\game\addons\fishstats`

### Optional: Add to Default Script:

1. Within the HorizonXI main folder, open the Scripts folder, then open `Default.txt`.
2. Within the section titled " # Load Common Addons," add the following line:

   
   /addon load fishstats
   

3. Save `Default.txt`.

## Commands

### Load the Addon:


/addon load fishstats

### Unload the Addon:


/addon unload fishstats

### Reload the Addon:


/addon reload fishstats

### Reset Fishing Statistics:


/fishstats reset

## Usage

### Moveable Text Window:

- Hold SHIFT and left-click to drag the moveable text window.

## Features

### Displays Fishing Statistics:

- Elapsed Time
- Total Casts
- Fish Caught
- Percent Fish Caught
- Estimated Fish per Hour
- Monsters Caught
- Items Caught
- Catching Nothing

### Automatic Window Display:

- The statistics window will show once a fishing message is received.

### Automatic Window Hiding:

- The statistics window will hide itself 60 seconds after the last fishing action.
