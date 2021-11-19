#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; Script version 1.2.1

; If you're here because you use a different language, then go to the 
; "ExitWorld()" function, it's around line 125.
; Otherwise, do not edit this script.

global pid := A_Args[1]
global vert_delay := A_Args[2]
global world_list_delay := A_Args[3]
global title_delay := A_Args[4]
global inst_num := A_Args[5]
global seed := A_Args[6]
global savesDirectory := A_Args[7]
global auto_reset_delay := A_Args[8]
global radius := A_Args[9]
global centerPointX := A_Args[10]
global centerPointZ := A_Args[11]
global old_worlds := A_Args[12]

SetKeyDelay, 1

CreateWorld() {
	sleep, title_delay
	ControlSend, ahk_parent, {Tab} {Enter}, ahk_id %pid%
	sleep, world_list_delay / 2
	
	ControlSend, ahk_parent, {Tab 3}, ahk_id %pid% ; world list screen
	sleep, world_list_delay / 2
	ControlSend, ahk_parent, {Enter}, ahk_id %pid%
	
	ControlSend, ahk_parent, {Tab 2}, ahk_id %pid% ; create world screen
	ControlSend, ahk_parent, {Enter 3}, ahk_id %pid%
	ControlSend, ahk_parent, {Tab 4}, ahk_id %pid%
	sleep, vert_delay
	
	ControlSend, ahk_parent, {Enter}, ahk_id %pid% ; more world options screen
	ControlSend, ahk_parent, {Tab 3}%seed%, ahk_id %pid%
	ControlSend, ahk_parent, {Enter}, ahk_id %pid%
	sleep, vert_delay
}

getSpawnPoint() ; Taken from Pjagada's 1.16 plus reset
{
	logFile := StrReplace(savesDirectory, "saves", "logs\latest.log")
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

goodSpawn() ; Taken from Pjagada's 1.16 plus reset
{
	sleep, inst_num * 100
	coords := getSpawnPoint()
	xCoord := coords[1]
	zCoord := coords[2]
	Loop, 2
	{
		currentSpawn[A_Index] := coords[A_Index]
	}
	if (inList(xCoord, zCoord, "whitelist.txt"))
	{
		return True
	}
	if (inList(xCoord, zCoord, "blacklist.txt"))
	{
		return False
	}
	xDisplacement := xCoord - centerPointX
	zDisplacement := zCoord - centerPointZ
	distance := Sqrt((xDisplacement * xDisplacement) + (zDisplacement * zDisplacement))
	if (distance <= radius)
		return True
	else
		return False
}

WaitForLoadIn() ; Taken from Pjagada's 1.16 plus reset
{
   logFile := StrReplace(savesDirectory, "saves", "logs\latest.log")
   numLines := 0
   Loop, Read, %logFile%
   {
	   numLines += 1
   }
   exitLoop := false
   startTime := A_TickCount
   while (!exitLoop)
   {
      Loop, Read, %logFile%
      {
         if ((numLines - A_Index) < 10)
         {
            if ((InStr(A_LoopReadLine, "Saving chunks for level 'ServerLevel")) and (InStr(A_LoopReadLine, "minecraft:the_end")))
            {
               exitLoop := True
            }
         }
      }
   }
}


ExitWorld() {
	WinGetTitle, title, ahk_id %pid%
	if (InStr(title, "Multiplayer")) { ; EDIT THIS, change Multiplayer to whatever the Minecraft Title is when you've opened a world to LAN
		ControlSend, ahk_parent, {Esc} {Tab 8} {Enter}, ahk_id %pid%
	} else {
		ControlSend, ahk_parent, {Esc} {Tab 9} {Enter}, ahk_id %pid%
	}
}

inList(xCoord, zCoord, fileName) ; Taken from Pjagada's 1.16 plus reset
{
	if (FileExist(fileName))
	{
		Loop, read, %fileName%
		{
			arr0 := StrSplit(A_LoopReadLine, ";")
			corner1 := arr0[1]
			corner2 := arr0[2]
			arr1 := StrSplit(corner1, ",")
			arr2 := StrSplit(corner2, ",")
			X1 := arr1[1]
			Z1 := arr1[2]
			X2 := arr2[1]
			Z2 := arr2[2]
			if ((((xCoord <= X1) && (xCoord >= X2)) or ((xCoord >= X1) && (xCoord <= X2))) and (((zCoord <= Z1) && (zCoord >= Z2)) or ((zCoord >= Z1) && (zCoord <= Z2))))
				return True
		}
	}
	return False
}

moveWorlds() { ; basically taken from Specnrs script
	global dir := savesDirectory . "\"
	Loop, Files, %dir%*, D
	{
		If (InStr(A_LoopFileName, "New World") || InStr(A_LoopFileName, "Speedrun #")) {
			tmp := A_NowUTC
			FileMoveDir, %dir%%A_LoopFileName%, %dir%%A_LoopFileName%%tmp%Instance %inst_num%, R
			FileMoveDir, %dir%%A_LoopFileName%%tmp%Instance %inst_num%, %old_worlds%\%A_LoopFileName%%tmp%Instance %inst_num%, 0
		}
	}
}

pauseResets() {
	FileAppend, %inst_num%`n, pause.txt
}

ExitWorld()
Loop {
	moveWorlds()
	CreateWorld()
	sleep, %auto_reset_delay%
	WaitForLoadIn()
	if (goodSpawn()) {
		pauseResets()
		break
	} else {
		while (FileExist("pause.txt")) {
			sleep, 500
		}
		ControlSend, ahk_parent, {Esc}, ahk_id %pid%
		ExitWorld()
	}
}

ExitApp
