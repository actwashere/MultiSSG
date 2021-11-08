# MultiSSG
An AHK script for Multi Instance 1.17 SSG
I haven't heavily tested this script, so expect it to be a little bit glitchy. It should work reliably enough, though.
If you want a video tutorial on how to set it up, click [here](https://youtu.be/xj_uRs_kyhc). Otherwise, scroll down to the how-to section.
Scroll down for a how-to.
OBS scene switching is currently broken

## Features
- Reset worlds from in-game.
- Multi instance resetting, with no limit on how many instances you can use (as far as I'm aware).
- Automatically switch to an instance with a good spawn.
- Automatically moves worlds to an 'Old Worlds' folder.
- A sound will play when a world is ready to be played (Sometimes, the OBS scene will switch a while before the Minecraft window is maximized, this is normal).

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
- There is NO fullscreen support yet
- Anything more then 3 instances can get a little scuffed, but usually the macro fixes itself (I cannot playtest above 3 instances, so lmk if you get problems above there)
- If you want IGT, use Specnr's livesplit setup for his [wall macro](https://github.com/Specnr/MultiResetWall).
- Does not reset from title screen

## How To
Make sure you have OBS open.
Download the [Latest Release](https://github.com/actwashere/MultiSSG/releases/latest), make sure to keep the .ahk files in the same spot.

Change the configurable variables, then run the script.
Once the script is running, press the `INS` button, then follow the instructions in the pop up box.

To reset, press `PG UP`. You can change these hotkeys at the bottom of the script.
Resetting currently does NOT work from the title screen

This relies on having OBS open, and having the [1.17 Fast Reset mod](https://github.com/jan-leila/FastReset/releases/tag/1.17.1-1.0.0).

## Road Map
- Full screen support
- Dragon perch macro
- Better livesplit support (Probably an option to automatically change the config file of Livesplit, letting in game time work on all instances)
- Change settings on reset
- Title screen resets
- Flint rate tracking
- Easier setup
- Instance freezing (Not sure how helpful this will be with SSG)

## Credits
Some autoresetter code from [Pjagada's SSG Script](https://github.com/pjagada/minecraftahk)

Some instance switching / managing code from [Specnr's Wall & Multi Instance scripts](https://github.com/Specnr)
