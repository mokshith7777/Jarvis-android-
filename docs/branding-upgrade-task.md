# JARVIS PRO Cinematic Branding Upgrade + APK Self-Repair Build

Repository: mokshith7777/Jarvis-android-
Target branch: feat/v3.2-gateway-caller-telegram
Base branch: main

## Objective
Transform the existing JARVIS PRO Android app into a premium cinematic AI product using the new reactor identity. Implement the branding upgrade, generate splash animation/video assets, replace outdated branding, integrate assets, build a release APK, and continuously diagnose and fix failures until a verified build succeeds. Never merge into main; work only on the feature branch.

## Identity
- OLED/obsidian black, dark navy secondary surfaces
- Metallic chrome reactor armor
- Electric cyan reactor illumination
- Neon crimson/red glowing central letter J
- Premium futuristic HUD, controlled bloom, subtle reflections, particles
- Futuristic typography, minimal clutter, premium product appearance
- Keep the same reactor symbol consistent across icon, logos, splash, and UI

## Logo system
Create: horizontal logo, vertical logo, reactor-only emblem, minimal J monogram, splash logo, small UI-compatible logo. Central metallic J with crimson glow inside the cyan-lit reactor. Do not invent unrelated AI symbols.

## App icon
Replace the launcher icon completely. Use the generated reactor reference if accessible. Center metallic J, cyan reactor structure, crimson neon J, no text or watermark. Avoid clipped borders and ensure recognizability at small sizes. Generate adaptive foreground/background and legacy launcher assets at required densities. Update manifest/references, remove obsolete assets only after checking all usages. Preserve package identity.

## Cinematic splash (3–5 seconds)
1. Init: OLED black, faint cyan HUD outline, subtle energy particles.
2. Assembly: reactor segments assemble/illuminate sequentially with subtle mechanical motion.
3. Ignition: cyan core pulses; metallic J appears with crimson neon.
4. Sync: rings synchronize, subtle HUD and waveform.
5. Reveal: JARVIS PRO, subtitle PERSONAL AI COMMAND CENTER; chrome JARVIS, crimson PRO, cyan reactor.
6. Settle and transition smoothly into app; no abrupt flashes or unnecessary launch delay.

## Video/animation assets
Create production-ready assets. Prefer Flutter-native animation, Lottie, or efficient vector/sequence animation. If FFmpeg is available, generate portrait 1080x1920 H.264 MP4 with smooth motion and optimized size. If video generation is impractical, implement an equivalent polished animated Flutter/Lottie splash, not a static image. Avoid heavy dependencies and battery drain.

## Branding replacement
Search the entire repository for old logos/icons/colors/splash branding. Update launcher, splash, home, drawer, headers, voice/listening/speaking, gateway, caller assistant, appointments, settings, about, notification icons, backgrounds, empty/loading states. Preserve functionality, navigation, permissions, provider routing, Telegram, caller assistant, settings, offline/fallback.

## Interactive reactor states
Idle: subtle cyan breathing.
Listening: reactor reacts to mic input level and waveform.
Thinking: subtle ring rotation/energy pulse.
Speaking: waveform reacts to TTS when possible.
Error: controlled red alert pulse.
Offline: dim reactor and clear offline indication.
Use smooth battery-conscious animation; pause/reduce when backgrounded.

## Technical constraints
Preserve applicationId com.mokshith.jarvis.ai, existing signing configuration, functionality, provider/fallback, Telegram integration, permissions unless justified, and versioning conventions. Do not push to main, merge, remove functionality, expose keys, hardcode credentials, add Firebase, or add WhatsApp.

## Build and self-repair
Run dependency resolution, formatting, flutter analyze, tests, Android Gradle validation, release APK build, artifact existence/integrity, package identity, signing, size, contents, emulator/device install smoke test where available, launch, splash, icon, navigation.
If any check fails: inspect actual logs, identify root cause, fix source/config, commit fix to feature branch, and rebuild. Do not rerun without fixing root cause. Implement reliable bounded GitHub Actions recovery where possible: preserve diagnostics, avoid uncontrolled/infinite loops, limit concurrent builds, respect workflow execution limits, document recovery. A green workflow alone is not proof.

## Final verification
Confirm APK exists, artifact uploads/downloads, valid APK/ZIP, package identity, signing certificate, nonempty/corruption-free, installation and launch on emulator/device if available, splash and launcher icon visible, main app loads without immediate crash. If physical device testing unavailable, say so and perform strongest available emulator/static checks.

## Deliverables
Commit to feature branch; include icon/adaptive assets, logo variants, splash/video/animation, app branding changes, Android resources, workflow improvements, tests, and verification report. Update Draft PR. Report commit hashes, files changed, build/test evidence, APK artifact link, checksum, package/signing/install/launch verification, and remaining issues. Never claim a check passed without evidence.