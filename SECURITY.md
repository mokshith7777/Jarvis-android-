# JARVIS PRO security report

**Review date:** 2026-11-21  
**Review type:** Repository/source/configuration review. Not a penetration test, independent audit, device test, or security certification.

## Executive status

This repository is public. Anyone can read, fork, copy, modify, and reproduce its source. A public repository cannot prevent replication. If exclusivity is required, the repository and source distribution must be private; a public release APK may still be reverse-engineered. This repository has not been made private by this review.

No security review can promise “zero security errors.” This report records known risks and the changes made; unresolved risks remain.

## Review scope and checks

Reviewed the recent security/CI commits, README, workflow configuration, Android manifest/build signing configuration, Home Assistant settings and URL validation, Termux worker, and selected configuration files.

A limited pattern scan was performed on 15 high-risk text/config files in the current main-branch snapshot for common private-key, GitHub token, Google API key, Telegram token, AWS key, and credentialed-URL patterns. **No matches were found in those files.** This is not a full repository scan, does not scan every tracked file, does not scan all commit history, and cannot detect every credential format.

## Findings and status

### High: Release signing and release provenance
**Status:** Mitigated in CI configuration, but production setup remains pending.

- Release builds do not fall back to the Android debug signing key.
- CI can build a debug-signed testing APK when the private release key is not configured; that artifact must not be treated as production.
- Publishing is tag-based, requires signing secrets, checks the tag against the app version, and refuses to overwrite an existing release.
- Existing public v3.3.1 APK is debug-signed and for testing only.
- Configure private signing material only in protected repository secrets; never commit keystore files or passwords.

### High: Termux worker caller authentication
**Status:** Open.

The worker is designed to bind to loopback, but Android localhost is not a security boundary between apps. Endpoints can trigger local operations. Do not expose it on all interfaces, through tunnels, or to untrusted callers. Pairing/authentication and request validation are still needed.

### High: Browser-fetch SSRF/DNS rebinding
**Status:** Partially mitigated, open.

The browser-fetch code checks schemes/credentials and rejects non-public resolved addresses, and redirects are rechecked. DNS resolution and the eventual connection are not pinned to the same address, so rebinding remains possible. Do not expose the worker to untrusted callers.

### High: Sensitive Android permissions
**Status:** Open for product/policy review.

The app requests sensitive permissions for optional features, including microphone, camera, contacts, SMS, notifications, accessibility, overlays, storage, app visibility, usage access, and Shizuku. Keep them opt-in, explain data/actions, minimize access, and test revocation. Play Store eligibility requires a separate policy review.

### Medium: Cleartext networking
**Status:** Open.

The manifest globally enables cleartext networking to support local worker use. This can permit HTTP outside localhost. Prefer HTTPS for remote endpoints and a narrow Android network-security configuration for any necessary local exceptions.

### Medium: Local and cloud data handling
**Status:** Open review item.

Screen/notification indexing, connectors, and configured AI providers may handle sensitive data. Avoid sending private data to providers without reviewing their terms. Do not log secrets, messages, screenshots, or personal data. Review retention, deletion, and opt-in behavior on-device.

### Medium: CI and supply chain
**Status:** Improved, continue maintenance.

Workflow actions are pinned to immutable SHAs and jobs use limited permissions. The build/test workflow is not a substitute for dependency review, signed provenance, or protected branch rules. Branch protection and required checks are not verified/enabled by this report.

### Medium: Home Assistant token storage and URL validation
**Status:** Mitigations implemented; device migration/test verification still required.

The token uses secure storage with migration from the legacy SharedPreferences value. URL validation permits HTTPS for remote hosts and HTTP only for loopback/private/local names, rejecting embedded credentials, query, and fragment. Test migration on a device before relying on it; local-name resolution is not an IP-pinning defense.

## Repository hygiene

- Local environment files, signing keystores, credential directories, and key properties are now ignored by Git.
- The Gradle wrapper JAR is intentionally tracked so builds use the committed wrapper.
- Do not commit API keys, tokens, signing keys, user data, logs, screenshots, backups, or local databases.
- If a secret was ever committed, deleting the file is insufficient: revoke/rotate the secret immediately, then remove it from Git history if appropriate. History rewriting does not replace revocation.

## Before any production release

- [ ] Configure and protect private release-signing secrets; verify certificate fingerprint.
- [ ] Add worker authentication/pairing and tighten endpoint access.
- [ ] Complete SSRF/DNS rebinding defenses.
- [ ] Restrict cleartext networking.
- [ ] Review each permission and store-policy eligibility.
- [ ] Run a full secret scan over all tracked files and Git history.
- [ ] Run dependency vulnerability checks.
- [ ] Test privacy/permission behavior on real devices.
- [ ] Protect main and require CI checks.
- [ ] Publish reproducible build/checksum/provenance.

## Responsible reporting

Please avoid posting credentials or personal data in public issues. Report security concerns privately to the repository owner using GitHub's private vulnerability reporting if enabled, or another private channel.
