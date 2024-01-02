#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

^a::
    path := get_explore_all_file_name()
    for k,v in path
    {
        MsgBox,% v

    }
return
get_explore_all_file_name()
{
    static all_file_name := []
	path := getPath()
    if(g_is_finc_status)
        return all_file_name
    else
        all_file_name := []

	Loop Files,% path "\*", DF
	{
		all_file_name.Push(A_LoopFileName)
	}

    g_is_finc_status := true
    return all_file_name
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
        if (window.hwnd == thisHwnd)
        path := StrReplace(window.LocationURL, "file:///", "")
        path := StrReplace(path, "/", "\")
        path := StrReplace(path, "`%20"," ")
    }
    Return path
}
