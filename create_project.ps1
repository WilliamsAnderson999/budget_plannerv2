Write-Host "🚀 Création du projet Flutter Budget Manager..."

# Étape 1 : Créer le projet Flutter de base
flutter create budget_manager

# Étape 2 : Se déplacer dans le projet
Set-Location budget_manager

Write-Host "📂 Projet Flutter initialisé"

# Étape 3 : Créer la structure de dossiers personnalisée
New-Item -ItemType Directory -Force -Path lib\theme, lib\screens, lib\widgets, lib\models, lib\services, lib\utils
New-Item -ItemType Directory -Force -Path assets\images, assets\fonts

Write-Host "📁 Structure des dossiers personnalisée créée"

# Étape 4 : Créer tous les fichiers nécessaires
# Fichiers racine
New-Item -ItemType File lib\main.dart
New-Item -ItemType File lib\app.dart

# Theme
New-Item -ItemType File lib\theme\app_theme.dart

# Screens
$Screens = @(
    "onboarding_screen.dart","login_screen.dart","signup_screen.dart",
    "forgot_password_screen.dart","security_pin_screen.dart","security_fingerprint_screen.dart",
    "home_screen.dart","analysis_screen.dart","transactions_screen.dart",
    "calendar_screen.dart","search_screen.dart","profile_screen.dart","new_password_screen.dart"
)
foreach ($s in $Screens) { New-Item -ItemType File ("lib\screens\" + $s) }

# Widgets
$Widgets = @(
    "balance_card.dart","transaction_item.dart","period_selector.dart",
    "custom_app_bar.dart","analytics_chart.dart","category_chip.dart",
    "pin_keypad.dart","budget_progress.dart"
)
foreach ($w in $Widgets) { New-Item -ItemType File ("lib\widgets\" + $w) }

# Models
$Models = @("transaction.dart","user.dart","category.dart")
foreach ($m in $Models) { New-Item -ItemType File ("lib\models\" + $m) }

# Services
$Services = @("auth_service.dart","firestore_service.dart","transaction_service.dart")
foreach ($srv in $Services) { New-Item -ItemType File ("lib\services\" + $srv) }

# Utils
$Utils = @("constants.dart","helpers.dart")
foreach ($u in $Utils) { New-Item -ItemType File ("lib\utils\" + $u) }

# Autres
New-Item -ItemType File README.md

Write-Host "✅ Tous les fichiers créés avec succès !"
Write-Host ""
Write-Host "⚠️ Étapes suivantes :"
Write-Host "1. Ouvrir le projet dans VS Code"
Write-Host "2. Ajouter vos assets dans assets/images/ et assets/fonts/"
Write-Host "3. Modifier pubspec.yaml pour inclure les assets et dépendances"
