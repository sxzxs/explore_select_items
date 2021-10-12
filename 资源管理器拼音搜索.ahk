;by ahker
;reference https://www.autoahk.com/archives/3274
#include <py>
#include <btt>
#include <my_lib>
#include <log4ahk>
#SingleInstance Force
SetWorkingDir, %A_ScriptDir%
CoordMode, ToolTip, Screen
SetBatchLines, -1
run_as_admin()
global Items := []
global tab_index := 1
global all_file_name := []
 ;注册热键
Hotkey, if, WinActive("ahk_class CabinetWClass") && A_CaretX = ""
;预加载
keyValueFind("}}","a")
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
    tab_index := 1
    btt()
Return

#if WinActive("ahk_class CabinetWClass") && A_CaretX = ""

~Enter::
    hotkeys := ""
    tab_index := 1
    btt()
Return
 
Backspace::
    if(hotkeys == "")
    {
        SendInput, {backspace}
        return
    }
    hotkeys := SubStr(hotkeys, 1, StrLen(hotkeys) - 1)
    if(StrLen(hotkeys) == 0)
    {
        btt()
        return
    }
    update_btt()
    tab_index := 1
    gosub QuickSearch
Return
choose:
    ctrl_hotkey := A_ThisHotkey
    ctrl_num := SubStr(ctrl_hotkey, 0)
    SelectItem(all_file_name[ctrl_num])
    btt()
return

tab::
tab_choose()
return
tab_choose()
{
    if(tab_index == all_file_name.Length())
    {
        tab_index := 0
    }
    tab_index++
    SelectItem(all_file_name[tab_index])
    update_btt()
}
QuickSearch:
    Matched := ""
    if(A_ThisHotkey != "Backspace")
    {
        hotkeys := hotkeys . A_ThisHotkey
    }
    update_btt()
    if(hotkeys != "")
    {
        Path := getPath()
        folder := ComObjCreate("shell.Application").NameSpace(Path)
        items := folder.Items
    }
    all_file_name := []
    all_file_name_str := ""
    index := 1
    for item in items
    {
        if (keyValueFind(item.name, hotkeys))
        {
            all_file_name.push(item.name)
            all_file_name_str .= index ": " item.name "`n"
            index++
        }
    }
    SelectItem(all_file_name[1])
    update_btt()
Return
update_btt()
{
    local
    global hotkeys, all_file_name_str, tab_index
    if(hotkeys == "")
        return
    tmp_str := ""
    Loop, parse, all_file_name_str, `n, `r  ; 在 `r 之前指定 `n, 这样可以同时支持对 Windows 和 Unix 文件的解析.
    {
        s := A_LoopField
        if(A_Index == tab_index)
            s := "[✓]" A_LoopField
        tmp_str .= s "`n"
    }
    btt(hotkeys "`n" tmp_str, A_ScreenWidth/2, A_ScreenHeight/2,,"Style1",{Transparent:200})
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
SelectItem_old(argv)
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
}
;不支持共享盘 \\xxx\
SelectItem(path)
{
    SelectItem_old(path)
    return
    sPath := getPath()
    if(SubStr(sPath, 1 , 6) == "file:\")
    {
        SelectItem_old(path)
        return
    }
    sFullPath := sPath "\" path
    log.info(sFullPath)
    sFullPath := StrReplace(sFullPath, ":\\",":\")
    sFullPath := StrReplace(sFullPath, "C:\用户", "C:\Users")
    log.info(sFullPath)
	FolderPidl := DllCall("shell32\ILCreateFromPath", "Str", sPath)
	DllCall("shell32\SHParseDisplayName", "str", sFullPath, "Ptr", 0, "Ptr*", ItemPidl := 0, "Uint", 0, "Uint*", 0)
	DllCall("shell32\SHOpenFolderAndSelectItems", "Ptr", FolderPidl, "UInt", 1, "Ptr*", ItemPidl, "Int", 0)
	CoTaskMemFree(FolderPidl)
	CoTaskMemFree(ItemPidl)
}
CoTaskMemFree(pv) 
{
   Return   DllCall("ole32\CoTaskMemFree", "Ptr", pv)
}