# Security review and publishing checklist

Review date: 2026-11-21  
Scope: public repository configuration, GitHub Actions workflows, Flutter/native Android permissions, Termux worker routes, and selected storage/notification/automation code. This is a source review, not a penetration test, device test, or exhaustive secret scan.

## Findings

### High — CI APK uses debug signing
The release workflow currently signs the release APK with Android's debug key. This is acceptable only for test builds. Do not distribute it as a production/Play Store build. Before production publishing, create a private upload/release key, store it only in protected GitHub Actions secrets, and verify the signing certificate and rotation/back-up process. Never commit the keystore or passwords.

### High — Termux worker endpoints have no authentication
The worker binds to `127.0.0.1`, which prevents remote network access by default, but localhost is shared by apps on Android. The POST routes can trigger local inference, image/video processing, and browsing. The video-edit endpoint accepts an input path readable by the Termux user. Treat this worker as trusted local software only; do not bind it to `0.0.0.0` or expose it through a tunnel/port-forward. Add a pairing secret or another caller-authentication mechanism before treating it as hardened.

### High — Browser-fetch route requires SSRF hardening
The worker's `/browse` route extracts and fetches search-result URLs. URL scheme validation alone is insufficient because redirects and DNS can point to loopback/private/link-local hosts. The route needs destination validation for each redirect and DNS result before being considered safe. Do not expose the worker to untrusted callers.

### High — Broad Android permission surface
The manifest requests permissions including microphone, camera, contacts, SMS, notification access, accessibility/window content, overlays, all-files access, app visibility, usage stats, and Shizuku integration. These permissions are sensitive and feature-dependent. The app must keep permissions opt-in, explain the data/action involved, minimize collection, and provide disable/clear controls. Publishing through Play Store would require a separate policy and permission eligibility review.

### Medium — Cleartext networking is globally enabled
The manifest sets `android:usesCleartextTraffic="true"` to support local worker HTTP endpoints. This permits cleartext traffic beyond loopback unless additional network-security restrictions are configured. Prefer HTTPS for cloud endpoints and a network security config narrowly permitting local traffic only. Verify all provider endpoints and local URLs before shipping.

### Medium — Notification/screen content can be sensitive
Notification triage and opt-in indexing may process message snippets, screen text, and notification metadata. Keep opt-in explicit, retention bounded, source allowlisted, user-visible, and wipeable. Avoid logging message contents, screenshots, tokens, or personal information.

### Medium — GitHub Actions supply-chain hardening
Workflow actions currently use version tags rather than full commit-SHA pins. Pin third-party actions to reviewed immutable SHAs, use minimal per-job permissions, and enable dependency/security alerts where available. Release publication should only run from the protected main branch.

## Changes made during this review

- Release workflow no longer runs on pull requests.
- Non-main workflow runs no longer push generated assets or lockfile changes to main.
- Release/tag publishing is restricted to the main branch.
- Added a separate PR workflow with read-only `contents: read` permission; it runs analysis, tests, worker syntax validation, and an APK build without uploading or publishing releases.
- Public README and changelog were corrected to describe v3.3.1 as published and to disclose debug signing.

## Before production release

- [ ] Configure protected main branch and required reviews/checks.
- [ ] Replace debug signing with a protected production signing key; verify the APK certificate.
- [ ] Authenticate Termux worker requests and validate caller/pairing.
- [ ] Harden browse URL fetches against SSRF and unsafe redirects.
- [ ] Restrict cleartext to loopback or remove it.
- [ ] Re-review permissions against actual features and store policies.
- [ ] Pin workflow actions by SHA; audit dependency updates.
- [ ] Run a secret scan and dependency vulnerability scan; review results.
- [ ] Test permissions, microphone lifecycle, notification opt-in, indexing wipe, and accessibility workflows on a real device.
- [ ] Publish checksums and provenance/attestation for release artifacts.

