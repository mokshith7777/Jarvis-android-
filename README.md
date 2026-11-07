
# JARVIS PRO

JARVIS PRO is an Android-first AI assistant project created and architected by **Mokshith Reddy**.

Repository: https://github.com/mokshith7777/Jarvis-android-

## Product direction

A configurable assistant with voice interaction, user-controlled screen-aware workflows, task planning, memory, and native Android integrations. Features that use accessibility, microphone, camera, contacts, notifications, or overlays must remain transparent, permission-gated, visible, and interruptible.

## Identity and architecture

- Creator and project architect: Mokshith Reddy.
- Flutter package: `jarvis_android`.
- Android application ID: `com.mokshith.jarvis.ai`.
- Application label: JARVIS PRO.
- Android release version: 2.0.0 (version code 200).

## Build and validate

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

The APK is generated at `build/app/outputs/flutter-apk/app-release.apk`.

## Security

Do not commit API keys, signing keys, passwords, or private tokens. Configure production signing credentials through protected GitHub Actions secrets. CI debug-signed APKs are for test installation only and are not Play Store production releases. Sensitive Android permissions must be requested only when a feature needs them, explained clearly, and controllable by the device owner.

## Licensing

JARVIS PRO's project-specific modifications and original branding are maintained by Mokshith Reddy. Existing third-party and upstream license notices remain intact where required by their licenses.
