# Architecture

## Runtime layers

1. **Flutter presentation** — onboarding, JARVIS HUD, chat, task history, settings, permission hub, and floating overlay.
2. **Application orchestration** — JarvisService routes conversational intents; TaskExecutor runs screen-aware automation; AiService handles provider requests.
3. **Capability services** — voice, vision, reminders, notes, todos, app launching, smart-home adapters, Telegram, macros, and diagnostics.
4. **Native Android bridge** — Kotlin MethodChannel and Android services provide accessibility-tree observation, supported gestures, notifications, overlays, and device integrations.
5. **Persistence** — SharedPreferences stores configuration and lightweight histories/context. Services own their storage keys and serialization.

## Screen automation loop

1. Confirm the Android accessibility service is enabled.
2. Observe the current accessibility hierarchy.
3. Send the user's goal, recent execution context, and compact screen description to the configured AI provider.
4. Parse one structured action.
5. Validate that the action is supported and execute it through the native bridge.
6. Observe the updated screen and repeat until completion, cancellation, or the configured step limit.

Automation should remain visible and interruptible. Accessibility access is powerful: explain the exact purpose before enabling it, keep user confirmation for consequential operations, and never treat an AI-generated action as trusted input.

## Voice and overlay

The voice service coordinates speech recognition and text-to-speech. Background listening is subject to Android foreground-service rules, microphone restrictions, battery policy, and device-vendor behavior. The floating assistant runs as an Android overlay and communicates with the main Flutter engine through the overlay plugin.

## Memory

Conversation history, preferences, skill records, and Hermes context are separate concerns. Keep memory user-inspectable and deletable. Treat AI-generated memory updates as suggestions, not unquestionable facts.

## Reliability rules

- Parse and validate model output before dispatch.
- Fail visibly for unknown action types.
- Preserve cancellation and bounded execution.
- Verify state after actions rather than assuming success.
- Do not log API keys, message bodies, screenshots, or other sensitive payloads.
- Keep network transport encrypted in production; local development endpoints require an explicit, documented exception.

## Known platform constraints

- Accessibility behavior varies by Android version and target application.
- Some apps expose incomplete or intentionally obscured accessibility trees.
- Overlay and microphone foreground services require user-visible permission and notification handling.
- Proximity sensors, camera capabilities, notification access, and background execution vary by device.
- The current codebase needs device-matrix testing before these capabilities can be treated as production guarantees.