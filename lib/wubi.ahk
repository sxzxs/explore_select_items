class wubi
{
    __New(bin_path := "wubi.bin")
    {
        if(!FileExist(bin_path))
        {
            MsgBox, 五笔词库 %bin_path% 不存在!!
            return
        }
        this.bin_path := bin_path
        this.map_wubi := this.ObjLoad(bin_path)
    }
    code(str)
    {
        rtn_code := ""
        word_array := StrSplit(str)
        for k,v in word_array
        {
            if(this.map_wubi.HasKey(v))
                rtn_code .= this.map_wubi[v]
            else
                rtn_code .= v
        }
        return rtn_code
    }
    ObjLoad(addr,objects:=0){
    If (addr+0=""){ ; FileRead Mode
        If !FileExist(addr)
        return
        FileGetSize,sz,%addr%
        FileRead,v,*c %addr%
        If ErrorLevel||!sz
        return
        addr:=&v
    }
    obj:=[],end:=addr+8+(sz:=NumGet(addr+0,"Int64")),addr+=8
    if !objects
        objects:={0:obj}
    else objects.Push(obj)
    While addr<end{ ; 9 = Int64 for size and Char for type
        If !(kIsString:=0)&&NumGet(addr+0,"Char")=-12
        k:=objects[NumGet(addr+1,"Int64")],addr+=9
        else if NumGet(addr+0,"Char")=-11
        k:=this.ObjLoad(addr+1,objects),addr+=9+NumGet(addr+1,"Int64")
        else if NumGet(addr+0,"Char")=-10
        kIsString:=true,sz:=NumGet(addr+1,"Int64"),k:=StrGet(addr+9),addr+=sz+9
        else k:=NumGet(addr+1,SubStr("Char  UChar Short UShortInt   UInt  Int64 UInt64Double",(sz:=-NumGet(addr+0,"Char"))*6-5,6)),addr+=SubStr("112244888",sz,1)+1
        If NumGet(addr+0,"Char")= 12
        obj[kIsString?"" k:k]:=objects[NumGet(addr+1,"Int64")],addr+=9
        else if NumGet(addr+0,"Char")= 11
        obj[kIsString?"" k:k]:=this.ObjLoad(addr+1,objects),addr+=9+NumGet(addr+1,"Int64")
        else if NumGet(addr+0,"Char")= 10
        obj[kIsString?"" k:k]:=StrGet(addr+9),obj.SetCapacity(kIsString?"" k:k,sz:=NumGet(addr+1,"Int64")),DllCall("RtlMoveMemory","PTR",obj.GetAddress(kIsString?"" k:k),"PTR",addr+9,"PTR",sz),addr+=sz+9
        else obj[kIsString?"" k:k]:=NumGet(addr+1,SubStr("Char  UChar Short UShortInt   UInt  Int64 UInt64Double",(sz:=NumGet(addr+0,"Char"))*6-5,6)),addr+=SubStr("112244888",sz,1)+1
    }
    return obj
    }
    ObjDump(obj,ByRef var:="",mode:=0){
    If IsObject(var){ ; FileAppend mode
        If FileExist(obj){
        FileDelete,%obj%
        If ErrorLevel
            return
        }
        f:=FileOpen(obj,"rw-rwd","CP0"),VarSetCapacity(v,sz:=this.RawObjectSize(var,mode)+8,0)
        ,this.RawObject(var,NumPut(sz-8,0+(ptr:=&v),"Int64"),mode),count:=sz//65536
        Loop % count
        f.RawWrite(ptr+0,65536),ptr+=65536
        return sz,f.RawWrite(ptr+0,Mod(sz,65536)),f.Close()
    } else if !IsByRef(var)
            return this.RawObjectSize(obj,mode)+8
    else return sz,VarSetCapacity(var,sz:=this.RawObjectSize(obj,mode)+8,0),this.RawObject(obj,NumPut(sz-8,&var,"Int64"),mode)
    }
    RawObject(obj,addr,buf:=0,objects:=0){
    ; Type.Enum:    Char.1 UChar.2 Short.3 UShort.4 Int.5 UInt.6 Int64.7 UInt64.8 Double.9 String.10 Object.11
    ; Negative for keys and positive for values
    if !objects
        objects:={(""):0,(obj):0}
    else objects[obj]:=(++objects[""])
    for k,v in obj
    { ; 9 = Int64 for size and Char for type
        If !(kIsString:=0)&&IsObject(k){
        If objects.HasKey(k)
            NumPut(-12,addr+0,"Char"),NumPut(objects[k],addr+1,"Int64"),addr+=9
        else NumPut(-11,addr+0,"Char"),NumPut(sz:=this.RawObjectSize(k,buf),addr+1,"Int64"),this.RawObject(k,addr+9,buf,objects),addr+=sz+9
        }else if (k+0=""||k ""!=k+0||k~="\s")
        kIsString:=true,NumPut(-10,addr+0,"Char"),NumPut(sz:=StrPut(k,addr+9)*2,addr+1,"Int64"),addr+=sz+9
        else NumPut( InStr(k,".")?-9:k>4294967295?-8:k>65535?-6:k>255?-4:k>-1?-2:k>-129?-1:k>-32769?-3:k>-2147483649?-5:-7,addr+0,"Char")
            ,NumPut(k,addr+1,InStr(k,".")?"Double":k>4294967295?"UInt64":k>65535?"UInt":k>255?"UShort":k>-1?"UChar":k>-129?"Char":k>-32769?"Short":k>-2147483649?"Int":"Int64")
            ,addr+=InStr(k,".")||k>4294967295?9:k>65535?5:k>255?3:k>-129?2:k>-32769?3:k>-2147483649?5:9
        If IsObject(v){
        if objects.HasKey(v)
            NumPut( 12,addr+0,"Char"),NumPut(objects[v],addr+1,"Int64"),addr+=9
        else NumPut( 11,addr+0,"Char"),NumPut(sz:=this.RawObjectSize(v,buf),addr+1,"Int64"),this.RawObject(v,addr+9,buf,objects),addr+=sz+9
        }else if (v+0=""||v ""!=v+0||v~="\s")
        NumPut( 10,addr+0,"Char"),NumPut(sz:=buf?obj.GetCapacity(kIsString?"" k:k):StrPut(v)*2,addr+1,"Int64"),DllCall("RtlMoveMemory","PTR",addr+9,"PTR",buf?obj.GetAddress(kIsString?"" k:k):&v,"PTR",sz),addr+=sz+9
        else NumPut(InStr(v,".")?9:v>4294967295?8:v>65535?6:v>255?4:v>-1?2:v>-129?1:v>-32769?3:v>-2147483649?5:7,addr+0,"Char")
            ,NumPut(v,addr+1,InStr(v,".")?"Double":v>4294967295?"UInt64":v>65535?"UInt":v>255?"UShort":v>-1?"UChar":v>-129?"Char":v>-32769?"Short":v>-2147483649?"Int":"Int64")
            ,addr+=InStr(v,".")||v>4294967295?9:v>65535?5:v>255?3:v>-129?2:v>-32769?3:v>-2147483649?5:9
    }
    }
    RawObjectSize(obj,buf:=0,objects:=0){
    if !objects
        objects:={(obj):1}
    else if !objects.HasKey(obj)
        objects[obj]:=1
    sz:=0
    for k,v in obj
    {
        If !(kIsString:=0)&&IsObject(k)
        sz+=objects.HasKey(k)?9:this.RawObjectSize(k,buf,objects)+9
        else if (k+0=""||k ""!=k+0||k~="\s")
        kIsString:=true,sz+=StrPut(k)*2+9
        else sz+=InStr(k,".")||k>4294967295?9:k>65535?5:k>255?3:k>-129?2:k>-32769?3:k>-2147483649?5:9
        If IsObject(v)
        sz+=objects.HasKey(v)?9:this.RawObjectSize(v,buf,objects)+9
        else if (v+0=""||v ""!=v+0||v~="\s")
        sz+=(buf?obj.GetCapacity(kIsString?"" k:k):StrPut(v)*2)+9
        else sz+=InStr(v,".")||v>4294967295?9:v>65535?5:v>255?3:v>-129?2:v>-32769?3:v>-2147483649?5:9
    }
    return sz
    }
}
