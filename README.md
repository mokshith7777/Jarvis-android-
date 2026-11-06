# JARVIS Android

A Flutter + native Android assistant focused on voice interaction, screen-aware workflows, and user-controlled automation.

## Project direction

JARVIS Android brings together a conversational assistant, a task-planning layer, and Android integrations. The engineering priorities for this repository are:

- A clear separation between planning, permission checks, execution, and verification.
- Explicit user control over sensitive actions.
- Local-first settings and conversation history.
- Observable task state, cancellation, and recovery.
- A maintainable Flutter UI with native Kotlin bridges.
- Reproducible Android builds through GitHub Actions.

## Current foundation

The codebase includes Flutter screens and widgets, AI-provider integration, voice services, task execution, memory and skill services, a floating assistant, and Android accessibility integration. Capabilities must be validated on real devices before being described as production-ready.

## Build

Requirements: Flutter SDK compatible with pubspec.yaml, Android SDK, and the JDK version required by the Gradle Android plugin.

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

The APK is generated at build/app/outputs/flutter-apk/app-release.apk.

## Security and permissions

Android accessibility, microphone, camera, contacts, notifications, and overlay capabilities are sensitive. Enable only the permissions required for a feature, explain their purpose, provide visible status, and allow the user to stop automation. Do not put API keys or signing credentials in source control.

## Upstream acknowledgement and license

This repository incorporates and is being developed from the MIT-licensed J.A.R.V.I.S. (PrivateAgent) Android project by **Abuzar Ansarii**:

- Upstream project: https://github.com/AbuZar-Ansarii/Jarvis
- The original MIT copyright and permission notice are retained in LICENSE.
- This is an independently maintained derivative. New work should be recorded in commits and release notes.

## Development status

A source import is not the same as a verified release. Run static analysis, tests, and device-level checks before publishing an APK.