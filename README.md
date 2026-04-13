# Wobbly Flutter

Мобильное Flutter-приложение для Wobbly.

## Политика веток

- `feature/*` -> ветки под задачи
- `develop` -> интеграционная ветка команды
- `main` -> релизная ветка

Рекомендуемый процесс:

1. открываем PR в `develop`
2. проверяем и собираем изменения в `develop`
3. мерджим `develop` в `main` только тогда, когда хотим получить релиз-кандидат

## CI/CD

В репозитории настроены GitHub Actions для:

- проверки форматирования
- статического анализа
- тестов
- сборки тестовой release APK на `develop`
- сборки продуктовых release APK и `.aab` на `main`

Подробное описание:
- [docs/CI_CD.md](docs/CI_CD.md)

## Локальная разработка

```bash
flutter pub get
dart format .
flutter analyze
flutter test
```

## Подпись Android release-сборок

Для продуктовой сборки в `main` в GitHub Secrets должны быть добавлены:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_GOOGLE_SERVICES_JSON_BASE64`

Для `develop` эти secrets опциональны:

- если они есть, тестовая release APK будет подписана release-ключом
- если `ANDROID_GOOGLE_SERVICES_JSON_BASE64` есть, тестовая сборка будет собрана с реальным Google/Firebase-конфигом
- если его нет, тестовая сборка все равно может собраться без Google Services plugin
- если keystore нет, тестовая сборка будет собрана с fallback signing и останется пригодной для ручного тестирования
