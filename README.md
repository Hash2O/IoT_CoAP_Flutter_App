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

## Présentation rapide
    Une application mobile Flutter permettant :
        - La découverte des appareils
        - La consultation de la température
        - La modification de la température
        - La visualisation du statut réseau
        - La simulation d’instabilité réseau (mode Admin)
    => L’objectif est de proposer une architecture réaliste de supervision IoT capable de gérer des conditions réseau instables.

## Lancer l'application
    flutter pub get
    flutter run

### Arborescence de l'application:
    lib/
    │
    ├── data/
    │   └── services/
    │       ├── coap_chaos_service.dart
    │       ├── coap_health_service.dart
    │       ├── coap_temperature_service.dart
    │       └── device_discovery_service.dart
    │
    ├── domain/
    │   └── models/
    │       └── device.dart
    │
    ├── presentation/
    │   ├── bloc/
    │   │   ├── device_bloc.dart
    │   │   ├── device_detail_bloc.dart
    │   │   ├── device_event.dart
    │   │   └── device_state.dart
    │   │
    │   └── pages/
    │       ├── device_detail_page.dart
    │       └── device_list_page.dart
    │
    ├── chaos_panel.dart
    ├── coap_test_service.dart
    └── main.dart

## Choix technique : Multicast UDP / CoAP announce plutôt que scan réseau + requête
    - Fonctionnellement, les deux approches partent de /.well-known/core, mais :
        - Scan réseau = émission unicast vers chaque IP possible, coûteux et peu élégant.
        - Multicast CoAP = une seule requête vers un groupe « All CoAP Nodes », avec réponses des seuls nœuds concernés.

    L’option multicast :
        - suit les recommandations et mécanismes prévus par CoAP et les RFC CoRE,
        - réduit le trafic de découverte et se prête mieux à des parcs importants,
        - s’intègre naturellement avec une future introduction d’un Resource Directory (RD).

    Il convient toutefois de préciser que, dans la pratique, certains environnements WiFi/entreprise filtrent sévèrement l’UDP et/ou le multicast, et qu’il est alors utile de garder :
        - soit un mode « fallback » (IP fixe connue, ou petit scan),
        - soit un RD centralisé découvert une fois puis utilisé en unicast.

### Arguments : 
    - Processus en temps réel
    - Pas besoin de scanner l'ensemble du réseau
    - Plus proche d’une situation réelle sur un système IoT

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

## Version 2 - Refactorisation de la version 1
    => UI → Bloc → Services → Modèles

    Objectifs : séparation data / logique / UI, gestion propre des streams, gestion propre des timers, aucune logique réseau dans l’UI

    => Architecture IoT propre, véritable séparation des couches, système extensible. 

## Statut des devices
    Le statut de chaque device est déterminé par un ping périodique de type CoAP /health

## Version 3 : 
    - Multicast discovery
    - Health monitoring robuste
    - Architecture Bloc
    - Écran détail fonctionnel
    - Lecture / écriture CoAP
    - Gestion réseau propre

### Evolution des règles de connexion : 
    - Multicast sert uniquement à faire apparaître le device
    - 0 échec → Online
    - 1–2 échecs → Degraded
    - 3+ échecs → Offline

### Modèle : Discovery layer + Health monitoring layer + Failure tolerance

### UI : 
    - Vert → Online
    - Orange → Degraded
    - Rouge → Offline
    - Noir → Inconnu

### Affichage des devices (DeviceListPage)
    Chaque device est identifié par un UUID unique généré dynamiquement si non fourni.
    Le timestamp lastSeen est mis à jour à chaque annonce multicast.
    Le statut de connexion est déterminé via ping CoAP /health avec dégradation progressive.

### Mode administrateur
    L’application intègre un mode administrateur permettant de simuler dynamiquement des conditions réseau dégradées via un endpoint CoAP dédié.
    L’interface d’administration reste accessible même en cas de défaillance réseau, garantissant la capacité de reprise

### Gestion des erreurs réseau 
    L’application :
        - Gère les timeouts
        - Affiche les erreurs sans crash
        - Désactive les actions critiques en cas d’erreur
        - Reste fonctionnelle même en mode offline
        - Se rétablit automatiquement lorsque le réseau revient
    De plus, un timer d’auto-refresh permet de resynchroniser l’état.