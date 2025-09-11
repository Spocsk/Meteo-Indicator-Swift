# Application Météo - Swift

## Description
Application météo iOS développée en Swift offrant les conditions actuelles, prévisions et géolocalisation avec une interface moderne et intuitive.

## Fonctionnalités
- **Météo actuelle** : Température, conditions, humidité, vent, pression
- **Prévisions** : Horaires (24h) et quotidiennes (7 jours)
- **Géolocalisation** : GPS automatique et recherche de villes
- **Interface** : Design adaptatif, animations fluides, mode sombre

## Technologies
- **Swift 5.x** avec UIKit/SwiftUI
- **Core Location** pour GPS
- **API météo** (OpenWeatherMap)
- **Core Data** pour persistance
- **Architecture MVVM**

## Installation
1. Cloner le projet
2. Configurer clé API dans `Config.plist`
3. Ajouter permissions localisation dans `Info.plist`
4. Compiler avec Xcode 14+

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Localisation pour météo locale</string>
```

## Fonctionnalités avancées
- Notifications météo
- Widget iOS
- Cache intelligent
- Optimisations batterie

## Tests
- Tests unitaires (modèles, réseau)
- Tests UI (parcours utilisateur)
- Couverture API mocks
