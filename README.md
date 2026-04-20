# workspace_guard

Flutter-застосунок для лабораторних робіт з мобільної розробки. Демонструє роботу з автентифікацією, MQTT, мережею та власним Flutter-плагіном.

## Лабораторна 7 — кастомний плагін ліхтарика

Застосунок використовує власний плагін [`flash_toggle_plugin`](https://github.com/sergiyclas/flash_toggle_plugin) для керування ліхтариком на Android.

**Секретний тригер:** подвійний тап по аватару на екрані **Profile** вмикає/вимикає ліхтарик. На iOS / Web з'являється попереджувальний діалог про непідтримувану платформу.

## Запуск

```bash
flutter pub get
flutter run
```

## Корисні команди

```bash
flutter clean       # очистити build-артефакти
flutter analyze     # перевірити код лінтером
dart fix --apply    # застосувати автофікси
flutter build apk --release   # зібрати release APK
```
