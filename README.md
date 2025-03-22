# Autom - Assistant IA avec AutoHotkey

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/LionelMangin/autom/releases)
[![AutoHotkey](https://img.shields.io/badge/AutoHotkey-v2.0.11+-green.svg)](https://www.autohotkey.com/)
[![Licence](https://img.shields.io/badge/licence-MIT-yellow.svg)](LICENSE)
[![Windows](https://img.shields.io/badge/Windows-10+-0078D6.svg)](https://www.microsoft.com/fr-fr/windows)

Un script AutoHotkey qui permet d'interagir facilement avec l'API Mistral AI pour obtenir des réponses à vos questions directement depuis n'importe quelle application.

## Fonctionnalités

- Capture rapide de texte avec des raccourcis clavier
- Envoi automatique à l'API Mistral AI
- Gestion intelligente des sauts de ligne
- Support multilingue
- Réponse automatique dans le presse-papier

## Prérequis

- Windows 10 ou supérieur
- [AutoHotkey v2.0.11](https://www.autohotkey.com/) ou supérieur
- Un compte Mistral AI avec une clé API

## Installation

1. Clonez ce dépôt :
```bash
git clone https://github.com/LionelMangin/autom.git
```

2. Copiez le fichier `config.example.ahk` vers `config.ahk` :
```bash
copy config.example.ahk config.ahk
```

3. Éditez `config.ahk` et remplacez :
   - `VOTRE_CLE_API_ICI` par votre clé API Mistral
   - `VOTRE_AGENT_ID_ICI` par votre ID d'agent Mistral

## Utilisation

Le script propose deux raccourcis clavier :

- `Ctrl + *` : Sélectionne tout le texte de la fenêtre active et l'envoie à l'API
- `Ctrl + Shift + *` : Envoie uniquement le texte sélectionné à l'API

La réponse de l'API sera automatiquement collée à l'endroit où le texte était sélectionné.

## Rechargement du script

Pour recharger le script après une modification, tapez "reloas" dans n'importe quelle fenêtre et utilisez `Ctrl + *`.

## Sécurité

- La clé API est stockée dans un fichier de configuration séparé (`config.ahk`)
- Ce fichier n'est pas versionné dans Git
- Utilisez toujours le fichier `config.example.ahk` comme modèle


## Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails. 