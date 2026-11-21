# Changelog

## 3.3.0+330 — Development build (not a public release)

- Development version number prepared on feature branch.
- README refreshed to show the latest public release and in-development status.
- CI build #200 passed Flutter analysis, tests, release APK build, identity/signature verification, and artifact upload.
- New reactor launcher icon and cinematic splash assets have been prepared but are **not yet integrated into the Android project or this APK**.
- The build artifact is available from the Actions run, not from the public Releases page.

## 3.2.0+320 — Development branch

- AI gateway and provider fallback routing.
- Provider configuration and telemetry/cooldown circuit breaker.
- Local-first appointments and calendar export.
- Opt-in call triage using permission-gated metadata only.
- Explicit Telegram summary actions; no automatic sends.

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
