# JARVIS PRO

**Android-first personal AI assistant** built with Flutter, Dart, and native Android integrations.

- **Package ID:** `com.mokshith.jarvis.ai`
- **Latest public release:** [v3.3.1](https://github.com/mokshith7777/Jarvis-android-/releases/tag/v3.3.1)
- **Source version:** `3.3.1+331`
- **Platform:** Android (API 26+)
- **Stack:** Flutter/Dart + Kotlin + optional Termux local worker

JARVIS PRO combines conversational AI, voice input/output, configurable AI providers, user-approved Android workflows, and optional local AI tooling. It is experimental software; capabilities depend on Android version, permissions, device hardware, installed apps, and configured providers.

## Download

Download the versioned APK from [GitHub Releases](https://github.com/mokshith7777/Jarvis-android-/releases). Review release notes and checksums before installing. **The existing v3.3.1 release is a debug-signed testing build, not a production release.** New CI builds without signing secrets are uploaded as testing artifacts only. Signed publishing is restricted to version tags and requires a private signing key.

## Features

- Chat, voice input, and text-to-speech.
- Local-first configuration with optional hosted AI providers and local model endpoints.
- Optional Termux worker for local inference and media tools; installed and started separately.
- User-triggered Android app and screen workflows through the accessibility service.
- Local task history, preferences, and optional indexing.
- Telegram bot integration when explicitly configured and paired with authorized chat IDs.
- Cinematic intro and branded launcher assets.

Feature availability is conditional. Sensitive features require user permission or explicit enablement; no permission is silently bypassed.

## Privacy and permissions

JARVIS may request sensitive Android permissions for specific features, including microphone, camera, contacts, SMS, notifications, accessibility, overlay, storage, app visibility, and usage access. Review each permission prompt and only enable features you need.

- Always-on microphone listening is OFF by default.
- Social/notification indexing is opt-in and uses an allowlist.
- Screen automation is user-driven and can interact with visible app UI.
- Telegram actions require local bot configuration and authorized chat IDs.
- Local index data is stored in app-private SQLite and can be cleared from the app.
- Local Termux worker is intended to bind to loopback; see its documentation and the security notes.

Read [SECURITY.md](SECURITY.md) before installing or exposing any local endpoints.

## Build from source

Prerequisites: Flutter SDK matching `pubspec.yaml`, Java 17, Android SDK/build tools, and Python for the Termux worker checks.

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

GitHub Actions validates Dart analysis, tests, Termux worker syntax, the committed Gradle wrapper, APK package/version identity, and signature. To publish a new signed release, create and push a matching version tag (for example `v3.4.0`) after updating `pubspec.yaml`, and configure these repository secrets: `JARVIS_RELEASE_KEYSTORE_BASE64`, `JARVIS_RELEASE_STORE_PASSWORD`, `JARVIS_RELEASE_KEY_ALIAS`, and `JARVIS_RELEASE_KEY_PASSWORD`. Keep the keystore and passwords private. Without them, CI uploads a debug APK artifact for testing only; it will not publish a GitHub Release. The release job refuses to overwrite an existing release tag.

## Project status

| Version | Status |
|---|---|
| 3.3.1+331 | Public release: cinematic splash video + launcher branding integration |
| 3.3.0+330 | Earlier source iteration |
| 3.2.0+320 | Development branch work: provider routing, local-first appointments, and opt-in metadata workflows |

## Project links

- [Releases](https://github.com/mokshith7777/Jarvis-android-/releases) (APK distribution; GitHub Packages is not used)
- [Changelog](CHANGELOG.md)
- [Actions](https://github.com/mokshith7777/Jarvis-android-/actions)
- [Architecture](docs/ARCHITECTURE.md)
- [Issues](https://github.com/mokshith7777/Jarvis-android-/issues)

## License

MIT. See [LICENSE](LICENSE).
