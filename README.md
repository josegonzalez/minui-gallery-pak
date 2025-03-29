# minui-gallery.pak

A MinUI app that starts a viewing Gallery for your images in your Screenshots directory.

## Requirements

This pak is designed and tested on the following MinUI Platforms and devices:

- `tg5040`: Trimui Brick (formerly `tg3040`), Trimui Smart Pro
- `rg35xxplus`: RG-35XX Plus, RG-34XX, RG-35XX H, RG-35XX SP

Use the correct platform for your device.

## Installation

1. Mount your MinUI SD card.
2. Download the latest release from Github. It will be named `Gallery.pak.zip`.
3. Copy the zip file to `/Tools/$PLATFORM/Gallery.pak.zip`.
4. Extract the zip in place, then delete the zip file.
5. Confirm that there is a `/Tools/$PLATFORM/Gallery.pak/launch.sh` file on your SD card.
6. Unmount your SD Card and insert it into your MinUI device.

## Usage

Browse to `Tools > Gallery` and press `A` to enter the Pak. Images can be scrolled by pressing the `LEFT` or `RIGHT` buttons.

### Debug Logging

To enable debug logging, create a file named `debug` in the `$SDCARD_PATH/.userdata/$PLATFORM/Gallery` folder. Logs will be written to the `$SDCARD_PATH/.userdata/$PLATFORM/logs/` folder.
