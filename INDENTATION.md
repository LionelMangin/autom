# Règles d'indentation du projet

Ce document décrit les règles d'indentation à suivre dans le projet.

## 1. Structure de base

Les accolades sont indentées de 2 espaces par rapport à leur instruction :

```autohotkey
fonction()
  {
   instruction
  }
```

## 2. Contenu des blocs

Tout le contenu est indenté de 3 espaces par rapport aux accolades :

```autohotkey
fonction()
  {
   instruction1
   instruction2
   instruction3
  }
```

## 3. Structure if/else

- Le `else` est indenté d'un espace par rapport au `if` parent
- Les accolades suivent toujours la règle des 2 espaces

```autohotkey
if (condition)
  {
   code1
  }
 else
  {
   code2
  }
```

## 4. Structure else if

- Le `else` est indenté d'un espace
- Le `if` qui suit est indenté d'un espace supplémentaire (2 espaces au total)
- Les accolades suivent toujours la règle des 2 espaces par rapport à leur instruction

```autohotkey
if (condition1)
  {
   code1
  }
 else
   if (condition2)
     {
      code2
     }
```

## 5. Commentaires et lignes de continuation

- Les commentaires suivent l'indentation de leur bloc
- Les lignes de continuation suivent l'indentation de leur instruction parente

```autohotkey
fonction()
  {
   ; Ceci est un commentaire
   instruction1
   instruction2   ; Commentaire en ligne
   
   ; Bloc de commentaires
   ; sur plusieurs lignes
   instruction3
  }
```

## 6. Exemple complet

```autohotkey
MaFonction(param)
  {
   if (param > 0)
     {
      resultat := param * 2
     }
    else
      if (param < 0)
        {
         resultat := param * -1
        }
      else
        {
         resultat := 0
        }
   
   return resultat
  }
```

Cette structure d'indentation permet de :
- Maintenir une hiérarchie visuelle claire
- Faciliter la lecture du code
- Identifier rapidement les différents niveaux de blocs
- Repérer facilement les structures de contrôle 