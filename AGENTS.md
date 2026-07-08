# AGENTS.md

## Project Context

- This repository is a Flutter course schedule app.
- The first delivery target is Flutter Web. Keep code portable for later Android and iOS Flutter builds.
- UI text should stay in Chinese unless a product requirement says otherwise.

## Commands

- Enable web support: `flutter config --enable-web`
- Install dependencies: `flutter pub get`
- Run tests: `flutter test`
- Build web: `flutter build web`
- Local web preview: `flutter run -d web-server`

## Data Rules

- Preserve the original teaching-system HTML samples under `assets/raw/`.
- Parse course HTML and period HTML into typed Dart models before rendering.
- Do not hand-edit normalized course data when it can be derived from the source HTML.
- Future imports should feed the same importer API used by bundled samples.

## Implementation Guidelines

- Keep parsing logic independent from Flutter widgets.
- Add tests for every supported week expression and timetable mapping rule.
- Treat courses with no fixed schedule as valid data and show them outside the weekly grid.
- Keep responsive layout usable on PC Web and mobile Web.

## Git Workflow

- Commit working milestones with focused messages.
- Do not include generated build output such as `build/`.
