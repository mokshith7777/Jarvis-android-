# Changelog

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
