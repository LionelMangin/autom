#Requires AutoHotkey v2.0.11+
#Include C:\Program Files\AutoHotkey\Lib\_JXON.ahk
#Include config.ahk

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
   static jsonEscapes := Map(
     "\", "\\",        ; Backslash
     '"', '\"',        ; Guillemets doubles
     "/", "\/",        ; Slash (optionnel mais conventionnel)
     "`b", "\b",       ; Backspace
     "`f", "\f",       ; Form feed
     "`n", "\n",       ; Nouvelle ligne
     "`r", "\r",       ; Retour chariot
     "`t", "\t"        ; Tabulation
   )
   result := ""
   i := 1
   while (i <= StrLen(str))
     {
      char := SubStr(str, i, 1)
      if (jsonEscapes.Has(char))
        result .= jsonEscapes[char]
      else
        result .= char
      i++
     }
   return result
  }

; Fonction pour désechapper les caractères spéciaux JSON
JsonUnescape(str)
  {
   result := ""
   i := 1
   while (i <= StrLen(str))
     {
      char := SubStr(str, i, 1)
      if (char = "\")
        {
         if (i < StrLen(str))
           {
            nextChar := SubStr(str, i + 1, 1)
            if (nextChar = "\")
              {
               result .= "\"
               i += 2
              }
            else if (nextChar = '"')
              {
               result .= '"'
               i += 2
              }
            else if (nextChar = "/")
              {
               result .= "/"
               i += 2
              }
            else if (nextChar = "b")
              {
               result .= "`b"
               i += 2
              }
            else if (nextChar = "f")
              {
               result .= "`f"
               i += 2
              }
            else if (nextChar = "n")
              {
               result .= "`n"
               i += 2
              }
            else if (nextChar = "r")
              {
               result .= "`r"
               i += 2
              }
            else if (nextChar = "t")
              {
               result .= "`t"
               i += 2
              }
            else
              {
               result .= char
               i++
              }
           }
         else
           {
            result .= char
            i++
           }
        }
      else
        {
         result .= char
         i++
        }
     }
   return result
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

; Fonction factorisée pour envoyer une requête HTTP avec timeout
SendHttpRequest(url, data, headers, timeoutMs := 30000)
  {
   try
     {
      http := ComObject("WinHttp.WinHttpRequest.5.1")
      http.Open("POST", url)
      for key, value in headers
        http.SetRequestHeader(key, value)
      ; Configuration des timeouts en millisecondes
      ; Option 4 = ResolveTimeout, Option 5 = ConnectTimeout
      ; Option 6 = SendTimeout, Option 7 = ReceiveTimeout
      http.SetTimeouts(timeoutMs, timeoutMs, timeoutMs, timeoutMs)
      http.Send(data)
      ; WaitForResponse attend un paramètre en SECONDES (ou -1 pour infini)
      ; Convertir ms en secondes correctement
      timeoutSeconds := timeoutMs / 1000
      http.WaitForResponse(timeoutSeconds)
      if (http.Status != 200)
        {
         errorText := BinArr_ToString(http.ResponseBody, "UTF-8")
         return Map("error", "Erreur : " . http.Status . " => " . errorText, "status", http.Status)
        }
       else
        {
         return Map("text", BinArr_ToString(http.ResponseBody, "UTF-8"), "status", http.Status)
        }
     }
   catch as err
     {
      return Map("error", "Timeout ou erreur de connexion: " . err.Message, "status", 0)
     }
  }

; Fonction d'envoi à l'API avec gestion de timeout
SendToAPI(agent, escapedContent)
  {
   if (agent != "Carla")
     {
      agent_id := API_AGENT_ID_MAEL
     }
    else
     {
      agent_id := API_AGENT_ID_Carla
     }
   data := '{ "agent_id": "' . agent_id . '", "messages": [ { "role": "user", "content": "' . escapedContent . '" } ] }'
   headers := Map(
     "Authorization", "Bearer " . API_KEY,
     "Content-Type", "application/json",
     "Accept", "application/json",
     "Accept-Charset", "UTF-8"
   )
   result := SendHttpRequest(API_URL, data, headers)
   if (result.Has("error"))
     {
      MsgBox(result["error"])
      return ""
     }
    else
     {
      return result["text"]
     }
  }

; Fonction d'envoi local pour LMStudio avec gestion de timeout
SendToLMStudio(agent, escapedContent)
  {
   ; Lire l'agent_id depuis le fichier correspondant
   if (agent != "Carla")
     {
      file := FileRead(A_ScriptDir . "\Maël.prt")
     }
    else
     {
      file := FileRead(A_ScriptDir . "\Carla.prt")
     }
   prompt := StrReplace(file, "`n", " ")
   data := '{ "model": "' . LMSTUDIO_MODEL . '", "temperature": 0.3, "messages": [ { "role": "system", "content": "' . prompt . '" }, { "role": "user", "content": "' . escapedContent . '" } ] }'
   headers := Map(
     "Content-Type", "application/json",
     "Accept", "application/json",
     "Accept-Charset", "UTF-8"
   )
   result := SendHttpRequest(LMSTUDIO_URL, data, headers)
   if (result.Has("error"))
     {
      MsgBox(result["error"])
      return ""
     }
    else
     {
      return result["text"]
     }
  }

; Fonction de traitement commune
Process(agent, text)
  {
   ; Vérifier si c'est la commande de rechargement
   if (Trim(text) = "reloas") {
      Reload
      return ""
   }
   ; Détecter le style de saut de ligne original
   originalStyle := DetectLineEndingStyle(text)
   ; Convertir les sauts de ligne en séquence \n
   normalizedContent := NormalizeToBackslashN(text, originalStyle)
   ; Échapper le contenu avant de l'envoyer (sans traiter les sauts de ligne)
   escapedContent := JsonEscape(normalizedContent)
   ; Retourner les données préparées et le style original
   result := Map()
   result["content"] := escapedContent
   result["originalStyle"] := originalStyle
   return result
  }

; Fonction factorisée pour le traitement et l'envoi
ProcessAndSend(agent, useAPI := true)
  {
   old := A_Clipboard
   A_Clipboard := ""
   Send("^c")
   ClipWait()
   ; Traiter le contenu
   originaltext := A_Clipboard
   processed := Process(agent, originaltext)
   if (processed = "")
     {
      A_Clipboard := old
      return
     }
   ; Envoyer selon le mode
   if (useAPI)
     {
      response := SendToAPI(agent, processed["content"])
     }
    else
     {
      response := SendToLMStudio(agent, processed["content"])
     }
   ; Traiter la réponse
   if (response != "")
     {
      arbre := Jxon_Load(&response)
      content := arbre["choices"][1]["message"]["content"]
      unescapedContent := JsonUnescape(content)
      unescapedContent := RestoreFromBackslashN(unescapedContent, processed["originalStyle"])
      ; des fois en local il y a un ajout d'un espace au début
      if (SubStr(unescapedContent, 1, 1) == " " && SubStr(originaltext, 1, 1) != " ")
        {
          unescapedContent := SubStr(unescapedContent, 2)
        }
      A_Clipboard := unescapedContent
      Send("^v")
     }
   Sleep(100)
   A_Clipboard := old
  }

; Raccourcis clavier
^!*::
{
   Send("^a")
   ProcessAndSend("Carla", true)
}

^!+*::
{
   ProcessAndSend("Carla", true)
}

^!$::
{
   Send("^a")
   ProcessAndSend("Maël", true)
}

^!+$::
{
   ProcessAndSend("Maël", true)
}

^*::
{
   Send("^a")
   ProcessAndSend("Carla", false)
}

^+*::
{
   ProcessAndSend("Carla", false)
}

^$::
{
   Send("^a")
   ProcessAndSend("Maël", false)
}

^+$::
{
   ProcessAndSend("Maël", false)
}
