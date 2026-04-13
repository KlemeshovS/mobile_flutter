# Mobile CI/CD

## Модель веток

- `feature/*` -> рабочие ветки под задачи
- `develop` -> интеграционная ветка команды
- `main` -> релизная ветка

Рекомендуемый процесс:

1. работа идет в `feature/*`
2. pull request открывается в `develop`
3. после проверки на `develop` изменения попадают в `main`
4. `main` собирает релизный артефакт для тестирования

## Что делает CI

### `develop`

На pull request и push:

- `flutter pub get`
- `dart format --set-exit-if-changed .`
- `flutter analyze --no-fatal-infos --no-fatal-warnings`
- `flutter test`

На push в `develop` дополнительно собирается debug APK:

- `build/app/outputs/flutter-apk/app-debug.apk`

Это удобно для быстрых smoke-проверок, не превращая каждый merge в релиз.

### `main`

На push в `main`:

- повторяются те же проверки
- выполняется `flutter build appbundle --release`
- готовый `app-release.aab` сохраняется как GitHub Actions artifact

Так `main` остается релизной веткой, но без автоматической публикации в Google Play.

## Secrets для подписанных release-сборок

Если нужны подписанные release bundle в CI, добавьте в GitHub Secrets:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_PASSWORD`
- `ANDROID_KEY_ALIAS`

Если их нет, CI все равно соберет release-артефакт, но Gradle использует debug signing как fallback.

Дополнительно:

- `google-services.json` не обязателен для CI artifact-сборок
- если файл отсутствует, Google Services plugin в Android Gradle не подключается
- это позволяет собирать debug/release артефакты в CI без Firebase-конфига
- локально и в реальных Android-сборках plugin включится автоматически, если `android/app/google-services.json` присутствует

## Почему пока без автоматической выкладки в Google Play

Для этого проекта более безопасный первый этап такой:

- CI проверяет каждый merge
- `develop` дает тестовые артефакты
- `main` дает релизные артефакты
- публикация остается ручной

Это дает предсказуемые сборки и не привязывает репозиторий к Play Console раньше времени.

Почему `analyze` запущен в мягком режиме:

- проект уже содержит накопленные warnings и deprecated API
- CI должен блокировать реальные analyzer errors, а не быть постоянно красным из-за старого техдолга
- когда кодовая база станет чище, этот флаг можно будет убрать

## Что такое Google Play Internal testing

`Internal testing` — это закрытый внутренний трек Google Play для быстрой раздачи сборок небольшой группе.

Обычно он нужен для того, чтобы:

- быстро раздать новую сборку команде
- проверить установку и обновление через Google Play
- проверить signing, auth, API-конфигурацию и поведение на реальных устройствах
- безопасно гонять много сборок в день без риска для production

На практике это выглядит так:

1. вы мерджите код в `main`
2. CI собирает подписанный `.aab`
3. этот `.aab` позже можно автоматически или вручную отправить в трек `internal`
4. тестировщики получают приложение через Play, но обычные пользователи его не видят

Это не production:

- production — публичный релиз
- internal testing — приватный этап проверки перед публичным выпуском

## Рекомендуемая политика выката

- `develop` = общая интеграция команды
- `main` = релиз-кандидат
- Google Play `Internal testing` = первый внешний этап тестирования
- Production = только после ручного подтверждения
