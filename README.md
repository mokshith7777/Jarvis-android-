# JARVIS PRO

**A cinematic, Android-first personal AI assistant** built with Flutter and native Android integrations.

- **Project owner / creator:** Mokshith Reddy
- **Application:** JARVIS PRO
- **Android application ID:** `com.mokshith.jarvis.ai`
- **Flutter package:** `jarvis_android`
- **Current release:** `2.0.0 (200)`
- **Primary platform:** Android

> JARVIS PRO is an experimental personal assistant. It is not a system-level replacement for Android, and it cannot override Android security, permission, battery, or background-execution policies.

## Contents

1. [What JARVIS PRO does](#what-jarvis-pro-does)
2. [Feature guide](#feature-guide)
3. [Requirements](#requirements)
4. [Install the APK](#install-the-apk)
5. [First-time setup](#first-time-setup)
6. [Android 13 and newer](#android-13-and-newer)
7. [Accessibility and automation](#accessibility-and-automation)
8. [Privacy and permission controls](#privacy-and-permission-controls)
9. [Troubleshooting](#troubleshooting)
10. [Build from source](#build-from-source)
11. [GitHub Actions releases](#github-actions-releases)
12. [Version and migration notes](#version-and-migration-notes)
13. [Security and signing](#security-and-signing)
14. [Project structure](#project-structure)
15. [Credits and licensing](#credits-and-licensing)

---

## What JARVIS PRO does

JARVIS PRO combines a conversational assistant, voice input/output, task execution, screen-aware Android workflows, a floating control panel, and a collection of focused utilities. The app is designed around explicit user control: Android permissions are requested by the feature that needs them, and sensitive actions should remain visible and interruptible.

The visual system uses an obsidian-black interface, electric-blue reactor lighting, crimson highlights, and gold accents. On cold launch, a five-second portrait-oriented animated brand intro presents the reactor identity before opening the main app.

## Feature guide

### 1. Assistant modes
- **Agent mode:** submit a goal and let the task executor work through supported steps.
- **Chat mode:** ask questions and receive conversational responses.
- **JARVIS mode:** use the HUD-style assistant experience and voice-oriented controls.
- **Voice input:** speech recognition can populate the task/chat input when microphone permission and a compatible recognition service are available.
- **Text-to-speech:** supported assistant responses can be spoken through the Android TTS engine.

### 2. Task execution and history
- Submit a task in natural language.
- Follow the task transcript and current execution state.
- Pause, resume, or cancel supported tasks from the app controls.
- Review completed task/session information where available.
- Use the Brain Dump workspace to break a broad request into smaller actions.

Task execution is limited by the app's implemented integrations, Android version, permissions, the active app, and the device manufacturer. It is not a guarantee that every third-party app can be controlled.

### 3. Screen automation and Accessibility
The optional Accessibility service can inspect on-screen accessibility nodes and perform user-requested UI actions such as tapping, scrolling, or entering text in supported contexts.

- The service is **off until the user enables it** in Android Settings.
- The service is not a hidden permission and cannot be enabled silently by the app.
- Review the service description and Android's confirmation screen before enabling it.
- Keep the app visible when starting automation and use the in-app stop/cancel controls.
- Do not use automation to access another person's private information or to perform actions without authorization.

### 4. Floating assistant
The floating bubble provides a compact control surface over other apps.

- Android requires the user to grant the **Display over other apps** permission.
- The bubble can be shown or closed from the app.
- Drag it to a convenient position.
- Disable the permission or close the bubble when it is not needed.

### 5. Voice, reminders and notifications
Depending on the feature and device configuration, JARVIS PRO can use:
- Microphone access for speech recognition.
- Android text-to-speech.
- Notification permission for app notifications.
- Notification-listener access for supported inbox/notification workflows.
- Calendar/reminder and to-do utilities included in the project.

Notification-listener access can expose notification content to the app. Enable it only if you understand and want that behavior.

### 6. Stark Command Center utilities
The Command Center groups the following built-in workspaces:

| Utility | Purpose |
|---|---|
| Optical Solver | Visual reasoning and image-related workspace |
| Airspace Radar | Radar-style visualization workspace |
| Network Audit | Local network diagnostics |
| Polyglot Diplomat | Translation and language tools |
| Air Gestures | Gesture-control interface |
| Reactor Telemetry | Battery and charging information HUD |
| Brain Dump Decoupler | Break down a broad request into smaller tasks |
| Code Black | User-controlled security console |

Availability and results depend on the relevant Android capabilities and permissions. A utility label does not imply that the phone has specialist sensors or privileged system access.

### 7. Reactor telemetry
The charging HUD displays supported device charging and battery metrics when the operating system exposes them. Values may be unavailable or estimated on some devices.

### 8. Telegram integration
The project includes an optional Telegram task interface. It requires the user to configure the bot and chat settings. Keep bot tokens private, restrict who can message the bot, and never commit credentials to the repository.

---

## Requirements

### For APK installation
- Android phone or tablet supported by the current Flutter/Android build.
- Internet access for features that call remote services.
- Enough free storage for the APK and app data.
- Android system permission prompts accepted only for features you intend to use.

### For building from source
- Flutter SDK matching the Dart SDK constraint in `pubspec.yaml`.
- Android SDK and Android build-tools.
- Java 17 for the configured CI build.
- Git.

---

## Install the APK

### Download

1. Open the [JARVIS PRO v2.0.0 GitHub Release](https://github.com/mokshith7777/Jarvis-android-/releases/tag/v2.0.0).
2. In **Assets**, download **JARVIS-PRO-v2.0.0.apk**.
3. Wait for the download to finish. Do not rename the file while installing.
4. Open the downloaded APK from the Android Downloads app or your file manager.
5. If Android asks which app may install this APK, choose the browser or file manager you used and enable **Allow from this source** for that source only.
6. Return to the installer and tap **Install**.
7. When installation finishes, open JARVIS PRO.

The setting is commonly found under **Settings → Apps → Special app access → Install unknown apps**. Names and menu placement vary by manufacturer and Android release. Turn this permission off again if you no longer need it.

### Play Protect and installation warnings

JARVIS PRO is distributed as an APK outside Google Play. Google Play Protect may scan it or display a warning because it is a sideloaded app or because the signing identity is not a Play-distributed identity.

- Do not assume a warning is harmless.
- Check that the APK came from the official release page linked above.
- Compare its SHA-256 digest with the release notes before installing.
- If Play Protect blocks or warns about the file, read the warning and make your own informed decision. Do not follow instructions that tell you to disable device security globally.
- This project does not bypass Play Protect, Android package verification, or device security checks. No README can guarantee a warning-free installation.

**Release SHA-256 (v2.0.0):**

```
c56ebad10702d0d1590a108a3fca9ccd388d9c9f7c7697fd8264462ce854e69b
```

On a computer, verify with `sha256sum JARVIS-PRO-v2.0.0.apk`. On Android, use a trusted checksum utility if you want to verify the downloaded file before installation.

---

## First-time setup

1. Launch JARVIS PRO and allow the five-second cinematic intro to complete.
2. Complete the onboarding flow.
3. Open Settings and review the available assistant and voice options.
4. Start in Chat mode to test basic interaction.
5. Grant microphone permission only if you want voice input.
6. Enable Accessibility only if you intend to use supported screen automation.
7. Enable overlay access only if you want the floating assistant bubble.
8. Configure optional integrations, such as Telegram, only after reading their setup and privacy requirements.
9. Test with a harmless task before using the assistant for anything important.

You can deny optional permissions and still use parts of the app. Features that depend on a denied permission will be unavailable.

## Android 13 and newer

Android 13+ introduces or tightens several runtime and special-access permission flows. The exact wording varies across Pixel, Samsung, Xiaomi, OnePlus, Realme, Vivo, Oppo, and other Android builds.

### Notifications
- Android 13 (API 33) and newer generally require runtime notification permission.
- If you deny it, JARVIS PRO may not be able to show normal notifications.
- Change it later in **Settings → Apps → JARVIS PRO → Notifications**.

### Microphone
- Grant microphone access only when using speech input or another feature that clearly requires it.
- Change it in **Settings → Apps → JARVIS PRO → Permissions → Microphone**.

### Camera
- Camera permission should be granted only when using an explicitly requested camera/visual feature.
- Change it in **Settings → Apps → JARVIS PRO → Permissions → Camera**.

### Photos, videos and files
- Android uses scoped storage and per-media/document access. Do not expect old unrestricted file-system behavior.
- Use Android's system file picker when a feature offers it.
- Broad all-files access, where present, is a sensitive special permission and should not be granted unless the feature genuinely requires it and the user understands why.

### Overlay access
- Open **Settings → Apps → Special app access → Display over other apps → JARVIS PRO**.
- Enable it only to use the floating bubble.
- Return to JARVIS PRO and activate the bubble from the app.

### Battery and background operation
- Android and device manufacturers may pause background work to save battery.
- If you rely on a supported background feature, review **Settings → Apps → JARVIS PRO → App battery usage**.
- Choose an unrestricted or unrestricted-background option only if your device offers it and you understand the battery impact.
- Some manufacturers add separate Auto-start or background-activity controls.
- Android may still stop background work. JARVIS PRO cannot guarantee permanent background execution.

---

## Accessibility and automation

Accessibility is a powerful Android capability intended to help users interact with apps and the device. It can expose on-screen text and controls to an enabled service. Treat it as sensitive access.

### Enable the service manually

1. Open Android **Settings**.
2. Go to **Accessibility**.
3. Open **Downloaded apps**, **Installed apps**, or **Installed services**. The label varies by device.
4. Select **JARVIS PRO** or its accessibility-service entry.
5. Read the Android disclosure screen carefully.
6. Enable the service only if you want to use screen automation.
7. Return to JARVIS PRO and check the service status indicator.

If the entry is not visible, open JARVIS PRO once, check for app updates, and restart the phone. Some OEM settings pages use different labels.

### Use it responsibly

- Start actions yourself from JARVIS PRO.
- Keep the task transcript visible and review what the assistant is doing.
- Stop the task if the target screen or action is unexpected.
- Disable the service in Android Settings when you no longer need it.
- Never enable Accessibility for an app you do not trust.

**There is no legitimate way for an ordinary app or README to grant unrestricted Accessibility access automatically.** Android intentionally requires the device owner to enable this special access. Android 13+ does not provide a universal bypass for it.

---

## Privacy and permission controls

JARVIS PRO may request access to microphone, camera, contacts, SMS, notifications, Accessibility, overlay, usage statistics, storage, and system settings depending on the included feature set.

Before granting access:
1. Open the Android permission screen and read what is requested.
2. Enable only permissions needed for the feature you plan to use.
3. Avoid enabling SMS, contacts, notification access, usage access, or broad file access unless you explicitly need the corresponding feature.
4. Review app permissions periodically.
5. Disable sensitive special access when finished.

The project should not be used for covert monitoring, hidden recording, unauthorized account access, or collecting another person's data. Keep integrations transparent and user-controlled.

---

## Troubleshooting

| Problem | What to try |
|---|---|
| APK will not install | Confirm the download completed, check available storage, and download again from the official release page. |
| “App not installed” | Check Android version compatibility and whether a conflicting build with the same package is installed. |
| Play Protect warning | Verify the source and SHA-256. Read the warning; do not disable device protection globally. |
| Accessibility service is missing | Open the app once, reboot, check Android's Installed services list, and confirm the installed package is JARVIS PRO. |
| Automation says service is off | Enable the service manually in Android Accessibility settings, then return to the app. |
| Floating bubble does not appear | Grant Display over other apps permission and retry from the app. |
| Voice input does not work | Check microphone permission, internet connection if required, and whether a speech recognition service is installed. |
| Notifications are missing | Check Android notification permission and app notification settings. |
| Background work stops | Review battery optimization and manufacturer auto-start settings. Android may still restrict background work. |
| Telegram is not responding | Check bot configuration, network access, chat authorization, and that secrets are not expired. |

---

## Build from source

Clone the repository:

```bash
git clone https://github.com/mokshith7777/Jarvis-android-.git
cd Jarvis-android-
git checkout jarvis-pro-v2
```

Install dependencies and validate:

```bash
flutter doctor -v
flutter pub get
flutter analyze
flutter test
```

Build a release APK:

```bash
flutter build apk --release
```

Output:

```
build/app/outputs/flutter-apk/app-release.apk
```

For a connected Android device, enable USB debugging and run:

```bash
flutter devices
flutter install
```

### Production signing

The public CI workflow currently creates a CI/debug-signed APK for testing. For a production distribution:
1. Create and securely back up a private Android upload/release keystore.
2. Store keystore data and passwords as protected GitHub Actions secrets.
3. Configure Gradle signing to load those secrets at build time.
4. Never commit a keystore, passwords, or signing properties.
5. Keep the same signing identity for future updates to the same Android application ID.

A Play Store release also requires compliance with current Google Play policies, target API requirements, app-content declarations, and testing requirements.

---

## GitHub Actions releases

The workflow at `.github/workflows/build-android.yml` runs on pushes to the configured branches when relevant source, test, Android, asset, or build files change. It can also be started manually from the repository's **Actions** tab.

The workflow:
1. Checks out the source.
2. Installs Java 17 and Flutter stable.
3. Resolves Flutter dependencies.
4. Runs `flutter analyze`.
5. Runs `flutter test`.
6. Builds the release APK.
7. Verifies package ID, version name, version code, and APK signature.
8. Calculates SHA-256.
9. Uploads the APK as a workflow artifact.
10. Publishes the versioned APK to GitHub Releases.

Release artifact naming:

```
JARVIS-PRO-v2.0.0.apk
```

---

## Version and migration notes

Version 2.0.0 uses the Android application ID `com.mokshith.jarvis.ai`. Earlier builds used a different application ID. Android treats a changed application ID as a separate app:

- Install v2.0.0 as a new app.
- The old app can remain installed alongside it.
- Existing preferences and local data from the old package are not automatically migrated.
- Export or back up any data you need before removing the previous installation.

---

## Security and signing

- Do not store API keys, Telegram tokens, private URLs, passwords, or signing material in source control.
- Use GitHub Actions secrets for private build credentials.
- Keep Android permissions optional and feature-specific.
- Accessibility, notification-listener, overlay, usage-statistics, and all-files access are sensitive capabilities.
- CI signature verification confirms the APK is signed; it does not mean the APK is Play Store certified or production signed.

## Project structure

```
android/                 Native Android project, manifest, Kotlin services
assets/                  App artwork and bundled images
docs/                    Architecture and project documentation
lib/
  overlay/               Floating overlay UI
  screens/               Home, onboarding, settings and session screens
  services/              Assistant, task, voice and Android integration services
  theme/                 App theme and visual tokens
  widgets/                HUDs, dialogs and reusable UI
test/                    Flutter tests
.github/workflows/       CI build, test and release automation
web/                     Flutter web shell and manifest
```

## Credits and licensing

JARVIS PRO project branding and this fork's project-specific development are maintained by Mokshith Reddy. The repository may include third-party packages and upstream-derived code. Existing license files and required copyright notices are retained; consult those notices for the applicable terms.
