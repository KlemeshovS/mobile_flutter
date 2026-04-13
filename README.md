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
- сборки debug-артефакта на `develop`
- сборки release `.aab` на `main`

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

CI сможет собирать подписанные release bundle, если в GitHub Secrets добавлены:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_PASSWORD`
- `ANDROID_KEY_ALIAS`
