;by ahker
;reference https://www.autoahk.com/archives/3274
#include <py>
#include <btt>
#SingleInstance Force
SetWorkingDir, %A_ScriptDir%
CoordMode, ToolTip, Screen
global Items := []
tcmatch := "Tcmatch.dll"
hModule := DllCall("LoadLibrary", "Str", tcmatch, "Ptr")
 ;注册热键
Hotkey, if, WinActive("ahk_class CabinetWClass") && A_CaretX = ""
;预加载
keyValueFind("a","a")
loop, 32
{
    m_hotkey(A_Index + 91)
}
;33-65
loop, 33
{
    m_hotkey(A_Index + 32)
}
Hotkey, %A_Space%, QuickSearch
loop, 9
{
    Hotkey,% "^"A_Index, choose
}
Return
m_hotkey(asci)
{
    thisHotkey := chr(asci)
    Hotkey, %thisHotkey%, QuickSearch,B
}
~$esc::
    hotkeys := ""
    btt()
Return

#if WinActive("ahk_class CabinetWClass") && A_CaretX = ""

~Enter::
    hotkeys := ""
    btt()
Return
 
Backspace::
    hotkeys := SubStr(hotkeys, 1, StrLen(hotkeys) - 1)
    update_btt()
    gosub QuickSearch
Return
choose:
    ctrl_hotkey := A_ThisHotkey
    ctrl_num := SubStr(ctrl_hotkey, 0)
    SelectItem(all_file_name[ctrl_num])
return
QuickSearch:
    Matched := ""
    if(A_ThisHotkey != "Backspace")
    {
        hotkeys := hotkeys . A_ThisHotkey
    }
    update_btt()
    Path := getPath()
    folder := ComObjCreate("shell.Application").NameSpace(Path)
    items := folder.Items
    all_file_name := []
    all_file_name_str := ""
    index := 1
    for item in items
    {
        if (keyValueFind(item.name, hotkeys))
        {
            all_file_name.push(item.name)
            all_file_name_str .= "ctrl+" index ": " item.name "`n"
            index++
        }
    }
    SelectItem(all_file_name[1])
    update_btt()
Return
update_btt()
{
    local
    global hotkeys, all_file_name_str
    btt(hotkeys "`n" all_file_name_str,,,,"Style4",{Transparent:150})
}
keyValueFind(haystack,needle)
{
    ;拼音首字母转换
    haystack .= py.allspell_muti(haystack) . py.initials_muti(haystack)
	findSign:=1
	needleArray := StrSplit(needle, " ")
	Loop,% needleArray.MaxIndex()
	{
		if(!InStr(haystack, needleArray[A_Index], false))
		{
			findSign:=0
			break
		}	
	}
	return findSign
}
getPath()
{
    thisHwnd := WinActive("A")
    WinGet, processName, processName, A
    WinGetClass, class, A

    if (processName!="explorer.exe")
    return
    for window in ComObjCreate("Shell.Application").Windows 
    {
        if (window.name = "文件资源管理器" && window.hwnd == thisHwnd)
        path := StrReplace(window.LocationURL, "file:///", "")
        path := StrReplace(path, "/", "\")
        path := StrReplace(path, "`%20"," ")
    }
    Return path
}
SelectItem(argv)
{
    hwnd := WinActive("a")
    Windows := ComObjCreate("shell.Application").Windows
    for window in Windows
    {
        if window.hwnd == hwnd
        thisWindow := window
    }
    folder := thisWindow.document.folder
    for item in folder.items
    {
        if item.name == argv
        {
            thisWindow.document.SelectItem(item, 13)
        }
    }
    ;thisWindow.document.FilterView("lib")
}