# Changelog

## 2.1.2 - Current-source Android release

### Release and build pipeline
- Bump the Android app version to 2.1.2 / version code 212.
- Generate the missing Gradle wrapper during CI so the repository can build without committing machine-generated wrapper files.
- Keep Flutter dependency resolution, static analysis, tests, APK identity checks, and signature verification in the release pipeline.
- Publish the verified `JARVIS-PRO-v2.1.2.apk` directly to GitHub Releases.

### Privacy continuity
- Carry forward the v2.1.1 microphone privacy behavior. Always-On listening remains off by default, and voice capture requires an explicit user action unless separately enabled in Settings.
- This is a release/build refresh of the current GitHub mainline source, not the separate v3.0.0 ZIP source.


## 2.0.0 - JARVIS PRO

### Identity and platform
- Set project creator and architect identity to Mokshith Reddy in assistant identity templates and personality responses.
- Rename the Flutter package to `jarvis_android`.
- Set Android application ID to `com.mokshith.jarvis.ai`.
- Rename the visible app to JARVIS PRO.
- Move native Kotlin sources to the matching Android package directory.
- Migrate native MethodChannel identifiers to the JARVIS namespace.

### Visual system
- Establish an obsidian base with neon-blue and crimson/solar-orange accents.
- Update HUD, overlay, settings, and feature dialog accents.

### Brand launch and documentation
- Add a five-second portrait-oriented animated reactor intro before the main app.
- Refresh the adaptive launcher icon artwork with obsidian, electric-blue, crimson, and gold reactor rings.
- Expand README with feature explanations, APK installation, Android 13+ permission setup, Accessibility guidance, troubleshooting, source builds, and security notes.

### Build pipeline
- Target version 2.0.0 / version code 200.
- Run Flutter dependency resolution, static analysis, tests, APK build, package identity verification, and APK signature verification in GitHub Actions.
- Publish the verified APK as `JARVIS-PRO-v2.0.0.apk`.

### Compatibility and safety
- Preserve required third-party license notices.
- Keep sensitive Android capabilities permission-gated and user-visible.
