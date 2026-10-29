# AGENTS.md

Nexora Suite (`nexora_launcher`) — Flutter desktop launcher for the Nexora ecosystem (Windows/Linux). Optional Rust FFI core.

## Commands

```bash
flutter pub get              # install (see Setup)
flutter analyze             # static analysis (lint)
flutter build linux         # or: flutter build windows
flutter run -d linux       # or: flutter run -d windows

# Rust core (optional)
cd rust/nexora_core
cargo fmt
cargo clippy            # currently fails: not_unsafe_ptr_arg_deref (see Gotchas)
cargo build --release
```

Verification order (per CONTRIBUTING): `flutter analyze` then build (`flutter build linux`/`windows`). Rust: `cargo fmt` then `cargo clippy`. No tests and no separate typecheck/codegen step.

## Setup

- SDK: Flutter stable, Dart `^3.13.7` (metadata pins revision `737ba8f885`).
- Path dependency: `nexora_ui_kit: path: ../NexoraUi-Kit`. In the canonical workspace (`.../Nexora-Labs-Co/apps/`) this resolves via a symlink `NexoraUi-Kit -> ../ui/NexoraUi-Kit`. In an isolated worktree (e.g. OpenCode) the symlink is missing — create it in the directory containing this repo before `flutter pub get`:
  `ln -s <Nexora-Labs-Co>/ui/NexoraUi-Kit <parent-of-this-repo>/NexoraUi-Kit`
- Rust/Cargo optional (core builds to `libnexora_core.so` / `nexora_core.dll`).
- Linux runtime needs `dpkg`, `pkexec`.

## Architecture / ownership

- `lib/main.dart` — window setup (transparent bg, hidden title bar, 1180x760 min 960x640).
- `lib/app.dart` — `MaterialApp` with `NexoraTheme.dark()`.
- `lib/core/theme/app_theme.dart` — monochrome `NexoraColors` + `NexoraTheme` (accent `#A50021`).
- `lib/core/models/nexora_app.dart` — `NexoraApp`, static catalogue `kNexoraApps` (Harmony, Nexora Suite).
- `lib/core/services/` — `github_service.dart` (GitHub Releases), `app_catalog_service.dart` (detect installs/versions), `installer_service.dart` (platform install).
- `lib/core/ffi/nexora_core.dart` — optional Rust binding with Dart fallbacks.
- `lib/features/home/` — `home_screen.dart` + widgets (`action_bar`, `app_card`, `section_header`, `title_bar`, `footer`).
- `rust/nexora_core/` — cdylib (`nexora_compare_versions`, `nexora_is_on_path`).
- `linux/`, `windows/` — platform runners. Binary name `nexora_launcher`; app id `com.nexora.launcher`.

## Gotchas

- Two different `NexoraColors`: this repo defines its own in `lib/core/theme/app_theme.dart`; the shared kit also exposes one. `home_screen.dart` hides the kit's (`hide NexoraColors, NexoraActionBar`) and imports the kit as `kit`. Don't mix them.
- Shared kit's real implementations live in `lib/src/...`; its top-level files are re-export shims. Edit `src/` in the kit repo, not shims, and not here.
- Version is maintained in multiple places by hand: `pubspec.yaml`, footer hardcode `'v26.10.27+4'` in `home_screen.dart`, `installedVersion` in `nexora_app.dart`, `build_windows.ps1`, and release artifact filenames. Keep them in sync.
- FFI library is optional: `libnexora_core.so`/`nexora_core.dll` must sit next to the binary; otherwise Dart fallbacks are used (`NexoraCore.isAvailable`).
- `hasUpdate` compares version strings with `!=`, not semver.
- GitHub calls are unauthenticated and best-effort; failures are swallowed.
- No automated tests (`test/` empty) — roadmap item.
- `flutter analyze` reports 2 minor issues (unused `_RefreshButton`, null-aware hint in `section_header.dart`); not errors.
- `cargo clippy` currently fails with 4 `not_unsafe_ptr_arg_deref` errors because the FFI entry points dereference raw pointers without being `unsafe fn`; `cargo build --release` still succeeds. Mark the functions `unsafe` (plus `# Safety` docs) to make clippy pass.
- Window uses transparent background + `ClipRRect` radius 14 (0 when maximized); title bar hidden; custom `NexoraWindowHeader`.
- Conventional Commits; branches `feat/`, `fix/`, `docs/`, `refactor/`.
