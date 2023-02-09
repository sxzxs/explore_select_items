;by ahker
;reference https://www.autoahk.com/archives/3274
#include <py>
#include <btt>
#include <json>
#SingleInstance Force

;py.cpp2ahk_open_folder_and_selcet_item("G:\我的AHK程序\我的工程\新建文件夹")
SetWorkingDir, %A_ScriptDir%
CoordMode, ToolTip, Screen
SetBatchLines, -1
run_as_admin()
py.mem_size := 4000
global Items := []
global tab_index := 1
global all_file_name := []
global g_is_finc_status := false
global g_json_path := A_ScriptDir . "/config/settings.json"
global g_config := {}
global g_is_get_all_file_name := true
if(!loadconfig(g_config))
{
    MsgBox,% "Load config"  g_json_path " failed! will exit!!"
    ExitApp
}
 ;注册热键
Hotkey, if, WinActive("ahk_class CabinetWClass") && A_CaretX = ""
;预加载
keyValueFind("}}","a")

global TPosObj, pToken_, @TSF
DrawHXGUI("", "init")
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
    g_is_finc_status := false
    hotkeys := ""
    tab_index := 1
	g_is_get_all_file_name := true
    ;btt()
    DrawHXGUI("a", "")
Return

#if WinActive("ahk_class CabinetWClass") && A_CaretX = ""

Enter::
    SelectItem(all_file_name[tab_index])
    g_is_finc_status := false
    hotkeys := ""
    tab_index := 1
	g_is_get_all_file_name := true
    ;btt()
    DrawHXGUI("a", "")
	SendInput, {enter}
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
        ;btt()
    	DrawHXGUI("a", "")
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
    ;btt()
    DrawHXGUI("a", "")
    hotkeys := ""
    tab_index := 1
return

tab::
tab_choose()
return
+tab::
tab_choose_sub()
return
tab_choose_sub()
{
    if(tab_index == 1)
    {
        tab_index := all_file_name.Length() + 1
    }
    tab_index--
    SelectItem(all_file_name[tab_index])
    update_btt()
}
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
    ;获取所有文件名字
	if(g_is_get_all_file_name)
	{
    	items := get_explore_all_file_name()
		g_is_get_all_file_name := false 
	}
    all_file_name := []
    all_file_name_str := ""
    index := 1
    for k,item in items
    {
        if (keyValueFind(item, hotkeys))
        {
            all_file_name.push(item)
            all_file_name_str .= index ": " item "`n"
            index++
        }
    }
    SelectItem(all_file_name[1])
    update_btt()
Return
update_btt()
{
    local
    global hotkeys, all_file_name_str, all_file_name, tab_index, g_config
	global g_total_show_number := g_config["win_hook_total_show_number"]

    if(hotkeys == "")
        return

    midle_show_number := g_total_show_number / 2
    start_index := 1
    if(tab_index > midle_show_number)
        start_index := ceil(tab_index - midle_show_number)

    have_show := 1
    tmp_str := []
    loop,% g_total_show_number
    {
        if(start_index + A_index - 1 > all_file_name.Length())
            break
        tmp_str.Push((start_index + A_index - 1) ". " substr(all_file_name[start_index + A_index - 1], instr(all_file_name[start_index + A_index - 1], "]") + 1))
    }

	WinGetPos, X, Y, W, H, A
    DrawHXGUI(hotkeys == "" ? "⌨" : hotkeys, tmp_str, X + W / 2, Y + H / 2 
                , tab_index - start_index + 1, 1
                , Font:= g_config["win_hook_font"], BackgroundColor := g_config["win_hook_backgroundcolor"]
                , TextColor := g_config["win_hook_textcolor"], CodeColor := g_config["win_hook_codecolor"]
                , BorderColor := g_config["win_hook_bordercolor"], FocusBackColor := g_config["win_hook_focusbackcolor"]
                , FocusColor := g_config["win_hook_focuscolor"], FontSize := g_config["win_hook_fontsize"]
                , FontBold := g_config["win_hook_fontbold"])
}

keyValueFind(haystack, needle)
{
    ;拼音首字母转换
	;msgbox,% py.double_spell_muti(haystack)
	StringUpper, haystack, haystack
	StringUpper, needle, needle
	findSign:=1
	needleArray := StrSplit(needle, " ")
	Loop,% needleArray.MaxIndex()
	{
		if(needleArray[A_Index] == "")
			Continue
		if(g_config.is_use_xiaohe_double_pinyin)
		{
			if(py.is_all_spell_match(haystack, needleArray[A_Index]) == -1 && py.is_all_spell_init_match(haystack, needleArray[A_Index]) == -1
					&& py.is_double_spell_match(haystack, needleArray[A_Index]) == -1)
			{
				findSign:=0
				break
			}
		}
		else
		{
			if(py.is_all_spell_match(haystack, needleArray[A_Index]) == -1 && py.is_all_spell_init_match(haystack, needleArray[A_Index]) == -1)
			{
				findSign:=0
				break
			}
		}
	}
	return findSign
}
keyValueFind_old(haystack,needle)
{
    ;拼音首字母转换
	;msgbox,% py.double_spell_muti(haystack)
	if(g_config.is_use_xiaohe_double_pinyin)
    	haystack .= py.allspell_muti(haystack) . py.initials_muti(haystack) . py.double_spell_muti(haystack)
	else
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
        if (window.hwnd == thisHwnd)
        path := StrReplace(window.LocationURL, "file:///", "")
        path := StrReplace(path, "/", "\")
        path := StrReplace(path, "`%20"," ")
    }
    Return path
}
;在当前活动资源管理器选择指定名字的文件
SelectItem(argv)
{
    folderView := Shell_GetActiveFolderView()
    item := folderView.Folder.ParseName(argv)
    folderView.SelectItem(item, 13)
	return
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
;获取当前资源管理器所以文件名字
/*
get_explore_all_file_name_old()
{
    static all_file_name := []
    if(g_is_finc_status)
        return all_file_name
    else
        all_file_name := []
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
        all_file_name.push(item.name)
    }
    g_is_finc_status := true
    return all_file_name
}
*/
;不支持共享盘 \\xxx\
SelectItem_old(path)
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
    sFullPath := StrReplace(sFullPath, ":\\",":\")
    sFullPath := StrReplace(sFullPath, "C:\用户", "C:\Users")
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
run_as_admin()
{
    full_command_line := DllCall("GetCommandLine", "str")
    if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
    {
        try
        {
            if A_IsCompiled
                Run *RunAs "%A_ScriptFullPath%" /restart
            else
                Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
        }
        ExitApp
    }
}

Gdip_MeasureString2(pGraphics, sString, hFont, hFormat, ByRef RectF){
	Ptr := A_PtrSize ? "UPtr" : "UInt", VarSetCapacity(RC, 16)
	DllCall("gdiplus\GdipMeasureString", Ptr, pGraphics, Ptr, &sString, "int", -1, Ptr, hFont, Ptr, &RectF, Ptr, hFormat, Ptr, &RC, "uint*", Chars, "uint*", Lines)
	return &RC ? [NumGet(RC, 0, "float"), NumGet(RC, 4, "float"), NumGet(RC, 8, "float"), NumGet(RC, 12, "float")] : 0
}
DrawHXGUI(codetext, Textobj, x:=0, y:=0, localpos:= 0, Textdirection:=0
            , Font:="Microsoft YaHei UI", BackgroundColor := "444444"
            , TextColor := "EEECE2", CodeColor := "C9E47E"
            ,BorderColor := "444444", FocusBackColor := "CAE682"
            , FocusColor := "070C0D", FontSize := 20, FontBold := 0, Showdwxgtip := 0, func_key := "/")
{
	Critical
	global TPosObj, pToken_, @TSF
	static init:=0, Hidefg:=0, DPI:=A_ScreenDPI/96, MonCount:=1, MonLeft, MonTop, MonRight, MonBottom, minw:=0
		, MinLeft:=DllCall("GetSystemMetrics", "Int", 76), MinTop:=DllCall("GetSystemMetrics", "Int", 77)
		, MaxRight:=DllCall("GetSystemMetrics", "Int", 78), MaxBottom:=DllCall("GetSystemMetrics", "Int", 79)
		, xoffset, yoffset, hoffset  ; 左边、上边、编码词条间距离增量
		, fontoffset
	If !IsObject(Textobj){
		If (Textobj="init"){
			If !pToken_&&(!pToken_:=Gdip_Startup()){
				MsgBox, 48, GDIPlus Error!, GDIPlus failed to start. Please ensure you have gdiplus on your system, 5
				ExitApp
			}
			Gui, TSF: -Caption +E0x8080088 +AlwaysOnTop +LastFound +hwnd@TSF -DPIScale
			Gui, TSF: Show, NA
			SysGet, MonCount, MonitorCount
			SysGet, Mon, Monitor
		} Else If (Textobj="shutdown"){
			If (pToken_)
				pToken_:=Gdip_Shutdown(pToken_)
			Gui, TSF:Destroy
		} Else If (Textobj=""){
			hbm := CreateDIBSection(1, 1), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
			UpdateLayeredWindow(@TSF, hdc, 0, 0, 1, 1), SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
			init:=0, minw:=0
		}
		Return
	} Else If (!init){
		If !pToken_&&(!pToken_:=Gdip_Startup()){
			MsgBox, 48, GDIPlus Error!, GDIPlus failed to start. Please ensure you have gdiplus on your system, 5
			ExitApp
		}
		xoffset:=FontSize*0.45, yoffset:=FontSize/2.5, hoffset:=FontSize/3.2, init:=1, fontoffset:=FontSize/16
		
		; 识别扩展屏坐标范围
		x:=(x<MinLeft?MinLeft:x>MaxRight?MaxRight:x), y:=(y<MinTop?MinTop:y>MaxBottom?MaxBottom:y)
		If (MonCount>1){
			If (MonInfo:=MDMF_GetInfo(MDMF_FromPoint(x,y)))
				MonLeft:=MonInfo.Left, MonTop:=MonInfo.Top, MonRight:=MonInfo.Right, MonBottom:=MonInfo.Bottom
			Else
				SysGet, Mon, Monitor
		}
	} Else
		x:=(x<MinLeft?MinLeft:x>MaxRight?MaxRight:x), y:=(y<MinTop?MinTop:y>MaxBottom?MaxBottom:y)
	hFamily := Gdip_FontFamilyCreate(Font), hFont := Gdip_FontCreate(hFamily, FontSize*DPI, FontBold)
	hFormat := Gdip_StringFormatCreate(0x4000), Gdip_SetStringFormatAlign(hFormat, 0x00000800), pBrush := []
	For __,_value in ["Background","Code","Text","Focus","FocusBack"]
		If (!pBrush[%_value%])
			pBrush[%_value%] := Gdip_BrushCreateSolid("0x" (%_value% := SubStr("FF" %_value%Color, -7)))
	pPen_Border := Gdip_CreatePen("0x" SubStr("FF" BorderColor, -7), 1)
	
	w:=MonRight-MonLeft, h:=MonBottom-MonTop
	; 计算界面长宽像素
	hdc := CreateCompatibleDC(), G := Gdip_GraphicsFromHDC(hdc)
	CreateRectF(RC, 0, 0, w-30, h-30), TPosObj:=[]
	If (!minw)
		minw := Gdip_MeasureString2(G, "⌨", hFont, hFormat, RC)[3]
	CodePos := Gdip_MeasureString2(G, codetext "|", hFont, hFormat, RC), CodePos[1]:=xoffset
	, CodePos[2]:=yoffset, mh:=CodePos[2]+CodePos[4], mw:=Max(CodePos[3], minw)
	If (Textdirection=1||InStr(codetext, func_key)){
		mh+=hoffset
		Loop % Textobj.Length()
			TPosObj[A_Index] := Gdip_MeasureString2(G, Textobj[A_Index], hFont, hFormat, RC), TPosObj[A_Index,2]:=mh
			, mh += TPosObj[A_Index,4], mw:=Max(mw,TPosObj[A_Index,3]), TPosObj[A_Index,1]:=CodePos[1]
		Loop % Textobj[0].Length()
			TPosObj[0,A_Index] := Gdip_MeasureString2(G, Textobj[0,A_Index], hFont, hFormat, RC), TPosObj[0,A_Index,2]:=mh
			, mh += TPosObj[0,A_Index,4], mw:=Max(mw,TPosObj[0,A_Index,3]), TPosObj[0,A_Index,1]:=CodePos[1]
		Loop % Textobj.Length()
			TPosObj[A_Index,3]:=mw
		Loop % Textobj[0].Length()
			TPosObj[0,A_Index,3]:=mw
		mw+=2*xoffset, mh+=yoffset
	} Else {
		t:=xoffset, mh+=hoffset
		TPosObj[1] := Gdip_MeasureString2(G, Textobj[1], hFont, hFormat, RC), TPosObj[1,2]:=mh, TPosObj[1,1]:=t, t+=TPosObj[1,3]+hoffset, maxh:=TPosObj[1, 4]
		Loop % (Textobj.Length()-1){
			TPosObj[A_Index+1]:=Gdip_MeasureString2(G, Textobj[A_Index+1], hFont, hFormat, RC), maxh:=Max(maxh, TPosObj[A_Index+1, 4])
			If (t+TPosObj[A_Index+1,3]<=w-30)
				TPosObj[A_Index+1,1]:=t, TPosObj[A_Index+1,2]:=TPosObj[A_Index,2], t+=TPosObj[A_Index+1,3]+hoffset
			Else
				mw:=Max(mw,t), TPosObj[A_Index+1,1]:=xoffset, mh+=TPosObj[A_Index,4], TPosObj[A_Index+1,2]:=mh, t:=xoffset+TPosObj[A_Index+1,3]+hoffset
		}
		mw:=Max(mw,t)
		mh+=maxh
		Loop % Textobj[0].Length()
			TPosObj[0,A_Index] := Gdip_MeasureString2(G, Textobj[0,A_Index], hFont, hFormat, RC), TPosObj[0,A_Index,1]:=xoffset, TPosObj[0,A_Index,2]:=mh, mh += TPosObj[0,A_Index,4], mw:=Max(mw,TPosObj[0,A_Index,3])	
		Loop % Textobj[0].Length()
			TPosObj[0,A_Index,3]:=mw-xoffset
		mw+=xoffset, mh+=yoffset
	}
	Gdip_DeleteGraphics(G), hbm := CreateDIBSection(mw, mh), obm := SelectObject(hdc, hbm)
	G := Gdip_GraphicsFromHDC(hdc), Gdip_SetSmoothingMode(G, 2), Gdip_SetTextRenderingHint(G, 4+(FontSize<21))
	; 背景色
	Gdip_FillRoundedRectangle(G, pBrush[Background], 0, 0, mw-2, mh-2, 5)
	; 编码
	CreateRectF(RC, CodePos[1], CodePos[2], w-30, h-30), Gdip_DrawString(G, codetext, hFont, hFormat, pBrush[Code], RC)
	Loop % Textobj.Length()
		If (A_Index=localpos)
			Gdip_FillRoundedRectangle(G, pBrush[FocusBack], TPosObj[A_Index,1], TPosObj[A_Index,2]-hoffset/3, TPosObj[A_Index,3], TPosObj[A_Index,4]+hoffset*2/3, 3)
			, CreateRectF(RC, TPosObj[A_Index,1], TPosObj[A_Index,2]+fontoffset, w-30, h-30), Gdip_DrawString(G, Textobj[A_Index], hFont, hFormat, pBrush[Focus], RC)
		Else
			CreateRectF(RC, TPosObj[A_Index,1], TPosObj[A_Index,2]+fontoffset, w-30, h-30), Gdip_DrawString(G, Textobj[A_Index], hFont, hFormat, pBrush[Text], RC)
	Loop % Textobj[0].Length()
		CreateRectF(RC, TPosObj[0,A_Index,1], TPosObj[0,A_Index,2], w-30, h-30), Gdip_DrawString(G, Textobj[0,A_Index], hFont, hFormat, pBrush[Text], RC)

	; 定位提示
	If (Showdwxgtip){
		If !pBrush["FFFF0000"]
			pBrush["FFFF0000"] := Gdip_BrushCreateSolid("0xFFFF0000")	; 红色
		CreateRectF(RC, TPosObj[1,1], TPosObj[1,2]+FontSize*0.70, w-30, h-30)
		Gdip_DrawString(G, "   " SubStr("　ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ",1,StrLen(jichu_for_select_Array[1,2])), hFont, hFormat, pBrush["FFFF0000"], RC)
	}
	; 边框、分隔线
	Gdip_DrawRoundedRectangle(G, pPen_Border, 0, 0, mw-2, mh-2, 5)
	Gdip_DrawLine(G, pPen_Border, xoffset, CodePos[4]+CodePos[2], mw-xoffset, CodePos[4]+CodePos[2])
	UpdateLayeredWindow(@TSF, hdc, tx:=Min(x, Max(MonLeft, MonRight-mw)), ty:=Min(y, Max(MonTop, MonBottom-mh)), mw, mh)
	SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc), Gdip_DeleteGraphics(G)

	Gdip_DeleteStringFormat(hFormat), Gdip_DeleteFont(hFont), Gdip_DeleteFontFamily(hFamily)
	For __,_value in pBrush
		Gdip_DeleteBrush(_value)
	Gdip_DeletePen(pPen_Border)
	WinSet, AlwaysOnTop, On, ahk_id%@TSF%
}

loadconfig(ByRef config)
{
    Global g_json_path
    config := ""
    FileRead, OutputVar,% g_json_path
    config := json_toobj(outputvar)
    if(config == "")
        return false
    return true
}
Shell_GetActiveFolderView() {
    hwndFore := WinExist("A")
    windows := ComObjCreate("{9BA05972-F6A8-11CF-A442-00A0C90A8F39}")
    for webBrowser in windows
        if webBrowser.Hwnd == hwndFore
            return webBrowser.Document

	hwndBuf := {}
	hwndBuf.size := 4
	hwndBuf.SetCapacity("data", hwndBuf.size)
	hwndBuf.ptr := hwndBuf.GetAddress("data")
	hwndBuf.is_buffer := true
    ;hwndBuf := Buffer(4)

    if webBrowser := windows.FindWindowSW(0, 0, 8, ComObject(0x4003, hwndBuf.Ptr), 1) {
        hwndDesktop := NumGet(hwndBuf.ptr, "int")
        if hwndFore == hwndDesktop
            return webBrowser.Document
        if WinGetClass(hwndFore) == "WorkerW" {
            hwndFocus := ControlGetFocus(hwndFore)
            if hwndFocus && WinGetClass(hwndFocus) == "SysListView32"
                return webBrowser.Document
        }
    }
}
ControlGetFocus(ctrl)
{
	ControlGetFocus, OutputVar, ahk_id %ctrl%
	return OutputVar
}

WinGetClass(hwnd)
{
	WinGetClass, class, ahk_id %hwnd%
	return class
}