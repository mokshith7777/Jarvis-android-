# Security review and publishing checklist

Review date: 2026-11-21  
Scope: public repository configuration, GitHub Actions workflows, Flutter/native Android permissions, Termux worker routes, and selected storage/notification/automation code. This is a source review, not a penetration test, device test, or exhaustive secret scan.

## Findings

### High — Release signing must use a private key
Release builds no longer use the Android debug signing key. CI creates an installable debug APK when release signing secrets are absent and does not publish it to Releases. Release publishing is gated on a configured private key. Configure the protected secrets `JARVIS_RELEASE_KEYSTORE_BASE64` (base64-encoded keystore), `JARVIS_RELEASE_STORE_PASSWORD`, `JARVIS_RELEASE_KEY_ALIAS`, and `JARVIS_RELEASE_KEY_PASSWORD` before publishing. Never commit the keystore or passwords. Keep a protected backup and document key rotation.

### High — Termux worker endpoints have no authentication
The worker binds to `127.0.0.1`, which prevents remote network access by default, but localhost is shared by apps on Android. The POST routes can trigger local inference, image/video processing, and browsing. The video-edit endpoint accepts an input path readable by the Termux user. Treat this worker as trusted local software only; do not bind it to `0.0.0.0` or expose it through a tunnel/port-forward. Add a pairing secret or another caller-authentication mechanism before treating it as hardened.

### High — Browser-fetch route has partial SSRF mitigation, not a complete guarantee
The worker's `/browse` route fetches search-result URLs. The code now rejects credentialed/non-HTTP URLs and validates resolved addresses as public, including redirects. This reduces SSRF risk, but DNS validation and the later connection are not pinned to the same address (DNS-rebinding race), so this is not a complete SSRF defense. Do not expose the worker to untrusted callers.

### High — Broad Android permission surface
The manifest requests permissions including microphone, camera, contacts, SMS, notification access, accessibility/window content, overlays, all-files access, app visibility, usage stats, and Shizuku integration. These permissions are sensitive and feature-dependent. The app must keep permissions opt-in, explain the data/action involved, minimize collection, and provide disable/clear controls. Publishing through Play Store would require a separate policy and permission eligibility review.

### Medium — Cleartext networking is globally enabled
The manifest sets `android:usesCleartextTraffic="true"` to support local worker HTTP endpoints. This permits cleartext traffic beyond loopback unless additional network-security restrictions are configured. Prefer HTTPS for cloud endpoints and a network security config narrowly permitting local traffic only. Verify all provider endpoints and local URLs before shipping.

### Medium — Notification/screen content can be sensitive
Notification triage and opt-in indexing may process message snippets, screen text, and notification metadata. Keep opt-in explicit, retention bounded, source allowlisted, user-visible, and wipeable. Avoid logging message contents, screenshots, tokens, or personal information.

### Medium — GitHub Actions supply-chain hardening
Workflow actions are pinned to full commit SHAs with version comments. Build permissions are read-only; only the version-tag release job receives contents write permission. The workflow does not overwrite existing release tags. Keep pins updated through reviewed dependency updates and protect main.

## Changes made during this review

- Release signing no longer falls back to the Android debug key; CI produces a debug-signed installable artifact when production secrets are absent and blocks publishing in that case.
- Home Assistant long-lived tokens now use secure storage; migration writes the secure value before deleting the legacy plaintext preference, and stale legacy copies are removed.
- Home Assistant URLs now require HTTPS except loopback, `.local`, and private/LAN addresses; malformed URLs are handled as connection errors.
- CI no longer commits generated assets or lockfile updates to main. Build and publishing are separated with minimal permissions; publishing runs only for matching version tags, requires private signing secrets, and refuses to overwrite existing releases.
- Gradle 9.3.1 wrapper scripts and JAR are committed; CI verifies and uses them instead of regenerating them.
- Workflow actions are pinned to immutable full SHAs.
- PR workflow remains read-only and runs analysis, tests, worker syntax validation, and an APK build.
- Termux worker browser-fetch now checks URL scheme/credentials, rejects non-public resolved IPs, and revalidates redirects; DNS-rebinding risk remains.

## Before production release

- [ ] Configure protected main branch and required reviews/checks.
- [ ] Add the four protected release-signing secrets and verify the release certificate fingerprint.
- [ ] Authenticate Termux worker requests and validate caller/pairing.
- [ ] Harden browse URL fetches against SSRF and unsafe redirects.
- [ ] Restrict cleartext to loopback or remove it.
- [ ] Re-review permissions against actual features and store policies.
- [x] Pin workflow actions by SHA (currently pinned); audit dependency updates.
- [ ] Run a secret scan and dependency vulnerability scan; review results.
- [ ] Test permissions, microphone lifecycle, notification opt-in, indexing wipe, and accessibility workflows on a real device.
- [ ] Publish checksums and provenance/attestation for release artifacts.

