# JARVIS PRO

Android-first personal AI assistant built with Flutter, Dart, and native Android integrations.

> **Experimental software.** This repository and APK are not a security-certified product. Review the permissions, source, and security notes before installation. Do not use with confidential data, production credentials, or accounts you cannot risk.

## Project overview

- Android application with chat, voice input/output, configurable AI provider connections, and user-approved device workflows.
- Optional Termux companion worker for local tools and model integrations.
- Feature availability depends on Android version, permissions, installed apps, hardware, and configured services.

## Downloads and distribution

Download APK builds from [GitHub Releases](https://github.com/mokshith7777/Jarvis-android-/releases).

GitHub **Packages is not used** for this project. APK distribution is via Releases and workflow artifacts; no container or package registry is published. Do not install workflow artifacts as production builds.

- Latest public release: [v3.3.1](https://github.com/mokshith7777/Jarvis-android-/releases/tag/v3.3.1)
- Current source version: 3.3.1+331
- Existing public v3.3.1 APK is debug-signed and for testing only.
- Release publication requires a privately-held signing key configured in GitHub Actions. Builds without it are not published as Releases.

## Features

- Chat, voice input, and text-to-speech.
- Configurable hosted AI providers and local model endpoints.
- Optional local Termux worker.
- User-driven Android app/screen workflows.
- Local task history, settings, and optional indexing.
- Optional integrations such as Telegram and Home Assistant.

These features may request sensitive permissions. Enable only features you use and review each permission before granting it.

## Privacy and permissions

JARVIS can request microphone, camera, contacts, SMS, notifications, accessibility, overlay, storage, app-visibility, usage-access, or Shizuku permissions. Some integrations may process screen/notification data or send requests to configured third-party providers.

- Always-on listening is intended to be disabled by default.
- Indexing and sensitive integrations are opt-in.
- Review provider privacy terms and data handling before connecting accounts.
- Avoid entering passwords, API keys, private messages, financial data, or other confidential content into experimental builds.
- Clear local app data and revoke permissions when you no longer use a feature.

## Security status

See [SECURITY.md](SECURITY.md) for the review scope, known risks, mitigation status, and reporting guidance. This is a code/configuration review, not a penetration test or a guarantee that the application has no vulnerabilities.

Known outstanding risks include local worker authentication, SSRF/DNS-rebinding defenses, broad Android permissions, global cleartext networking, release signing configuration, and testing on physical devices.

## Build and test

Prerequisites: Flutter SDK compatible with the project, Java 17, Android SDK/build tools, and Python 3 for worker syntax checks.

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

CI workflows are in [.github/workflows](.github/workflows). Inspect workflow logs and release notes; a green build does not prove security.

## Repository metadata / About

Suggested GitHub About description:

**Android-first AI assistant with voice, configurable AI providers, local tools, and user-controlled device workflows.**

Suggested topics: `android`, `flutter`, `dart`, `ai-assistant`, `voice-assistant`, `termux`.

## Links

- [Releases (APK)](https://github.com/mokshith7777/Jarvis-android-/releases)
- [Actions / CI](https://github.com/mokshith7777/Jarvis-android-/actions)
- [Security report](SECURITY.md)
- [Changelog](CHANGELOG.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Issues](https://github.com/mokshith7777/Jarvis-android-/issues)

## License

MIT. See [LICENSE](LICENSE).
