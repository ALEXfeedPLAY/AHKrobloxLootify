#NoEnv
#SingleInstance, Force
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

; Configuration
global IsRunning := false
global Tolerance := 25  ; Adjust this value for X-position tolerance
global CanFish := true ; Global variable to check if fishing is possible
global LogUse := false  ; Use log file for debugging
; Hotkeys
Hotkey, Esc, ExitScript
Hotkey, P, PauseScript
HotKey, ^C, ShowMousePosition
Hotkey, ^R, ShowPixelColor
; Hotkey, ^L, ShowRegionSelector  ; Ctrl+L to open selector ; Delete first symbol ";" if you want to use it
; Hotkey, ^D, DrawSearchArea  ; Ctrl+D to draw region
; Hotkey, ^+D, ShowCurrentRegion
; Hotkey, ^+T, TestColors  ; Ctrl+T to test

global StartX, StartY, EndX, EndY
global IsSelecting := false

; initialization section
IfExist, fishing.ini
{
    IniRead, X1, fishing.ini, Settings, X1, 0
    IniRead, Y1, fishing.ini, Settings, Y1, 0
    IniRead, X2, fishing.ini, Settings, X2, %A_ScreenWidth%
    IniRead, Y2, fishing.ini, Settings, Y2, %A_ScreenHeight%

    IniRead, X1err, fishing.ini, Settings, X1err, 0
    IniRead, Y1err, fishing.ini, Settings, Y1err, 0
    IniRead, X2err, fishing.ini, Settings, X2err, %A_ScreenWidth%
    IniRead, Y2err, fishing.ini, Settings, Y2err, %A_ScreenHeight%

    IniREad, grayColor, fishing.ini, Colours, grayColor, 0xABABAB
    IniREad, greenColor, fishing.ini, Colours, greenColor, 0x86FFC7
    IniREad, yellowColor, fishing.ini, Colours, yellowColor, 0xFFD025
}

IfWinExist, ahk_exe RobloxPlayerBeta.exe
{
    WinActivate
    WinWaitActive
}
else
{
    MsgBox, Roblox is not running. Please open the game and try again.
    ExitApp
}

showmainUI:
    global IsRunning, LogUse
    Gui, MainUI:New, +AlwaysOnTop +ToolWindow
    Gui, Add, Button, gShowRegionSelector, Change positions of Search Region
    
    Gui, Add, Button, gShowCurrentRegion, Show Current Region
    Gui, Add, Button, gDrawSearchArea, Draw the current Search Area
    Gui, Add, Button, gTestColors, Testing Colors

    Gui, Add, Button, gSpamE, Spam E for money Shrimp

    Gui, Add, Checkbox, vIsRunning gPauseScript, Pause Enabled
    Gui, Add, Checkbox, vLogUse gLogUseChange, Use log file for debugging
    Gui, Add, Button, gFishingStart, Start Fishing
    Gui, Add, Button, gExitScript, Exit Script
    Gui, Show
return

ShowRegionSelector:    
    Gui, RegionSelector:New, +AlwaysOnTop, Search Region Setup
    Gui, Add, Text, , X1:
    Gui, Add, Edit, vX1Input w100, %X1%
    Gui, Add, Text, , Y1:
    Gui, Add, Edit, vY1Input w100, %Y1%
    Gui, Add, Text, , X2:
    Gui, Add, Edit, vX2Input w100, %X2%
    Gui, Add, Text, , Y2:
    Gui, Add, Edit, vY2Input w100, %Y2%
    
    Gui, Add, Button, gCapturePosition, Capture Start (Hold LMB)

    Gui, Add, Text, , Search Error Region Setup:

    Gui, Add, Text, , X1:
    Gui, Add, Edit, vX1errInput w100, %X1err%
    Gui, Add, Text, , Y1:
    Gui, Add, Edit, vY1errInput w100, %Y1err%
    Gui, Add, Text, , X2:
    Gui, Add, Edit, vX2errInput w100, %X2err%
    Gui, Add, Text, , Y2:
    Gui, Add, Edit, vY2errInput w100, %Y2err%

    Gui, Add, Button, gCaptureErrPosition, Capture Error Area (Hold LMB)

    Gui, Add, Button, gSaveCoordinates, Save Coordinates
    Gui, Show
return

CapturePosition:
    IsSelecting := true
    ToolTip, Click and hold LMB to set start position
    KeyWait, LButton, D
    MouseGetPos, StartX, StartY
    ToolTip, Start position set: %StartX%`,%StartY%
    GuiControl, , X1Input, %StartX%
    GuiControl, , Y1Input, %StartY%

    KeyWait, LButton, Up
    MouseGetPos, endX, endY
    ToolTip, End position set: %endX%`,%endY%
    GuiControl, , X2Input, %endX%
    GuiControl, , Y2Input, %endY%

    CaptureUI(StartX, StartY, endX, endY)

    Sleep, 1000
    ToolTip
return

CaptureErrPosition:
    IsSelecting := true
    ToolTip, Click and hold LMB to set start position
    KeyWait, LButton, D
    MouseGetPos, StartX, StartY
    ToolTip, Start position set: %StartX%`,%StartY%
    GuiControl, , X1errInput, %StartX%
    GuiControl, , Y1errInput, %StartY%

    KeyWait, LButton, Up
    MouseGetPos, endX, endY
    ToolTip, End position set: %endX%`,%endY%
    GuiControl, , X2errInput, %endX%
    GuiControl, , Y2errInput, %endY%

    CaptureUI(StartX, StartY, endX, endY)

    Sleep, 1000
    ToolTip
return

CaptureUI(StartX, StartY, endX, endY) {
    global SearchText
    Gui, AreaView:New, +AlwaysOnTop -Caption +ToolWindow
    Gui, Color, Yellow
    Gui, Font, s24, Arial  ; Set font size and type
    Gui, Add, Text, cBlue Center vSearchText, SEARCH AREA
    Gui, Show, % "x" StartX " y" StartY " w" (endX-StartX) " h" (endY-StartY)
    GuiControl, Move, SearchText, % "x" (endX-StartX)/2-50 " y" (endY-StartY)/2-12

    Sleep, 3000
    Gui, Destroy
}

SaveCoordinates:
    Gui, Submit
    X1 := X1Input
    Y1 := Y1Input
    X2 := X2Input
    Y2 := Y2Input

    X1err := X1errInput
    Y1err := Y1errInput
    X2err := X2errInput
    Y2err := Y2errInput

    ; Swap coordinates if inverted
    coords := swapCoordinates(X1, Y1, X2, Y2)
    X1 := coords[1], Y1 := coords[2], X2 := coords[3], Y2 := coords[4]
    coordsErr := swapCoordinates(X1err, Y1err, X2err, Y2err)
    X1err := coordsErr[1], Y1err := coordsErr[2], X2err := coordsErr[3], Y2err := coordsErr[4]

    ; Display the search region coordinates
    MsgBox, Search region set to:`n`nX1: %X1% Y1: %Y1%`nX2: %X2% Y2: %Y2%`n`n`nError region set to:`nX1: %X1err% Y1: %Y1err%`nX2: %X2err% Y2: %Y2err%
    ; Optional: Save to INI file
    IniWrite, %X1%, fishing.ini, Settings, X1
    IniWrite, %Y1%, fishing.ini, Settings, Y1
    IniWrite, %X2%, fishing.ini, Settings, X2
    IniWrite, %Y2%, fishing.ini, Settings, Y2
    ; Error region
    IniWrite, %X1err%, fishing.ini, Settings, X1err
    IniWrite, %Y1err%, fishing.ini, Settings, Y1err
    IniWrite, %X2err%, fishing.ini, Settings, X2err
    IniWrite, %Y2err%, fishing.ini, Settings, Y2err
    ; Save colors
    IniWrite, %grayColor%, fishing.ini, Colours, grayColor
    IniWrite, %greenColor%, fishing.ini, Colours, greenColor
    IniWrite, %yellowColor%, fishing.ini, Colours, yellowColor

    Gui, Destroy
return

swapCoordinates(X1, Y1, X2, Y2) {
    if (Y1 > Y2) {
        temp := Y1
        Y1 := Y2
        Y2 := temp
    }
    if (X1 > X2) {
        temp := X1
        X1 := X2
    }

    return [X1, Y1, X2, Y2]
}

FishingStart(){
    Loop
    {
        if (IsRunning == false) {
            Sleep, 2000
            ToolTip, Press @P to start
            continue
        }
        
        Sleep, 500
        ToolTip, Waiting for an Action. Change Direction to avoid the bottle. Providing Click
        changePlayerDirection()
        Click

        Loop, 10
        {
            error = FindImage("error.png")
            if (error != "")
            {
                ToolTip, Error detected. Catching the bottle, 10, A_ScreenHeight/2
                CatchBottle()
                break
            }
            
            Sleep 15
        }

        Sleep, 4000

        ; Wait for black screens to appear
        if !WaitForBlackScreens()
        {
            continue
        }
        
        tmp := 0
        ; Main loop
        Loop, 
        {
            if (IsRunning == false) { 
                Break 
            }
        
            ; Find green and yellow positions
            greenX := FindColor(greenColor)

            yellowX := FindColor(yellowColor)

            ; Check if scene disappeared
            if (greenX == "" || yellowX == "")
            {
                ; Scene ended, wait for new activation
                ToolTip, No Image found attemp: %tmp% greenX: %greenX% yellowX: %yellowX%
                Sleep, 100

                if (tmp >= 10) {
                    ToolTip, Event ended. Start Event again.
                    Sleep, 1000
                    Break
                }

                tmp := tmp + 1
                continue
            }
            
            ; Check X position alignment
            if (Abs(greenX - yellowX) <= Tolerance)
            {
                Click
                Sleep, 150  ; Wait for animation
            }
            
            Sleep, 15
        }
        
    }
    Return
}

WaitForBlackScreens() {
    ToolTip, check action
	temp := 0
    Loop, 100 ; Wait max 10 seconds
    {
        if (IsRunning == false) { 
            Break 
        }
        ; Check for top black screen
        ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight//3, black.png
        if (ErrorLevel = 0)
        {
            ToolTip, Event detected
            return true
        }

        Sleep, 100
    }
}

changePlayerDirection(){
    ; Change player direction
    Send, {Shift}{Left}
    Sleep, 500
    MouseGetPos, xpos, ypos
    MouseMove, xpos+1, ypos, 100
    Sleep, 500
    Send, {Shift}{Left}
    Sleep, 1000
}

FindColor(targetColor) {
    global X1, Y1, X2, Y2, LogUse
    global grayColor, greenColor, yellowColor 
    
    PixelSearch, FoundX, FoundY, %X1%, %Y1%, %X2%, %Y2%, %targetColor%, 10, Fast RGB
    if (ErrorLevel == 0) {

        if (LogUse)
            FileAppend,  Color %targetColor% found at %FoundX%`,%FoundY%`n, found.log

        return FoundX
    }

    if (LogUse){
        ToolTip, Color %targetColor% not found in region %X1%`,%Y1% - %X2%`,%Y2%
        FileAppend, Searching for color: %targetColor% in region %X1%`,%Y1%-%X2%`,%Y2%`n, debug.log
    }

    return ""
}

FindImage(image) {
    global X1err, Y1err, X2err, Y2err, LogUse
    ImageSearch, FoundX, FoundY, %X1err%, %Y1err%, %X2err%, %Y2err%, *10 *TransBlack *n80 %image%

    if (ErrorLevel == 0) {  
        if (LogUse)
            FileAppend,  Image: %image% found at %FoundX%`,%FoundY%`n, found.log

        return FoundX
    } 

    if LogUse{
        FileAppend, Searching for image: %image% in region %X1%`,%Y1%-%X2%`,%Y2%`n, debug.log
    }

    return ""
}

ShowMousePosition:
    MouseGetPos, xpos, ypos
    ToolTip, X: %xpos% Y: %ypos%, 10, A_ScreenHeight/2
return

PauseScript:
    global IsRunning
    if (IsRunning == true) {
		IsRunning := false
		ToolTip, Script Paused, 10, A_ScreenHeight/2
	} else {
		IsRunning := true
		ToolTip, Script Started, 10, A_ScreenHeight/2
	}
return

LogUseChange:
    global LogUse
    LogUse := !LogUse
return

; Function to show the RGB color of the pixel where the mouse is located
ShowPixelColor:
    MouseGetPos, xpos, ypos
    PixelGetColor, color, %xpos%, %ypos%, RGB
    MsgBox, The color at the current mouse position (X: %xpos%, Y: %ypos%) is %color%
return

DrawSearchArea:
    ; Draw the main search area
    Gui, Debug:New, +AlwaysOnTop -Caption +ToolWindow
    Gui, Color, Red
    Gui, Add, Text, , SEARCH AREA
    Gui, Show, % "x" X1 " y" Y1 " w" (X2-X1) " h" (Y2-Y1)

    ; Draw the error search area
    Gui, ErrorDebug:New, +AlwaysOnTop -Caption +ToolWindow
    Gui, Color, Blue
    Gui, Add, Text, , ERROR AREA
    Gui, Show, % "x" X1err " y" Y1err " w" (X2err-X1err) " h" (Y2err-Y1err)

    Sleep, 3000
    Gui, Debug:Destroy
    Gui, ErrorDebug:Destroy
return

ShowCurrentRegion:
    ToolTip, Current Region: X1=%X1% Y1=%Y1% X2=%X2% Y2=%Y2% `n Current Error Region: X1=%X1err% Y1=%Y1err% X2=%X2err% Y2=%Y2err%
    Sleep, 3000
    ToolTip
return

TestColors:
    global yellowColor, greenColor, grayColor, Tolerance, LogUse

    if (LogUse)
        FileAppend, Current Color Values: Yellow: %yellowColor% Green: %greenColor% Gray: %grayColor%`n, debug.log

    MsgBox, 
    (LTrim
        Current Color Values:
        Yellow: %yellowColor%
        Green: %greenColor%
        Gray: %grayColor%

        Tolerance: %Tolerance%
        IsRunning: %IsRunning%
    )
return

SpamE(){
    openRoblox()
    IsRunning := true
    ToolTip, Event spamming was Started, 10, A_ScreenHeight/2
    Loop
        {
            if (!IsRunning)
            {
                ToolTip, Event spamming was ended, 10, A_ScreenHeight/2
                Sleep 1000 
                Break
            }
            
            Send e
            Sleep 10
        }
    Return
}

CatchBottle(){
    global CanFish

    if (!CanFish) {
        ToolTip, Cannot fish in this area
        return
    }

    Send, {w down}
    startTime := A_TickCount

    Loop
    {
        if (IsRunning == false) {
            Send, {w up}
            return
        }

        ; Check for the error image indicating a bottle
        if (FindImage("bottle.png") != "" || (time := A_TickCount - startTime > 10000) ) {

            elapsedTime := A_TickCount - startTime
            ; Stop moving forward
            
            Send, {w up}
            ToolTip, Bottle found or time is up, picking up
            Sleep, 500

            ; Hold "e" to pick up the bottle
            if (elapsedTime <= 10000) {
                Send, {e down}
                Sleep, 4000
                Send, {e up}
            }

            Click, 10, % (A_ScreenHeight)
            Click, 10, % (A_ScreenHeight)
            ; Move back to the original position
            Send, {s down}
            Sleep, elapsedTime
            Send, {s up}

            ; Reset CanFish to true
            CanFish := true
            return
        }

        Sleep, 100
    }
}

openRoblox(){
    IfWinExist, ahk_exe RobloxPlayerBeta.exe
    {
        IfWinActive
        {
            return
        }
        else
        {
            WinActivate
            WinWaitActive
        }
    }
    else
    {
        MsgBox, Roblox is not running. Please open the game and try again.
        ExitApp
    }
}

ExitScript:
    ExitApp
return