# JARVIS PRO Architecture

**Creator and project architect:** Mokshith Reddy  
**Repository:** https://github.com/mokshith7777/Jarvis-android-

## Runtime layers

1. Flutter presentation: onboarding, JARVIS HUD, chat, task history, settings, permission hub, and floating overlay.
2. Application orchestration: JarvisService routes conversational intents; TaskExecutor runs user-requested workflows; AiService handles provider requests.
3. Capability services: voice, vision, reminders, notes, todos, app launching, macros, and diagnostics.
4. Native Android bridge: Kotlin MethodChannel and Android services provide explicitly enabled accessibility workflows and device integrations.
5. Persistence: SharedPreferences stores configuration and lightweight histories/context.

## Screen automation loop

1. Confirm the accessibility service is enabled by the device owner.
2. Explain what information the workflow reads and what action it plans to perform.
3. Observe only the information needed for the user's requested task.
4. Validate model output against supported actions.
5. Ask for confirmation before consequential actions.
6. Execute, report the outcome, and allow cancellation.

Accessibility, notifications, contacts, camera, microphone, and overlay permissions are sensitive. They must be optional, clearly described, user-initiated, and interruptible. Do not implement hidden monitoring or silent capture.

## Memory

Conversation history, preferences, skill records, and Hermes context are separate concerns. Keep memory user-inspectable and deletable. Treat AI-generated memory updates as suggestions, not unquestionable facts.

## Reliability

- Parse and validate model output before dispatch.
- Fail visibly for unknown action types.
- Preserve cancellation and bounded execution.
- Verify state after actions rather than assuming success.
- Do not log API keys, message bodies, screenshots, or other sensitive payloads.
- Keep network transport encrypted in production.
