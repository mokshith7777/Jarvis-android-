# Changelog

All notable project changes are recorded here.

## Unreleased

### Added
- Project-specific architecture and build documentation.
- GitHub Actions workflow for Flutter analysis, tests, and release APK artifact generation.
- GitHub Actions integration workflow that preserves the upstream Git history.
- Deterministic unit tests for reminder-time parsing.

### Changed
- Android launcher and accessibility service labels now use JARVIS Android branding.
- Permission descriptions now state the real constraints around accessibility, microphone, and background execution.
- Brain Dump to-do tasks preserve the requested priority.

### Fixed
- Brain Dump reminders now honor supported 12-hour and 24-hour time values.
- Reminder times already passed today are scheduled for the next day.
- Invalid reminder time values are reported instead of silently using the default time.
- Unknown Brain Dump task and device-action types are reported as failures rather than successful completions.

### Attribution
- The base Android assistant implementation and its upstream history are from Abuzar Ansarii's MIT-licensed J.A.R.V.I.S. project: https://github.com/AbuZar-Ansarii/Jarvis.
- Original MIT notices are retained in LICENSE.