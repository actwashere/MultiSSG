#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetKeyDelay, -1

global save_directories := ["D:\Games\multimc\instances\1.17.11\.minecraft\saves", "D:\Games\multimc\instances\1.17 ssg\.minecraft\saves"] ; no backslash at end of file name
global instance_number := 2 ; put the number of instances your playing with here 
global old_worlds := "D:\Games\multimc\instances\oldworlds" ; do NOT put "/" at the end of this string
global seed := "-3294725893620991126" ; 1.17 SSG seed is the default
global title_delay := 300 ; Raise number if getting stuck on title screen
global world_list_delay := 1100 ; Raise number if getting stuck in world list screen
global vert_delay := 300 ; For vertification purposes, increase the delay if not all world creation screens are shown.
global change_obs_scene := True ; If true, you will have to have a seperate OBS instance open, recording all instances, for vertification.
global obs_delay := 150 ; Increase if the macro isn't changing your OBS scenes
global auto_reset_delay := 100 + title_delay + world_list_delay + vert_delay ; if the auto resetter is breaking, increase the number at the beggining

; auto reset stuff (Most of this was taken from Pjagada's  1.16 plus reset)
global radius := 5 ; radius from around the center points where spawns wont be reset
global centerPointX := 162.7 ; this is the x coordinate of that certain point (by default it's the x coordinate of being pushed up against the window of the blacksmith of -3294725893620991126)
global centerPointZ := 194.5 ; this is the z coordinate of that certain point (by default it's the z coordinate of being pushed up against the window of the blacksmith of -3294725893620991126)

; dont configure
global PIDs := []
global active_id := ""

console(text)
{
	; this is here for debugging
}

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

isInGame(currTitle)
{
	return InStr(currTitle, "Singleplayer") || InStr(currTitle, "Multiplayer")
}

GetActiveInstanceNum() { ; Taken from Specnr's "The Wall" macro (with changes)
	WinGet, pid, ID, A
	WinGetTitle, WinTitle, ahk_id %pid%
	if (InStr(WinTitle, "Minecraft")) {
		for i, tmppid in PIDs {
			if (tmppid == pid)
				return i
		}
	}
	return -1
}

SetTitles() { ; Taken from Specnrs Wall 1
	for i, pid in PIDs {
		WinSetTitle, ahk_id %pid%, , Minecraft* - Instance %i%
	}
}

ExitWorld()
{
	console("Exiting the world...")
	deletePauseFile()
	
	if (index := GetActiveInstanceNum()) > 0
	{
		pid := PIDs[index]
		curr_dirr := save_directories[index]
		console(curr_dirr)
		Run, reset.ahk %pid% %vert_delay% %world_list_delay% %title_delay% %index% %seed% "%curr_dirr%" %auto_reset_delay% %radius% %centerPointX% %centerPointZ% %old_worlds% %obs_delay%
	}
}

ActivateInstance(idx) { ; temp (i think)
	console(idx)
	pid := PIDs[idx]
	console(pid)
	send {Numpad%idx% down}
	sleep, %obs_delay%
	send {Numpad%idx% up}
	WinSet, AlwaysOnTop, On, ahk_id %pid%
	WinSet, AlwaysOnTop, Off, ahk_id %pid%
	send {LButton}
}

deletePauseFile() {
	if (FileExist("pause.tmp")) {
		FileDelete, pause.tmp
	}
}

deletePauseFile()
global setup := false
Ins::
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

PgUp:: ; This will reset and move all worlds that don't start with a '_'
	ExitWorld()
	send {F12 down}
	sleep, %obs_delay%
	send {F12 up}
return