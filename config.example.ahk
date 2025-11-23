#Requires AutoHotkey v2.0.11+

; Configuration de l'API
global API_KEY := "votre_cle_api_ici"  ; Remplacez par votre clé API Mistral
global API_URL := "https://api.mistral.ai/v1/agents/completions"
global API_AGENT_ID_CARLA := "votre_agent_id_ici"  ; Remplacez par votre ID d'agent Mistral de correction
global API_AGENT_ID_MAEL := "votre_agent_id_ici"  ; Remplacez par votre ID d'agent Mistral de tranduction

; Configuration de l'appel à LMStudio
global LMSTUDIO_URL := "http://localhost:1234/v1/chat/completions"
global LMSTUDIO_MODEL := "Mistral-Small-22B-ArliAI-RPMax-v1_1-IQ4_XS"
