# AGENTS.md

## Purpose and Scope

This file governs the entire repository. It is written for future coding agents working on LZU Timetable, a Flutter course schedule app.

- Active targets are Flutter Web and Android. Keep the Dart app and data model portable enough for a later iOS target unless a requirement explicitly says otherwise.
- The product UI is Chinese. Keep labels such as `课程表`, `管理课程表`, `教务系统导入`, `课程序号`, and `第一周星期一` in Chinese when they identify real app concepts.
- The timetable is table-first. The main experience is a weekly grid, not a list agenda or landing page.
- A fresh install must not include any initial schedule. Users add schedules through the management/import flows.
- `assets/raw/` is for repository fixtures and compatibility tests only. Do not list raw teaching-system HTML as Flutter runtime assets.

## Environment and Command Policy

The workspace is normally used on Windows with PowerShell under `D:\WorkSpace\course schedule`.

- Run shell, Flutter, Dart, and Git commands elevated in this repository. Non-elevated execution is known to hang in this workspace.
- Prefer PowerShell-native commands. Use `rg` or `rg --files` for searches when available.
- Keep command output readable. Avoid noisy chained command blocks when separate focused commands are clearer.
- Do not create or rely on generated files outside the repository unless the task explicitly needs that.

Common commands:

```powershell
flutter pub get
dart format <touched-dart-files>
flutter analyze
flutter test
flutter build web
flutter run -d web-server
flutter devices
flutter emulators
flutter emulators --launch <emulator-id>
flutter build apk --debug
flutter run -d <device-id>
flutter pub outdated --no-transitive
```

## Repository Map

- `lib/models/` owns typed schedule data, immutable keys, hardcoded timetable sections, and date/week logic.
- `lib/database/` owns the Drift schema, SQLite constraints, indexes, effective-version view, and cross-platform database opening.
- `lib/services/` owns HTML parsing, hardcoded academic period mappings, academic-page recognition, the timetable repository, and course customization application.
- `lib/app/` owns navigation, timetable rendering, management screens, import/edit flows, dialogs, Android conditional WebView integration, and shared UI widgets.
- `android/` contains the Android platform shell, permissions, WebView/network compatibility settings, and launcher metadata.
- `web/` contains the Flutter Web shell. Web must stay free of Android-only WebView imports.
- `test/` contains parser, store, model, widget, import-flow, and timetable behavior coverage.
- `assets/raw/` contains test-only teaching-system HTML fixtures. These files may be read by tests and development tooling, but they are not product seed data.
- `assets/branding/` contains app branding assets such as the launcher/source icon.
- `build/`, `.dart_tool/`, generated APKs, and other build outputs are never committed.

## Architecture and Data Flow

The app uses a normalized data pipeline:

1. A user provides source content through manual HTML paste/upload or Android academic import.
2. Import services parse transient HTML into typed Dart models.
3. Parser-only period mappings come from `AcademicPeriodMappings`; runtime section labels and start/end times come from `TimetableSections`.
4. Parsed schedules are normalized into Drift/SQLite relation tables through `TimetableRepository` transactions.
5. Local course customizations are applied after loading schedules.
6. Shared timetable widgets render the resulting schedule for Web, mobile Web, and Android.

Keep parsing and persistence independent from Flutter widgets. Widgets should call services and render model state; they should not scrape HTML, interpret teaching-system week text, or issue ad hoc SQL.

## Data Invariants

- Imported HTML is transient. Do not persist raw HTML; it may exist only during an import/recognition flow.
- Persist schedule records through the typed Drift schema and `TimetableRepository`, not ad hoc widget state or JSON blobs.
- `AcademicPeriodMappings.all` is the parser-only source of the 48 teaching-system mappings. `TimetableSections.all` is the runtime source of the 14 single-section labels and start/end times. Neither is persisted.
- Individual section start/end times shown in the section column are inferred from single-section period definitions.
- Teaching-system week expressions are expanded during import into numeric scheduled sessions. Do not store or expose editable week-rule text such as `1-17周全周`.
- Editing a course section must present concrete weeks, weekday, period, and location. Users should not type week-rule strings.
- `weekCount` is schedule metadata. The effective week count is at least the final week that currently contains a scheduled course.
- `weekCount` may exceed the final scheduled week. It may be reduced only down to the current final scheduled week, never below it.
- Deleting or moving the last scheduled course can lower the minimum allowed `weekCount`, but it must not automatically erase the user's explicit extension.
- Date range logic uses the first Monday of week 1 and the effective final Sunday. Device-local dates are used, ignoring time of day.
- On app start, prefer a schedule whose date range contains today. If multiple schedules contain today, choose the one with the latest first Monday.
- If today is before a selected schedule, show week 1 and do not highlight today. If today is after it, show the final effective week and do not highlight today.
- Highlight today only in the weekday/date header cell for the displayed week. Do not highlight course cells, section cells, or the top-left corner cell.
- Imported course overrides match only by immutable `课程号 + 课程序号`. If an imported course disappears after re-import, its override must not affect unrelated courses.
- Manual courses use stable local keys. They must not pretend to have teaching-system course numbers unless the user explicitly supplies compatible data.
- Untimed courses are valid model data but are not rendered in the weekly timetable grid.
- Schedule display names are unique after `trim()`. Do not allow two schedules with the same trimmed name.

## UI Invariants

- Keep the main timetable as a table with a left section column and Monday through Sunday columns.
- Mobile must show Monday through Sunday within the page without horizontal overflow. Reduce column density before switching to an agenda-style layout.
- Section cells show the start time above the section label and the end time below it. The section label uses compact text such as `1`, `2`, `午1`, and `午2`.
- Course cards must show the course name and location when a location exists.
- Grid lines must remain visible for empty cells and table structure, but lines crossing through course cards should be visually suppressed only where they intersect course cards.
- Course detail dialogs expose an edit entry. Course editing uses a full page, not a cramped inline editor.
- Clicking an empty timetable cell can add a course with that week, weekday, and period preselected. Only time placement and name are mandatory for a minimal manual course.
- Week selection for course editing should use a dedicated picker/sub-dialog when it would otherwise consume too much page space.
- Period selection should use compact period buttons, not a long dropdown. Selected period buttons are highlighted; do not add redundant checkmarks.
- Course schedule creation, editing, deletion, and import entry points belong in `管理课程表`. The home timetable is primarily for viewing and quick cell-based course creation.
- On mobile, the top-right menu owns secondary actions, including management. Semester selection should remain a selector rather than expanding every schedule into the menu.

## Import Behavior

Manual import:

- Manual HTML import supports paste and `.html`, `.htm`, or `.txt` upload.
- Preview is optional. Users may preview first or confirm directly.
- When previewing, render the same timetable grid used by the normal schedule view and allow week switching in the preview.
- When confirming, validate required metadata, unique name, first Monday, `weekCount`, and parsed schedule data.
- If editing existing schedule metadata without providing new HTML, keep the existing relational course data and update only requested metadata.

Android academic import:

- Android uses an embedded WebView for `教务系统导入` and starts from `https://jwk.lzu.edu.cn/academic/student/currcourse/currcourse.jsdo`.
- The WebView must follow SSO redirects. Users log in and select/query the desired 学年学期 themselves.
- After the user taps recognition, capture the current DOM HTML internally, hide the captured HTML from the UI, auto-preview the recognized schedule, and continue through the same save path as manual import.
- Never read, log, display, or persist usernames, passwords, SSO tickets, or credential fields.
- The `保留登录状态` option controls WebView cookies only for the import session. Clearing it should clear WebView cookies at the appropriate exit/transition point.
- Recognize only the actual teaching-system course page. Use the academic-page recognition service for URL and selected-term extraction.
- The Android HTTP return path, cleartext allowance, and mixed-content WebView configuration are intentional compatibility requirements for real devices and OEM WebViews. Do not tighten them without validating the full SSO round trip on Android 12 and Android 16 class devices.

Web import:

- Flutter Web must not attempt to read cross-origin SSO pages or embedded third-party DOM. Browser same-origin policy applies.
- Web users should use manual paste/upload import unless a backend or browser extension is explicitly added in a future requirement.

## Persistence

- Schedule storage uses Drift/SQLite on Android and SQLite/WASM on Web. `shared_preferences` is only for lightweight preferences such as theme mode.
- This schema intentionally starts fresh and does not read or migrate legacy schedule JSON. Do not add a compatibility reader or migration path unless a later requirement explicitly requests one.
- `TimetableRepository` owns transactions, duplicate-name checks, aggregate CRUD, re-import matching, and effective model assembly.
- Keep imported base data and local override versions separate. Re-import updates only base versions and preserves overrides matched by immutable `课程号 + 课程序号`.
- Parser period mappings and runtime section definitions are hardcoded program data and must not be stored in the database.
- Course deletion in the customization layer means the course disappears from details and grids. Deleting every section of a course leaves an untimed course unless the whole course is deleted.

## Testing Expectations

Use focused tests that match the risk of the change.

- Parser tests should cover teaching-system table selection, full-page HTML, fixture course counts, teacher lists, missing locations, empty time data, and every supported original week expression.
- Period tests should verify `AcademicPeriodMappings.all` has 48 parser mappings and that `TimetableSections.all` has the expected 14 labels and start/end times.
- Repository tests should verify relational round trips, absence of raw HTML and period tables, `weekCount`, manual courses, imported course keys, re-import behavior, and customization overlays.
- Date/week tests should cover first Monday boundaries, final Sunday boundaries, before/after clamping, overlap selection, and header-only today highlighting.
- Repository tests should cover save, restore, search, edit, delete, duplicate names, cascading deletes, and transaction rollback.
- Import-flow widget tests should cover required metadata, duplicate names, optional preview, direct confirmation, auto-preview from academic recognition, and hidden HTML behavior.
- Course editing tests should cover metadata edits, adding sections, deleting selected sections, deleting a course, and limits based on effective week count.
- Shared timetable tests should cover desktop and narrow mobile layouts, week switching, empty-cell add, detail opening, course card name/location, grid-line suppression through cards, and overflow absence.
- Current raw fixtures may assert known counts such as 19 sample courses and 48 periods, but those counts are fixture facts, not product limits.

## Verification by Change Type

- Documentation-only changes: inspect the diff and run `git diff --check`. Flutter builds are not required.
- Dart-only logic changes: format touched Dart files, then run `flutter analyze` and `flutter test`.
- Shared UI, model, storage, or parser changes: run `flutter analyze`, `flutter test`, `flutter build web`, and `flutter build apk --debug`.
- Android manifest, WebView, network security, or plugin changes: run Android debug APK build and validate on an emulator or real device when available.
- Responsive timetable changes: add or update desktop and 390x844-style widget coverage with explicit overflow checks.
- Dependency changes: update both `pubspec.yaml` and `pubspec.lock`, inspect plugin platform impact, and build Web plus Android.

## Engineering Workflow

- Read the relevant code before editing. Prefer existing models, services, stores, and widgets over new parallel abstractions.
- Keep edits scoped to the requested behavior. Avoid unrelated refactors while fixing product behavior.
- Use structured parsers and typed models instead of string manipulation when the existing stack supports it.
- Use `apply_patch` for manual file edits. Formatting commands and generated platform tooling may update files mechanically.
- Add concise comments only when they clarify non-obvious behavior, such as Android compatibility settings or re-import overlay decisions.
- Keep UI text fitted at mobile sizes. Avoid overflow by changing layout constraints, density, or content hierarchy.
- Preserve Web and Android behavior together unless a requirement explicitly allows a platform split.

## Git Workflow

- Check `git status --short` before and after work.
- Preserve unrelated user changes. Do not revert, reset, or overwrite work you did not make.
- Do not use destructive Git commands such as `git reset --hard` or `git checkout --` unless the user explicitly asks for that operation.
- Stage only files that belong to the task.
- Keep commits focused and human-readable, for example `docs: expand repository agent guide`.
- Never commit generated output such as `build/`, `.dart_tool/`, APK files, transient logs, or local IDE state.

## Delivery Notes

- Summaries should mention what changed, what was verified, and any validation that was intentionally skipped.
- When a change affects real-device Android import, state whether it was validated on emulator, physical device, or by code/build inspection only.
- Keep `README.md` and this file aligned when product behavior changes. For this repository, the code and tests are the source of truth when older prose is stale.
