# JARVIS PRO

**Android-first personal AI assistant** built with Flutter and native Android integrations.

- **Package ID:** `com.mokshith.jarvis.ai`
- **Current public release:** [v3.1.0](https://github.com/mokshith7777/Jarvis-android-/releases/tag/v3.1.0)
- **Current main source version:** `3.3.0+330` (branding update in progress; not yet a published release)
- **Platform:** Android
- **Build:** Flutter / Dart + native Android

> Experimental personal assistant. It does not bypass Android permissions, security policies, or background execution limits.

## Download
Use the [GitHub Releases page](https://github.com/mokshith7777/Jarvis-android-/releases) for public, versioned APK downloads. Only releases listed there are public releases.

The source version on `main` is now v3.3.0. A public release will be created only after the cinematic splash video and launcher icon are integrated and the APK is verified.

## Highlights
- Chat, voice input and text-to-speech modes.
- User-controlled task workflows and Android integrations.
- Local-first AI configuration with optional cloud providers.
- Provider routing/fallback and local gateway development in v3.2 branch.
- Local appointments and opt-in call metadata workflows in v3.2 development.
- Telegram integration with explicit user configuration/confirmation.
- Termux worker is a separate optional setup; it is not bundled with the APK.

Features depend on Android version, permissions, installed apps, provider configuration, and device capabilities.

## Privacy & safety
- Always-on microphone listening is OFF by default.
- Entering JARVIS mode alone does not start microphone capture.
- Sensitive Android permissions are requested by features that need them.
- Call triage is permission-gated and uses metadata; it does not access call audio.
- Telegram actions require explicit configuration and confirmation; no automatic message sending.
- Local indexing features are opt-in where applicable.

## Build from source
Prerequisites: Flutter SDK matching the Dart constraint in `pubspec.yaml`, Java/Android SDK, and Android build tools.

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

CI also validates Termux worker syntax and checks APK identity/signature before uploading an artifact.

## Project status
| Version | Status |
|---|---|
| 3.1.0 | Latest public GitHub release |
| 3.2.0 | Development branch / Draft PR #5 |
| 3.3.0+330 | Main source version bumped and vector splash branding refreshed. Cinematic MP4 and uploaded launcher PNG are still pending repository integration. |

## Releases & changelog
- [GitHub Releases](https://github.com/mokshith7777/Jarvis-android-/releases)
- [CHANGELOG](CHANGELOG.md)
- [CI builds](https://github.com/mokshith7777/Jarvis-android-/actions)

## Security
Do not commit API keys, tokens, private signing keys, personal data, or secrets. Use local secure storage or GitHub Actions secrets where appropriate. CI artifacts may use debug signing and are not automatically production-ready.

## Contributing / reporting issues
Use [Issues](https://github.com/mokshith7777/Jarvis-android-/issues) for bugs and feature requests. Development changes are reviewed through pull requests; check PR status before treating development versions as stable.
