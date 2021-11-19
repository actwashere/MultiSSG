#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common verrors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, Force
SetKeyDelay, 1
; Script version 1.2.1

; If your using a different language, please go to edit reset.ahk and follow the instructions there. 
; Also, check lines 90-110 and follow the instructions there.

global save_directories := [""] ; do NOT put "\" at the end of your file name.
global old_worlds := "" ; do NOT put "\" at the end of this string

global seed := "-3294725893620991126" ; 1.17 SSG seed is the default
global title_delay := 500 ; Raise number if getting stuck on title screen OR getting stuck on multiplayer
global world_list_delay := 1100 ; Raise number if getting stuck in world list screen
global vert_delay := 300 ; For vertification purposes, increase the delay if not all world creation screens are shown.
global obs_delay := 150 ; Increase if the macro isn't changing your OBS scenes
global fullscreen_delay := 300 ; Increase if you're having fullscreening issues.

; Set the following values to 'true' or 'false'
global change_obs_scene := true ; If true, you will have to have a seperate OBS instance open, recording all instances, for vertification.
global play_sound := true ; A noise will play whenever a good seed is found.
global fullscreen := false ; A little wacky, but should work 

; auto reset stuff (Most of this was taken from Pjagada's  1.16 plus reset)
global radius := 7 ; radius from around the center points where spawns wont be reset. If you would like to only spawn on whitelisted spawns, change this number to a negative number.
global centerPointX := 162.7 ; this is the x coordinate of that certain point (by default it's the x coordinate of being pushed up against the window of the blacksmith of -3294725893620991126)
global centerPointZ := 194.5 ; this is the z coordinate of that certain point (by default it's the z coordinate of being pushed up against the window of the blacksmith of -3294725893620991126)
global auto_reset_delay := 600 + title_delay + world_list_delay + vert_delay ; Increase number at the beggining to slow down resets but lower the amount of false-positive good spawns.

; dont configure (Either they dont do anything yet, or you don't need to change it)
global PIDs := []
global active_id := ""

global instance_number := 0
for instance in save_directories
	instance_number++

getSpawnPoint(inst) ; Taken from Pjagada's 1.16 plus reset
{
	logFile := StrReplace(save_directories[inst], "saves", "logs\latest.log")
	numLines := 0
	Loop, Read, %logFile%
	{
		numLines += 1
	}
	Loop, Read, %logFile%
	{
		if ((numLines - A_Index) <= 15)
		{
			if (InStr(A_LoopReadLine, "logged in with entity id"))
			{
				spawnLine := A_LoopReadLine
			}
		}
	}
	array1 := StrSplit(spawnLine, " at (")
	xyz := array1[2]
	array2 := StrSplit(xyz, ", ")
	xCoord := array2[1]
	zCooord := array2[3]
	array3 := StrSplit(zCooord, ")")
	zCoord := array3[1]
	return ([xCoord, zCoord])
}


AddToBlacklist()
{
	currentSpawn := getSpawnPoint(GetActiveInstanceNum())
	xCoord := currentSpawn[1]
	zCoord := currentSpawn[2]
	theString := xCoord . "," . zCoord . ";" . xCoord . "," . zCoord
	if (!FileExist("blacklist.txt"))
		FileAppend, %theString%, blacklist.txt
	else
		FileAppend, `n%theString%, blacklist.txt
}

CopyCoords()
{
	currentSpawn := getSpawnPoint(GetActiveInstanceNum())
	xCoord := currentSpawn[1]
	zCoord := currentSpawn[2]
	theString := xCoord . "," . zCoord . ";" . xCoord . "," . zCoord
	Clipboard := theString
}

isInGame(currTitle) {
	return InStr(currTitle, "Singleplayer") || InStr(currTitle, "Multiplayer") 
	; CHANGE THIS to whatever Singleplayer and Multiplayer is in the language your using in game.
	; You can find this by opening to LAN and checking the title.
}

AlertUser()
{
	if (play_sound = true)
	{
		if (FileExist("spawnready.mp3")) ; You can create a .mp3 file and have that play as the reset sound.
			SoundPlay, spawnready.mp3
		else
			SoundPlay *16
	}
}

GetActiveInstanceNum() { ; Taken from Specnr's "The Wall" macro (with changes)
	WinGet, pid, ID, A
	WinGetTitle, WinTitle, ahk_id %pid%
	if (InStr(WinTitle, "Minecraft")) { ; CHANGE THIS to whatever Singleplayer is in the language your using in game. Find this by loading into a world and checking the window title.
		for i, tmppid in PIDs {
			if (tmppid == pid)
				return i
		}
	}
	return -1
}

ActivateInstance(idx) { ; Taken from Specnr's macro
	pid := PIDs[idx]
	if (change_obs_scene == true) {
		send {Numpad%idx% down}
		sleep, %obs_delay%
		send {Numpad%idx% up}
	}
	WinSet, AlwaysOnTop, On, ahk_id %pid%
	WinSet, AlwaysOnTop, Off, ahk_id %pid%
	if (fullscreen) {
		ControlSend, ahk_parent, {Blind}{F11}, ahk_id %pid%
		sleep, %fullscreen_delay%
	}
	send {LButton}
}

SetTitles() { ; Taken from Specnrs Wall 1
	for i, pid in PIDs {
		WinSetTitle, ahk_id %pid%, , Minecraft* - Instance %i%
	}
}

ExitWorld() {
	if (index := GetActiveInstanceNum()) > 0 
	{
		pid := PIDs[index]
		curr_dirr := save_directories[index]
		if (change_obs_scene == true) {
			Send, {F12 down}
			sleep, %obs_delay%
			Send, {F12 up}
		}
		WinActivate, OBS
		Run, reset.ahk %pid% %vert_delay% %world_list_delay% %title_delay% %index% %seed% "%curr_dirr%" %auto_reset_delay% %radius% %centerPointX% %centerPointZ% %old_worlds%
	}	
}

global has_paused := false
deletePause() {
	if (FileExist("pause.txt")) {
		FileDelete, pause.txt
	}
}

removeTopLine() {
	getPauseSize()
	FileRead, my_file, pause.txt
	num_lines := InStr(my_file, "`n",,, 1)
	if (num_lines > 0) {
		new_file := SubStr(my_file, InStr(my_file, "`n") + 1)
		FileDelete, pause.txt
		FileAppend, %new_file%, pause.txt
	} else if (num_lines == 0) {
		FileDelete, pause.txt
	}
}

managePause() {
	FileReadLine, new_inst, pause.txt, 1
	sleep, %auto_reset_delay%
	ActivateInstance(new_inst)
	AlertUser()
	has_paused := true
}

pauseLoop(i) {
	if (has_paused == true) {
		removeTopLine()
	}
	if (i >= instance_number) {
		ExitWorld()
		Loop {
			if (FileExist("pause.txt")) {
				managePause()
				break
			}
			sleep, 250
		}
	}
}	

getPauseSize() { ; returns false if empty (and deletes), true if it has something
	FileGetSize, size, pause.txt
	FileRead, test, pause.txt
	if (size <= 3) {
		FileDelete, pause.txt
		return false
	} else {
		return true
	}
}

; Perch code taken from Pjagada
WaitForHost()
{
	logFile := StrReplace(save_directories[GetActiveInstanceNum()], "saves", "logs\latest.log")
	numLines := 0
	Loop, Read, %logFile%
	{
		numLines += 1
	}
	openedToLAN := False
	while (!openedToLAN)
	{
		Loop, Read, %logFile%
		{
			if ((numLines - A_Index) < 2)
			{
				if (InStr(A_LoopReadLine, "[CHAT] Local game hosted on port"))
				{
					openedToLAN := True
				}
			}
		}
	}
}

OpenToLAN() {
	Send, {Esc} {Tab 7}
	Send, {Enter}
	Send, {Tab 2}
	Send, {Enter}
	Send, {Tab}
	Send, {Enter}
	WaitForHost()
}

Perch() {
	OpenToLAN()
	Send, /
	Sleep, 70
	SendInput, data merge entity @e[type=ender_dragon,limit=1] {{}DragonPhase:2{}}
	Send, {enter}
}

deletePause()
global setup := false
global initial_resets := 0
Ins:: ; This is where the keybind for setting up / changing instance names is set.
if (setup = false) {
		for i, inst in save_directories
		{
			MsgBox, When you are ready, close this window then maximize the next Minecraft Instance. `nThe previous instance title was `n%WinTitle%
			sleep, 5000
			WinGet, active_id, ID, A
			WinGetTitle, WinTitle, ahk_id %active_id%
			PIDs.Push(active_id)
		}
		SetTitles()
		MsgBox, Got all of the windows, you can open the right OBS scene and start resetting! `nThe previous instance title was `n%WinTitle%
		setup = true
	} else {
		SetTitles()
	}
return

#IfWinActive, Minecraft
{
	PgUp:: ; This is where the keybind for resetting worlds is set.
		initial_resets++
		if (fullscreen && initial_resets > instance_number) {
			send {f11}
			sleep, %fullscreen_delay%
		}
		ExitWorld()
		pauseLoop(initial_resets)
	return
	
	^B:: ; This is where the keybind is set for adding a spawn to the blacklisted spawns.
		AddToBlacklist()
	return
	
	^R:: ; Keybind for copying coordinates for the whitelist, you can just paste the string it gives you into the whitelist.txt file
		CopyCoords()
	return	
	
	End:: ; This is where the keybind for forcing the dragon to perch is set
		Perch()
	return	
}