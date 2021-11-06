# MultiSSG
An AHK script for Multi Instance 1.17 SSG
Scroll down for a how-to.

## Features
- Reset worlds from in-game.
- Multi instance resetting, with no limit on how many instances you can use (as far as I'm aware).
- Automatically switch to an instance with a good spawn.
- Automatically moves worlds to an 'Old Worlds' folder.

Auto Resetter Features:
- This is near the same as [Pjagada's SSG Script](https://github.com/pjagada/minecraftahk)
- Completely customizable whitelist & blacklist, compatible with the whitelist and blacklist from Pjagada's script
- Customizable center point, where all spawns outside of a certain radius from that centerpoint will be reset.
- Will be alerted when a good spawn is loaded
- Automatically switchs OBS scene and Active Instance to the good spawn.

There are, unfortuantely, some limitations to this script:
- All resets will be paused when a good SSG seed is loaded
- Macro sometimes breaks if a lot of good seeds are loaded at the same time
- Manually have to enter the saves directories
- On initial load, you have to do some extra steps in order for the script to work.

## How To
Make sure you have OBS open.
Download the [Latest Release](https://github.com/actwashere/MultiSSG/releases/latest), make sure to keep the .ahk files in the same spot.

Change the configurable variables, then run the script.
Once the script is running, press the `INS` button, then follow the instructions in the pop up box.

To reset, press `PG UP`. You can change these hotkeys at the bottom of the script.
Resetting currently does NOT work from the title screen

This relies on having OBS open, and having the [1.17 Fast Reset mod](https://github.com/jan-leila/FastReset/releases/tag/1.17.1-1.0.0).

## Credits
Some autoresetter code from [Pjagada's SSG Script](https://github.com/pjagada/minecraftahk)

Some instance switching / managing code from [Specnr's Wall & Multi Instance scripts](https://github.com/Specnr)
