screenWidth=1920
screenHeight=1080

/*
- Windows 10 with high DPI display mast get the value of 'Change the size of text, apps, and other items', you can find it in above:
    1. Right-click anywhere on the Desktop
    1. Select __Display Settings__ from the menu, You will see it
    1. Edit Initialization.ahk to change the value after TAOsize= to the corresponding number (without the % sign)

    拥有高 DPI 显示设备的 Windows 10 系统需要获得 “更改文本、应用和其他项目的大小” 的值，你可以在这里找到它：
    1. 在桌面空白地方点击桌面
    1. 从菜单中选择"显示设置“，你会在界面中看到这个选项
    1. 编辑 Initialization.ahk，将 TAOsize= 后面的值改为对应数字（不带 % 号）
*/
TAOsize=120

; Do not change the following
; 不要改变以下内容
; Chat word limit 聊天字数限制
chatboxMaxLength=100

#NoEnv
SetBatchLines -1
ListLines Off
SendMode Input
SetWorkingDir %A_ScriptDir%
#SingleInstance, force
Gosub, SetDefaultState
ResolutionAdaptation("screenWidth","screenHeight")
Menu, tray, NoStandard
Menu, tray, add, 重置 | Reload, ReloadScrit
Menu, tray, add, 暂停 | Pause, PauseScrit
Menu, tray, add
Menu, tray, add, 热键 | HOTKEY, SetHotKey
Menu, tray, add
Menu, tray, add, 帮助 | Help, Help
Menu, tray, add, 更新 | Ver %ver%, UpdateScrit
Menu, tray, add, 退出 | Exit, ExitScrit
Gui, +ToolWindow -Caption +AlwaysOnTop -DPIScale
Gui, Color, %bGColor%
gui, font, s12 cffffff q5, SimSun
gui, font, s11 cffffff q5, Microsoft YaHei UI
Gui, Color, ,000000
Gui, Add, Edit, x0 y0 w%chatboxW% h25 vchatBox Limit140
gui, font
gosub,readini
gosub,checkkey
SetTimer, battleModeCheck, 200
Return
battleModeCheck:
If WinActive("ahk_exe Borderlands3.exe")
{
DllCall("SendMessage", "UInt", (WinActive("ahk_exe Borderlands3.exe")), "UInt", "80", "UInt", "1", "UInt", (DllCall("LoadKeyboardLayout", "Str", "00000804", "UInt", "257")))
}
If WinExist("ChatBoxTitle") && !WinActive("ChatBoxTitle")
{
WinActive("ChatBoxTitle")
Gui Cancel
}
If !WinActive("ahk_exe Borderlands3.exe") && (rDown=1)
{
Send, {RButton Up}
rDown=0
}
Return
readini:
IniRead,startkey,settings.ini,热键,开启聊天,y
IniRead,gamechatkey,settings.ini,热键,游戏中开启聊天,y
IniRead,chooses1,settings.ini,热键,chooses1,1
IniRead,chooses2,settings.ini,热键,chooses2
IniRead,chooseg1,settings.ini,热键,chooseg1,1
IniRead,chooseg2,settings.ini,热键,chooseg2
Return
checkkey:
hotkey,IfWinActive, ahk_exe Borderlands3.exe
hotkey,%startkey%,startchat
Hotkey, IfWinActive
return
#IfWinActive, ahk_exe Borderlands3.exe
startchat:
inputState:=inputState=1?0:1
inBattle:=0
If (inputState=1) && (consoleMode=0)
{
Gui, Show, w%chatBoxW% h25 x%chatBoxX% y%chatBoxY%, %title%
WinSet, TransColor, %bGColor% %transparency%, %title%
}
Return
Esc::
normalButton("Esc")
inputState:=0
consoleMode:=0
gameUI:=0
heroUI:=0
mapsUI:=0
itemUI:=0
inBattle:=0
Return
#IfWinActive, ChatBoxTitle
Enter::
Gui Submit
WinWaitActive, ahk_exe Borderlands3.exe
If (chatBox!="")
{
chatBoxLength:= StrLen(chatBox)
chatBoxCutOff:=chatBoxLength/chatboxMaxLength
If (chatBoxCutOff>1)
{
chatBoxCutOff:= Ceil(chatBoxCutOff)
chatBoxStartPos=1
Loop, %chatBoxCutOff%
{
chatBox%A_Index%:= SubStr(chatBox, chatBoxStartPos, chatboxMaxLength)
chatBoxStartPos:=chatBoxStartPos+chatboxMaxLength
chatText=% chatBox%A_Index%
WinWaitActive, ahk_exe Borderlands3.exe
Send, %gamechatkey%
Sleep, 50
Send, {Text}%chatText%
Sleep, 50
Send, {Enter}
If (A_Index<chatBoxCutOff)
{
Sleep, 50
Send, %sendkey%
}
}
}
Else
{
Send,%gamechatkey%
Sleep, 50
Send, {Text}%chatBox%
Sleep, 50
Send, {Enter}
}
GuiControl, Text, chatBox,
}
Else
GuiControl, Text, chatBox,
inputState:=0
Return
Esc::
Gui Cancel
WinWaitActive, ahk_exe Borderlands3.exe
inputState:=0
Return
#IfWinActive
ReloadScrit:
Reload
Return
PauseScrit:
Pause, Toggle, 1
Return
UpdateScrit:
Run, https://github.com/coralfox/Destiny-2-CN-Chat/releases
Return
Help:
Run, https://github.com/coralfox/Destiny-2-CN-Chat
Return
SetHotKey:
Gosub readini
gui key:-SysMenu
Gui key:Add, Text, x10 y10 w75 h23 +0x200, 开启聊天
Gui key:Add, Text, x10 y40 w75 h23 +0x200, 游戏内聊天
Gui,key:Add, Radio,x75 y15 Group vchooses1 gr1  checked%chooses1%
Gui,key:Add, Radio,x170 y15 vchooses2 gr2 checked%chooses2%
Gui,key:Add, Radio, x75 y45 Group vchooseg1 gr3 checked%chooseg1%
Gui,key:Add, Radio, x170 y45 vchooseg2 gr4 checked%chooseg2%
Gui key:Add, Hotkey, x100 y10 w65   vstartkey,%startkey%
Gui key:Add, Hotkey, x100 y40 w65  vgamechatkey,%gamechatkey%
Gui key:Add, DDL,x195 y10 w50 vskeychoice ,Enter|Space|LWin
Gui key:Add, DDL,x195 y40 w50  vgkeychoice ,Enter|Space|LWin
Gui key:Add, Button, x80 y80 w75 h23, 确定
Gui,key:Show, w300 h140, 设置热键
Gosub, init
return
init:
GuiControl,key:Enable%chooses1%,startkey
GuiControl,key:Enable%chooses2%,skeychoice
GuiControl,key:Enable%chooseg1%,gamechatkey
GuiControl,key:Enable%chooseg2%,gkeychoice
GuiControl, key:ChooseString, skeychoice, %startkey%
GuiControl, key:ChooseString, gkeychoice, %gamechatkey%
return
r1:
GuiControl,key:Enable,startkey
GuiControl,key:Disable,skeychoice
return
r2:
GuiControl,key:Disable,startkey
GuiControl,key:Enable,skeychoice
return
r3:
GuiControl,key:Enable,gamechatkey
GuiControl,key:Disable,gkeychoice
return
r4:
GuiControl,key:Disable,gamechatkey
GuiControl,key:Enable,gkeychoice
return
keyButton确定:
Gui, key:Submit
iniwrite,%chooses1%,settings.ini,热键,chooses1
iniwrite,%chooses2%,settings.ini,热键,chooses2
iniwrite,%chooseg1%,settings.ini,热键,chooseg1
iniwrite,%chooseg2%,settings.ini,热键,chooseg2
if(chooses1)
iniwrite,%startkey%,settings.ini,热键,开启聊天
if(chooses2)
iniwrite,%skeychoice%,settings.ini,热键,开启聊天
if(chooseg1)
iniwrite,%gamechatkey%,settings.ini,热键,游戏中开启聊天
if(chooseg2)
iniwrite,%gkeychoice%,settings.ini,热键,游戏中开启聊天
gui ,key:Destroy
gosub,readini
gosub,checkkey
Return
ExitScrit:
ExitApp
Return
normalButton(key)
{
global
inBattle:=0
If (item!=1)
preWeapon:=weapon
send, {RButton Up}
rDown:=0
Send, {%key% Down}
KeyWait, %key%
Send, {%key% Up}
}
ResolutionAdaptation(width,height)
{
global
dpiRatio:=A_ScreenDPI/96
chatBoxX:=A_ScreenWidth*0.80
chatBoxY:=A_ScreenHeight*0.805
chatBoxW:=A_ScreenWidth/dpiRatio*0.2
If (width=1920)
chatBoxX:=70*dpiRatio*100/TAOsize
If (height=1080)
{
chatBoxW:=480/TAOsize*100
chatBoxY:=850*dpiRatio*100/TAOsize
}
If (width=1366) && (height=768)
{
chatBoxW=340
chatBoxX=50
chatBoxY=600
}
If (width=1360) && (height=768)
{
chatBoxW=340
chatBoxX=50
chatBoxY=600
}
}
SetDefaultState:
ver:=1.0.0
inBattle:=0
item:=0
inputState:=0
gameUI:=0
voteUI:=0
consoleMode:=0
bGColor:="FF00FF"
transparency:=200
title:="ChatBoxTitle"
Return
;================= END SCRIPT ===================
