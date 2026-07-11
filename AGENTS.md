# AGENTS.md

## Project Context

- This repository is a Flutter course schedule app.
- The active delivery targets are Flutter Web and Android. Keep code portable for later iOS Flutter builds.
- UI text should stay in Chinese unless a product requirement says otherwise.

## Commands

- Enable web support: `flutter config --enable-web`
- Install dependencies: `flutter pub get`
- Run tests: `flutter test`
- Build web: `flutter build web`
- Build Android debug APK: `flutter build apk --debug`
- Run on Android device/emulator: `flutter run -d <device-id>`
- Local web preview: `flutter run -d web-server`

## Data Rules

- Preserve the original teaching-system HTML samples under `assets/raw/` for repository tests only; do not include them in Flutter runtime assets or ship an initial schedule.
- Parse course HTML and period HTML into typed Dart models before rendering.
- Do not hand-edit normalized course data when it can be derived from the source HTML.
- Future imports should feed the same importer API used by bundled samples.
- Persist configured semester week counts in normalized JSON; allow them to exceed, but never fall below, the final scheduled course week.
- Keep raw full-page teaching-system samples under `assets/raw/` when they are used to verify import compatibility.
- Parse imported HTML before persistence and store only typed, JSON-serializable semester data. HTML may exist only in the transient import flow or be read once to migrate an older local record.
- Expand teaching-system week expressions during parsing. Store and render each fixed class as an individual numeric week session; do not persist or expose editable week-rule text.
- Persist local course overrides separately and apply them only when the immutable `课程号 + 课程序号` key still matches an imported course. Persist manually added courses as separate JSON records with stable local course keys.

## Implementation Guidelines

- Keep parsing logic independent from Flutter widgets.
- Add tests for every supported week expression and timetable mapping rule.
- Treat courses with no fixed schedule as valid parsed data, but do not place them in the weekly grid unless a product requirement asks for a separate display.
- Keep responsive layout usable on PC Web, mobile Web, and Android phones.
- Keep course schedule creation, editing, and deletion in the dedicated management page; the timetable home remains a viewing surface.
- Keep Android WebView SSO imports isolated from Flutter Web with conditional imports; never read or persist user credentials.

## Git Workflow

- Commit working milestones with focused messages.
- Do not include generated build output such as `build/`.
