@echo off
REM MindSpice structure (Windows CMD batch)

mkdir lib\models 2>nul
mkdir lib\providers 2>nul
mkdir lib\services 2>nul
mkdir lib\screens 2>nul
mkdir lib\widgets 2>nul
mkdir lib\theme 2>nul
mkdir lib\utils 2>nul
mkdir assets\images 2>nul
mkdir assets\lottie 2>nul
mkdir assets\data 2>nul

type nul > lib\main.dart

type nul > lib\models\entry.dart
type nul > lib\models\category.dart

type nul > lib\providers\entries_notifier.dart
type nul > lib\providers\categories_notifier.dart
type nul > lib\providers\theme_notifier.dart
type nul > lib\providers\providers.dart

type nul > lib\services\storage_service.dart
type nul > lib\services\csv_service.dart

type nul > lib\screens\root_screen.dart
type nul > lib\screens\home_screen.dart
type nul > lib\screens\create_screen.dart
type nul > lib\screens\edit_entry_screen.dart
type nul > lib\screens\settings_screen.dart

type nul > lib\widgets\entry_card.dart
type nul > lib\widgets\category_chip.dart
type nul > lib\widgets\empty_state.dart

type nul > lib\theme\app_colors.dart
type nul > lib\theme\app_text_styles.dart
type nul > lib\theme\app_theme.dart

type nul > lib\utils\date_utils.dart
type nul > lib\utils\constants.dart

echo ✅ MindSpice Flutter project structure created successfully!
pause
