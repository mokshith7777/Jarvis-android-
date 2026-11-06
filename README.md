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

## Engineering improvements in this branch

- Brain Dump reminders now parse 12-hour and 24-hour local times and roll past times forward to the next day.
- Requested reminder times that cannot be parsed are reported as failures instead of silently scheduling at an unrelated time.
- Unsupported Brain Dump task and device-action types are reported as unsupported rather than falsely marked complete.
- To-do priority from the decomposed task is passed through to the local task service.
- Accessibility and background-permission explanations have been rewritten to describe actual Android behavior without promising unrestricted background execution.
- The Android launcher and accessibility labels use JARVIS Android branding.

## Development status

The upstream project history is retained as a merge parent. This branch adds project documentation, focused task-execution fixes, and GitHub Actions workflows. A source import is not a verified release: static analysis, tests, APK compilation, and device-level checks must pass before publishing.