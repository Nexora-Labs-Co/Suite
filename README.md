# Nexora Launcher

A desktop control center for the Nexora ecosystem (Harmony and other tools).
Targets **Windows** and **Linux** only. Android apps are distributed as APKs.

## Stack

- Flutter (desktop)
- Rust (`rust/nexora_core`) exposed through `dart:ffi` for native helpers
  (version comparison, PATH detection, package installation helpers).
- GitHub Releases API for update detection.

## Run

```bash
flutter pub get
flutter run -d linux   # or windows
```

Build the optional Rust core:

```bash
cd rust/nexora_core
cargo build --release
# Linux: copy target/release/libnexora_core.so next to the app binary
# Windows: copy target/release/nexora_core.dll next to the app binary
```

## Structure

```
lib/
  main.dart
  app.dart
  core/
    theme/app_theme.dart          # monochrome palette
    models/nexora_app.dart       # app model + catalogue
    services/
      github_service.dart        # /releases/latest
      app_catalog_service.dart   # load + enrich + detect installed
      installer_service.dart     # download + install per platform
    ffi/nexora_core.dart        # Rust FFI binding (optional)
  features/home/
    home_screen.dart
    widgets/
      title_bar.dart
      action_bar.dart
      app_card.dart
      section_header.dart
      footer.dart
rust/nexora_core/                # Rust cdylib
```

## Design

Strictly monochrome: background `#090C02`, foreground `#EBF5EE`, neutral greys.
No accent colors.

## Update flow

1. `AppCatalogService.load()` fetches `/repos/{repo}/releases/latest` for each app.
2. Installed apps are detected via `NexoraCore.isOnPath`.
3. `InstallerService.install()` downloads the platform asset and runs the
   appropriate installer (`dpkg`/`pkexec` on Linux, `msiexec`/silent `.exe`
   on Windows).
