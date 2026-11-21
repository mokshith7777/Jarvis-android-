# Changelog

## 3.3.0+330 — Development (not yet publicly released)

- Bumped the app version to 3.3.0 (build 330).
- Refreshed public-facing README to distinguish stable releases from development builds.
- Branding assets supplied for this version: cinematic 8-second portrait splash video and reactor launcher icon.
- **Branding integration status:** source assets have been prepared, but they are not yet committed to the Android project/APK due to the current binary-transfer limitation. The app still uses the existing Flutter splash implementation.
- CI build #200 on the feature branch passed Flutter analysis, tests, release APK build, APK identity/signature verification, and artifact upload. It is a development artifact, not a public release.
- Build #200 artifact: [Actions run](https://github.com/mokshith7777/Jarvis-android-/actions/runs/44887974021).

## 3.2.0+320 — Development

- Added pure-Dart provider fallback router, loopback HTTP gateway, provider configuration UI, telemetry, and cooldown circuit breaker.
- Added local-first appointments with CRUD, status transitions, calendar export, and explicit Telegram summary actions.
- Added opt-in call triage with native Call Log permission request and metadata-only recent-call query; create appointments or review Telegram summaries before sending.
- Added navigation and bumped version to 3.2.0+320.
- Package ID and min SDK unchanged.
- Telegram is the only external messaging integration. No Firebase or WhatsApp was added.
- No automatic Telegram sends: UI send actions require confirmation.
- Call metadata is permission-gated and no call audio is accessed.
- Local AI direct mode remains fallback when embedded gateway is stopped or disabled.

## 3.0.0+300

- Defaulted to JARVIS Local Index AI at http://127.0.0.1:9000/v1 with model local-vision.
- Added local backend host recognition for loopback, private LAN, Tailscale and .local.
- Added native Android SQLite/FTS4 memory with 30-minute content-hash deduplication, search, stats and wipe.
- Added explicitly opt-in, throttled social-screen and notification indexing for the allowlisted apps.
- Added separate Termux local worker for llama.cpp, local browsing, image generation, video editing and storyboard rendering.
- Preserved v2.1.3 microphone lifecycle, Always-On privacy migration, media audio-focus protection and Gradle 9.3.1 wrapper bootstrap.

### Preserved fixes
- 2a64717: native one-shot SpeechRecognizer cancel/destroy lifecycle.
- mic_privacy_migration_v1: Always-On OFF by default; JARVIS mode alone does not start capture.
- isMediaPlaybackActive: existing media playback suppression in MainActivity.kt retained.
- CI wrapper: isolated Gradle 9.3.1 wrapper generation retained.

### Privacy
- Social indexing is OFF by default and explicitly user-controlled.
- Screen capture is scroll-triggered, allowlisted and throttled to 3.5 seconds.
- Notification indexing uses the same opt-in and allowlist.
- Indexed content is stored in app-private SQLite; clear index wipes source and FTS tables.

### CI recovery note

- Initial v3 test run: 68 passed, 1 failed because local-index MethodChannel calls were intentionally fire-and-forget but raised MissingPluginException in Flutter unit tests without an Android host. Correction: LocalIndexService now treats MissingPluginException and PlatformException as an unavailable native index and safely returns empty/no-op results. Android production calls still use the same native bridge.

- CI analyzer recovery: removed an unused notification argument left after converting Sentry reporting to text-only motion telemetry; `flutter analyze --no-fatal-infos` treats warnings as failures.

- CI workflow correction: replaced over-escaped sed grouping in version extraction with shell parameter expansion so pubspec version and build code are read reliably.
- Voice command parsing correction: normalized raw-regex whitespace escapes in local worker triggers.

- Termux media pipeline correction: use auto-editor's documented `-o` output flag, and run FFmpeg loudness normalization through the audio filter (`-af`), not the video filter (`-vf`). Added Python syntax validation to CI.

- UI copy cleanup: updated local-first settings to describe the Termux worker endpoint and clarified that wake-word listening is OFF by default.
