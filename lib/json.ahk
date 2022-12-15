json_toobj(s)  ; JSon字符串转AHK对象
{
  static rep:=[ ["\\","\u005c"], ["\""",""""], ["\/","/"]
    , ["\r","`r"], ["\n","`n"], ["\t","`t"]
    , ["\b","`b"], ["\f","`f"] ]
  if !(p:=RegExMatch(s, "[\{\[]", r))
    return
  SetBatchLines, % (bch:=A_BatchLines)?"-1":"-1"
  stack:=[], obj:=arr:=[], is_arr:=(r="[")
  , key:=(is_arr ? 1:""), keyok:=0
  While p:=RegExMatch(s, "\S", r, p+StrLen(r))
  {
    if (r="{" or r="[")  ; 如果是 左括号
    {
      stack.Push(is_arr, arr), arr[key]:=[], arr:=arr[key]
      , is_arr:=(r="["), key:=(is_arr ? 1:""), keyok:=0
    }
    else if (r="}" or r="]")  ; 如果是 右括号
    {
      if !stack.Length()
        Break
      arr:=stack.Pop(), is_arr:=stack.Pop()
      , key:=(is_arr ? arr.Length():""), keyok:=0
    }
    else if (r=",")  ; 如果是 逗号
    {
      key:=(is_arr ? Floor(key)+1:""), keyok:=0
    }
    else if (r="""")  ; 如果是 双引号
    {
      if RegExMatch(s, """((?:[^""\\]|\\[\s\S])*)""", r, p)!=p
        Break
      if InStr(r1, "\")
      {
        For k,v in rep
          r1:=StrReplace(r1, v[1], v[2])
        v:="", k:=1
        While i:=RegExMatch(r1, "\\u[0-9A-Fa-f]{4}",, k)
          v.=SubStr(r1,k,i-k) . Chr("0x" SubStr(r1,i+2,4)), k:=i+6
        r1:=v . SubStr(r1,k)
      }
      if (!is_arr and keyok=0)
      {
        p+=StrLen(r)
        if RegExMatch(s, "\s*:", r, p)!=p
          Break
        key:=r1, keyok:=1
      }
      else arr[key]:=r1
    }
    else  ; 如果是 true、false、null、数字
    {
      if RegExMatch(s, "[\w\+\-\.]+", r, p)!=p
        Break
      arr[key]:=(r=="true" ? 1:r=="false" ? 0:r=="null" ? "":r+0)
    }
  }
  SetBatchLines, %bch%
  return obj
}

json_fromobj(obj, space:="")  ; AHK对象转JSon字符串
{
  ;-------------------
  ; 默认不替换 "/-->\/" 与 特殊html字符<、>、&
  ;-------------------
  static rep:=[ ["\\","\"], ["\""",""""]  ; , ["\/","/"]
    ; , ["\\u003c","<"], ["\\u003e",">"], ["\\u0026","&"]
    , ["\r","`r"], ["\n","`n"], ["\t","`t"]
    , ["\b","`b"], ["\f","`f"] ]
  if !IsObject(obj)
  {
    if obj is Number  ; thanks lexikos
      return ([obj].GetCapacity(1) ? """" obj """" : obj)
    ;-------------------
    ; 布尔值在AHK中转为数字了
    ; if (obj=="true" or obj=="false" or obj=="null")
    ;   return obj
    ;-------------------
    For k,v in rep
      obj:=StrReplace(obj, v[2], v[1])
    ;-------------------
    ; 默认不替换 "Unicode字符-->\uXXXX"
    ; While RegExMatch(obj, "[^\x20-\x7e]", k)
    ;   obj:=StrReplace(obj, k, Format("\u{:04x}",Ord(k)))
    ;-------------------
    return """" obj """"
  }
  is_arr:=1  ; 是简单数组
  For k,v in obj
    if (k!=A_Index) and !(is_arr:=0)
      Break
  s:="", space2:=space . "    ", f:=A_ThisFunc
  For k,v in obj
    s.= "`r`n" space2
    . (is_arr ? "" : """" Trim(%f%(k ""),"""") """: ")
    . %f%(v,space2) . ","
  return (is_arr?"[":"{") . Trim(s,",")
    . "`r`n" space . (is_arr?"]":"}")
}
