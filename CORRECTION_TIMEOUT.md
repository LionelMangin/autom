# Correction du Timeout HTTP

## Problèmes identifiés

La modification précédente tentait d'augmenter le temps d'attente sur les requêtes HTTP mais contenait plusieurs erreurs :

### 1. **Conversion incorrecte ms → secondes**
```ahk
http.WaitForResponse(timeoutMs // 1000) ; Division entière problématique
```
- Utilisait l'opérateur `//` (division entière) au lieu de `/` (division normale)
- `WaitForResponse` attend des **secondes**, pas des millisecondes

### 2. **Utilisation incorrecte des Options**
```ahk
http.Option(12) := timeoutMs ; Incorrect
http.Option(13) := timeoutMs ; Incorrect
```
- Les options 12 et 13 ne sont pas les bonnes pour configurer les timeouts
- Il faut utiliser `SetTimeouts()` avec les 4 paramètres appropriés

### 3. **Vérification readyState inutile**
```ahk
if (http.readyState != 4)
```
- Après `WaitForResponse`, cette vérification n'a pas de sens
- `WaitForResponse` est bloquant et attend la fin de la requête

### 4. **Absence de gestion d'erreur**
- Aucun bloc try/catch pour capturer les exceptions de timeout

## Solution implémentée

```ahk
SendHttpRequest(url, data, headers, timeoutMs := 30000)
  {
   try
     {
      http := ComObject("WinHttp.WinHttpRequest.5.1")
      http.Open("POST", url)
      for key, value in headers
        http.SetRequestHeader(key, value)
      
      ; Configuration correcte des timeouts (en millisecondes)
      http.SetTimeouts(timeoutMs, timeoutMs, timeoutMs, timeoutMs)
      
      http.Send(data)
      
      ; Conversion correcte ms → secondes pour WaitForResponse
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
```

## Améliorations apportées

1. ✅ **SetTimeouts()** : Utilise la méthode correcte avec 4 paramètres (ResolveTimeout, ConnectTimeout, SendTimeout, ReceiveTimeout)
2. ✅ **Conversion correcte** : Division normale `/` au lieu de `//`
3. ✅ **Gestion d'erreur** : Bloc try/catch pour capturer les timeouts et autres erreurs
4. ✅ **Suppression du code inutile** : Retrait de la vérification readyState et de l'appel Abort()

## Paramètres SetTimeouts

```ahk
http.SetTimeouts(ResolveTimeout, ConnectTimeout, SendTimeout, ReceiveTimeout)
```

- **ResolveTimeout** : Temps pour résoudre le nom DNS
- **ConnectTimeout** : Temps pour établir la connexion
- **SendTimeout** : Temps pour envoyer les données
- **ReceiveTimeout** : Temps pour recevoir la réponse

Tous sont configurés à `timeoutMs` (30000ms = 30s par défaut).

## Test recommandé

Pour tester avec un timeout plus long (par exemple 60 secondes) :

```ahk
result := SendHttpRequest(API_URL, data, headers, 60000)
```
