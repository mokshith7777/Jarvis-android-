# JARVIS Android

A personal Android AI assistant project built around voice interaction, screen-aware workflows, task execution, and user-controlled automation.

## Project vision

JARVIS is being developed as a customizable Android assistant. The goal is to evolve its identity, interface, capabilities, and app structure into a cohesive product.

## Core engineering priorities

- A clear separation between planning, permission checks, execution, and verification.
- Explicit user control over sensitive actions.
- Local-first settings and conversation history.
- Observable task state, cancellation, and recovery.
- A maintainable Flutter UI with native Kotlin integrations.
- Reproducible Android builds through GitHub Actions.

## Current capabilities

The current codebase contains Flutter screens and widgets, AI-provider integration, voice services, task execution, memory and skill services, a floating assistant, and Android accessibility integration. Actual device behavior must be validated before any capability is described as production-ready.

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

## Development roadmap

- Establish the JARVIS visual identity, launcher icon, and app naming.
- Redesign the main assistant experience and navigation.
- Refactor the app into clear feature modules.
- Improve task planning, execution feedback, and recovery.
- Validate permissions and background behavior on real Android devices.
- Ship signed, reproducible APK releases.