# Instructions for AI Agents

## General

Make sure, you have done the following:

- Your code is documented using doc comments.
- You added unit tests to all your implemented functions.
- You did not put raw strings in the app UI but used localizations.
- You ran the CI checks (`flutter analyze`, `flutter test`, and `dart format`) and they all pass.
- Ask the developer before making a change that affects the app's functionality unless explicitly
  prompted.
- Automatically update `AGENTS.md` when the developer provides generic guidelines, preferences, or
  workflow instructions.
- consider the instructions for writing text

## Writing text

Don't write any user-facing text (localizations) that is longer than a few words (i.e. sentences) by
yourself!!!
Always prompt the developer to formulate a message for some given information. This makes the app
feel more personal and ensures we hit the right tone!

## Changelog Management

When creating a new version of the Mensa KA app, you MUST update the changelog to inform users about
the latest improvements.

### 1. Update Version

Increment the version in `pubspec.yaml`.

### 2. Add Translation Entries

Update the following files:

- `assets/locales/de/update.json`
- `assets/locales/en/update.json`

Add a new key under `changes` for the current version. Use UNDERSCORES instead of dots (e.g., "
1_4_0" for version 1.4.0) to prevent issues with i18n key splitting.
Inside that version key, provide a numbered list of changes (0, 1, 2, ...).

### 3. Technical Note

The app fetches these entries using `update.changes.<version>.<index>` in
`NewVersionDialog.getChanges`. Ensure the indices are sequential starting from 0.
