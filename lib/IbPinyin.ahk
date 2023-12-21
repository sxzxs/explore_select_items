; IbPinyinLib
; https://github.com/Chaoses-Ib/IbPinyinLib
; v1 change by zzZ

global IbPinyin_Unicode := 0x8
global IbPinyin_Ascii := 0x2
global IbPinyin_AsciiTone := 0x4
global IbPinyin_AsciiFirstLetter := 0x1
global IbPinyin_DiletterAbc := 0x10
global IbPinyin_DiletterJiajia := 0x20
global IbPinyin_DiletterMicrosoft := 0x40
global IbPinyin_DiletterThunisoft := 0x80
global IbPinyin_DiletterXiaohe := 0x100
global IbPinyin_DiletterZrm := 0x200

IbPinyin_IsMatch(pattern, haystack, notations := 0x3)
{
    return DllCall("IbPinyin\ib_pinyin_is_match_u16", "str", pattern, "int64", StrLen(pattern), "str", haystack, "int64", StrLen(haystack), "UInt", notations, "Cdecl Int") == 1
}

class LbPinyin
{
    static _new := LbPinyin.init()
    init() 
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
        DllCall("LoadLibrary", "Str", "IbPinyin.dll", "Ptr")
    }
}