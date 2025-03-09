#Requires AutoHotkey v2.0.11+

#Include C:\Program Files\AutoHotkey\Lib\_JXON.ahk

; Fonction pour détecter le style de saut de ligne
DetectLineEndingStyle(text)
  {
   if (InStr(text, "`r`n"))
     {
      return "windows"
     }
    else
      if (InStr(text, "`n"))
        {
         return "unix"
        }
      else
        {
         return "unix"  ; Par défaut Unix si aucun saut de ligne trouvé
        }
  }

; Fonction pour convertir les sauts de ligne en séquence \n selon le style source
NormalizeToBackslashN(text, sourceStyle)
  {
   if (sourceStyle = "windows")
     {
      return StrReplace(text, "`r`n", "\n")
     }
    else
     {
      return text  ; Déjà au format souhaité
     }
  }

; Fonction pour restaurer les sauts de ligne depuis la séquence \n vers le style cible
RestoreFromBackslashN(text, targetStyle)
  {
   if (targetStyle = "windows")
     {
      return StrReplace(text, "\n", "`r`n")
     }
    else
     {
      return text  ; Garder le format actuel
     }
  }

; Fonction pour échapper les caractères spéciaux JSON
JsonEscape(str)
  {
   escaped := StrReplace(str, "\", "\\")
   escaped := StrReplace(escaped, """", "\""")
   escaped := StrReplace(escaped, "/", "\/")
   escaped := StrReplace(escaped, "`b", "\b")
   escaped := StrReplace(escaped, "`f", "\f")
   escaped := StrReplace(escaped, "`n", "\n")
   escaped := StrReplace(escaped, "`r", "\r")
   escaped := StrReplace(escaped, "`t", "\t")
   return escaped
  }

; Fonction pour désechapper les caractères spéciaux JSON
JsonUnescape(str)
  {
   unescaped := StrReplace(str, "\\", "\")
   unescaped := StrReplace(unescaped, "\""", """")
   unescaped := StrReplace(unescaped, "\/", "/")
   unescaped := StrReplace(unescaped, "\b", "`b")
   unescaped := StrReplace(unescaped, "\f", "`f")
   unescaped := StrReplace(unescaped, "\n", "`n")
   unescaped := StrReplace(unescaped, "\r", "`r")
   unescaped := StrReplace(unescaped, "\t", "`t")
   return unescaped
  }

BinArr_ToString(BinArr, Encoding := "UTF-8")
  {
   ; https://gist.github.com/tmplinshi/a97d9a99b9aa5a65fd20
   ; https://www.autohotkey.com/boards/viewtopic.php?p=100984#p100984
   oADO := ComObject("ADODB.Stream")
   oADO.Type := 1 ; adTypeBinary
   oADO.Mode := 3 ; adModeReadWrite
   
   oADO.Open
   
   oADO.Write(BinArr)
   
   oADO.Position := 0, oADO.Type := 2, oADO.Charset := Encoding ; adTypeText
   resp := oADO.ReadText()
   oADO.Close
   Return resp
  }

^*::
  {
   url := "https://api.mistral.ai/v1/agents/completions"

   old := A_Clipboard
   A_Clipboard := ""
   Send("^a")
   Send("^c")
   ClipWait()

   ; Détecter le style de saut de ligne original
   originalStyle := DetectLineEndingStyle(A_Clipboard)
   
   ; Convertir les sauts de ligne en séquence \n
   normalizedContent := NormalizeToBackslashN(A_Clipboard, originalStyle)

   ; Échapper le contenu avant de l'envoyer (sans traiter les sauts de ligne)
   escapedContent := JsonEscape(normalizedContent)
   data := '{ "agent_id": "ag:f64a9592:20250302:carla:cb28af32", "messages": [ { "role": "user", "content": "' . escapedContent . '" } ] }'
      
   http := ComObject("WinHttp.WinHttpRequest.5.1")
   http.Open("POST", url)
   http.SetRequestHeader("Authorization", "Bearer NZH6j2F11hefHAhO6yxo92RNe0PtfhCm")
   http.SetRequestHeader("Content-Type", "application/json")
   http.SetRequestHeader("Accept", "application/json")
   http.SetRequestHeader("Accept-Charset", "UTF-8")
   http.Send(data)
   http.WaitForResponse()
 
   if (http.Status != 200)
     {
      MsgBox("Erreur : " . http.Status . " => " . http.responseBody)
     }
    else
     {
      text := BinArr_ToString(http.ResponseBody, "UTF-8")
      arbre := jxon_load(&text)
      
      ; Désechapper le contenu reçu
      content := arbre["choices"][1]["message"]["content"]
      unescapedContent := JsonUnescape(content)
      
      ; Restaurer les sauts de ligne depuis la séquence \n vers le format original
      unescapedContent := RestoreFromBackslashN(unescapedContent, originalStyle)
      
      A_Clipboard := unescapedContent
      Send("^v")
     }

   Sleep(100)
   A_Clipboard := old
  }