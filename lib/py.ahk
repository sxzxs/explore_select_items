class py
{
    static LOG4AHK_G_MY_DLL_USE_MAP := {"cpp2ahk.dll" : {"chinese_convert_pinyin_initials" : 0, "chinese_convert_pinyin_allspell" : 0
															,"chinese_convert_pinyin_allspell_muti" : 0
															, "chinese_convert_pinyin_allspell_muti_ptr" : 0
															, "chinese_convert_pinyin_initials_muti" : 0
															, "chinese_convert_pinyin_initials_muti_ptr" : 0
															, "chinese_convert_double_pinyin_muti" : 0
															, "chinese_convert_double_pinyin_muti_ptr" : 0
															, "cpp2ahk_open_folder_and_selcet_item" : 0
															, "cpp2ahk_is_all_py_match" : 0
															, "cpp2ahk_is_all_py_match" : 0
															, "cpp2ahk_is_all_py_init_match" : 0
															, "cpp2ahk_is_double_py_match" : 0}
															, "is_load" : 0}
    static is_dll_load := false
    static _ := this.log4ahk_load_all_dll_path()
    static mem_size := 2024000
    log4ahk_load_all_dll_path()
    {
        local
        SplitPath,A_LineFile,,dir
        path := ""
        lib_path := dir
        if(A_IsCompiled)
        {
            path := A_PtrSize == 4 ? A_ScriptDir . "\lib\dll_32\" : A_ScriptDir . "\lib\dll_64\"
            lib_path := A_ScriptDir . "\lib"
        }
        else
        {
            path := (A_PtrSize == 4) ? dir . "\dll_32\" : dir . "\dll_64\"
        }
        dllcall("SetDllDirectory", "Str", path)
        for k,v in this.LOG4AHK_G_MY_DLL_USE_MAP
        {
            for k1, v1 in v 
            {
                this.LOG4AHK_G_MY_DLL_USE_MAP[k][k1] := DllCall("GetProcAddress", "Ptr", DllCall("LoadLibrary", "Str", k, "Ptr"), "AStr", k1, "Ptr")
            }
        }
        this.is_dll_load := true
    }
	cpp2ahk_open_folder_and_selcet_item(path)
	{
        if(this.is_dll_load == false)
        {
            this.log4ahk_load_all_dll_path()
        }
        rtn := DllCall(this.LOG4AHK_G_MY_DLL_USE_MAP["cpp2ahk.dll"]["cpp2ahk_open_folder_and_selcet_item"], "Str", path, "Cdecl Int")
        return rtn
	}
	is_double_spell_match(all_str, filter)
	{
        if(this.is_dll_load == false)
        {
            this.log4ahk_load_all_dll_path()
        }
        py_StrPutVar(all_str, buf1, "UTF-16")
        py_StrPutVar(filter, buf2, "UTF-16")
        rtn := DllCall(this.LOG4AHK_G_MY_DLL_USE_MAP["cpp2ahk.dll"]["cpp2ahk_is_double_py_match"], "Str", buf1, "Str", buf2, "Cdecl Int")
        return rtn
	}
	is_all_spell_match(all_str, filter)
	{
        if(this.is_dll_load == false)
        {
            this.log4ahk_load_all_dll_path()
        }
        py_StrPutVar(all_str, buf1, "UTF-16")
        py_StrPutVar(filter, buf2, "UTF-16")
        rtn := DllCall(this.LOG4AHK_G_MY_DLL_USE_MAP["cpp2ahk.dll"]["cpp2ahk_is_all_py_match"], "Str", buf1, "Str", buf2, "Cdecl Int")
        return rtn
	}
	is_all_spell_init_match(all_str, filter)
	{
        if(this.is_dll_load == false)
        {
            this.log4ahk_load_all_dll_path()
        }
        py_StrPutVar(all_str, buf1, "UTF-16")
        py_StrPutVar(filter, buf2, "UTF-16")
        rtn := DllCall(this.LOG4AHK_G_MY_DLL_USE_MAP["cpp2ahk.dll"]["cpp2ahk_is_all_py_init_match"], "Str", buf1, "Str", buf2, "Cdecl Int")
        return rtn
	}
    allspell(in_str)
    {
        if(this.is_dll_load == false)
        {
            this.log4ahk_load_all_dll_path()
        }
        out_str := ""
        VarSetCapacity(out_str,0)
        VarSetCapacity(out_str,this.mem_size)

        py_StrPutVar(in_str, buf, "CP0")
        rtn := DllCall(this.LOG4AHK_G_MY_DLL_USE_MAP["cpp2ahk.dll"]["chinese_convert_pinyin_allspell"],"Str", buf, "Str", out_str,"Cdecl Int")
        rtn := StrGet(&out_str, this.mem_size,"UTF-8")
        return rtn
    }
    double_spell_muti(in_str)
    {
        if(this.is_dll_load == false)
        {
            this.log4ahk_load_all_dll_path()
        }
        out_str := ""
        VarSetCapacity(out_str,0)
        VarSetCapacity(out_str,this.mem_size)

        py_StrPutVar(in_str, buf, "UTF-16")
        rtn := DllCall(this.LOG4AHK_G_MY_DLL_USE_MAP["cpp2ahk.dll"]["chinese_convert_double_pinyin_muti"],"Str", buf, "Str", out_str,"Cdecl Int")
        rtn := StrGet(&out_str, this.mem_size,"UTF-8")
        return rtn
    }

    double_spell_muti_ptr(in_str)
	{
        if(this.is_dll_load == false)
        {
            this.log4ahk_load_all_dll_path()
        }
        out_str := ""
        VarSetCapacity(out_str,0)
        VarSetCapacity(out_str,this.mem_size)

        py_StrPutVar(in_str, buf, "UTF-16")
        ptr := DllCall(this.LOG4AHK_G_MY_DLL_USE_MAP["cpp2ahk.dll"]["chinese_convert_double_pinyin_muti_ptr"],"Str", buf, "Cdecl ptr")
		if(ptr != 0)
		{
        	rtn := StrGet(ptr,,"UTF-8")
			this.free_ptr(ptr)
		}
		else
			rtn := ""
        return rtn
	}
    allspell_muti(in_str)
    {
        if(this.is_dll_load == false)
        {
            this.log4ahk_load_all_dll_path()
        }
        out_str := ""
        VarSetCapacity(out_str,0)
        VarSetCapacity(out_str,this.mem_size)

        py_StrPutVar(in_str, buf, "UTF-16")
        rtn := DllCall(this.LOG4AHK_G_MY_DLL_USE_MAP["cpp2ahk.dll"]["chinese_convert_pinyin_allspell_muti"],"Str", buf, "Str", out_str,"Cdecl Int")
        rtn := StrGet(&out_str, this.mem_size,"UTF-8")
        return rtn
    }
	allspell_muti_ptr(in_str)
	{
        if(this.is_dll_load == false)
        {
            this.log4ahk_load_all_dll_path()
        }
        out_str := ""
        VarSetCapacity(out_str,0)
        VarSetCapacity(out_str,this.mem_size)
        py_StrPutVar(in_str, buf, "UTF-16")

        ptr := DllCall(this.LOG4AHK_G_MY_DLL_USE_MAP["cpp2ahk.dll"]["chinese_convert_pinyin_allspell_muti_ptr"],"Str", buf,"Cdecl Ptr")
		if(ptr != 0)
		{
        	rtn := StrGet(ptr,,"UTF-8")
			this.free_ptr(ptr)
		}
		else
			rtn := ""
        return rtn
	}
	free_ptr(ptr)
	{
        DllCall(this.LOG4AHK_G_MY_DLL_USE_MAP["cpp2ahk.dll"]["cpp2ahk_free_ptr"],"ptr", ptr)
	}
    initials_muti(in_str)
    {
        if(this.is_dll_load == false)
        {
            this.log4ahk_load_all_dll_path()
        }
        out_str := ""
        VarSetCapacity(out_str,0)
        VarSetCapacity(out_str,this.mem_size)

        py_StrPutVar(in_str, buf, "UTF-16")
        rtn := DllCall(this.LOG4AHK_G_MY_DLL_USE_MAP["cpp2ahk.dll"]["chinese_convert_pinyin_initials_muti"],"Str", buf, "Str", out_str,"Cdecl Int")
        rtn := StrGet(&out_str, this.mem_size,"UTF-8")
        return rtn
    }
    initials_muti_ptr(in_str)
    {
        if(this.is_dll_load == false)
        {
            this.log4ahk_load_all_dll_path()
        }
        py_StrPutVar(in_str, buf, "UTF-16")
        ptr := DllCall(this.LOG4AHK_G_MY_DLL_USE_MAP["cpp2ahk.dll"]["chinese_convert_pinyin_initials_muti_ptr"],"Str", buf, "Cdecl Ptr")
		if(ptr != 0)
		{
        	rtn := StrGet(ptr,,"UTF-8")
			this.free_ptr(ptr)
		}
		else
			rtn := ""
        return rtn
    }
    initials(in_str)
    {
        if(this.is_dll_load == false)
        {
            this.log4ahk_load_all_dll_path()
        }
        out_str := ""
        VarSetCapacity(out_str,0)
        VarSetCapacity(out_str,this.mem_size)

        py_StrPutVar(in_str, buf, "CP0")
        rtn := DllCall(this.LOG4AHK_G_MY_DLL_USE_MAP["cpp2ahk.dll"]["chinese_convert_pinyin_initials"],"Str", buf, "Str", out_str,"Cdecl Int")
        rtn := StrGet(&out_str, this.mem_size,"UTF-8")
        return rtn
    }
}

py_StrPutVar(string, ByRef var, encoding)
{
    ; 确定容量.
    VarSetCapacity( var, StrPut(string, encoding)
        ; StrPut 返回字符数, 但 VarSetCapacity 需要字节数.
        * ((encoding="utf-16"||encoding="cp1200") ? 2 : 1) )
    ; 复制或转换字符串.
    return StrPut(string, &var, encoding)
}