# iot_coap_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
# IoT_CoAP_Flutter_App

## Test Découverte :
- Lance le service multicast au démarrage
- Écoute les annonces
- Affiche chaque device reçu
- Nettoie proprement socket + stream à la fermeture

## Gestion intelligente des devices

### Objectifs : 
    - Dédupliquer les devices
    - Ajouter lastSeen
    - Implémenter les statuts demandés par le cahier des charges:
        - Unknown
        - Online
        - Degraded
        - Offline
    - Ajouter un timer de surveillance
    - Préparer le terrain pour une architecture en Bloc

### Résultats :
    - Chaque device apparaît une seule fois
    - A l'arrêt du simulateur : 
        => Le statut passe Online → Degraded → Offline
    - Si on le relance :
        => repasse immédiatement Online
    Important : L’app ne doit pas crasher.

### Règles basiques de connexion :
    - Online: last announce <= 5 seconds
    - Degraded: 5 < last announce <= 10 seconds
    - Offline: last announce > 10 seconds
