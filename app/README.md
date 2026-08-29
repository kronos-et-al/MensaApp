# Mensa KA - Flutter App

A modern Flutter application to view and interact with meal plan data from the canteens of
the [Studierendenwerk Karlsruhe](https://www.sw-ka.de/de/hochschulgastronomie/speiseplan/).

## 🚀 Features

- **Daily Meal Plans**: Stay up to date with the latest menus from all KIT canteens.
- **Filtering**: Filter by allergens, food types, and price categories.
- **Personalization**: Save favorites and set your own meal preferences.
- **Ratings & Images**: Rate meals and upload your own food photos.
- **Offline First**: High-performance local caching using ObjectBox.

## 🛠 Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (Target: 3.29.0)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Local Database**: [ObjectBox](https://objectbox.io/) (NoSQL)
- **API**: [GraphQL](https://graphql.org/) (via `graphql_codegen`)
- **Localization**: [flutter_i18n](https://pub.dev/packages/flutter_i18n)

---

## 🏗 Building the App

### 1. Prerequisites

Ensure you have the following installed:

- **Flutter SDK**: `3.29.0` or newer.
- **Java JDK**: `25` (Required for modern Gradle compatibility).
- **Android Gradle Plugin**: `9.3.0` (Configured in the project).

### 2. Environment Setup

Create a `.env` file in the root directory based on `.env.example`:

```bash
cp .env.example .env
```

Fill in your `API_URL` and `API_KEY` accordingly.

### 3. Dependencies & Code Generation

This project relies heavily on code generation for both GraphQL and the ObjectBox database.

```bash
# Get dependencies
flutter pub get

# Generate code (GraphQL wrappers and ObjectBox models)
dart run build_runner build

### 4. Running the App

**Debug Mode:**
```bash
flutter run
```

**Release Build (Android APK):**

```bash
flutter build apk --release
```

*Note: To target specific architectures (e.g., arm64), use `--target-platform android-arm64`.*

---

## 🧪 Testing

The project includes unit tests and integrity tests.

```bash
# Run all tests
flutter test
```

To run integration tests on a connected device:

```bash
flutter test test/integrity_test/allTests.dart
```

---

## 📝 Changelog Management

When updating the app version, please add a new entry to the changelog to inform users of the
changes.

1. Increment the `version` in `pubspec.yaml`.
2. Add the release notes to `assets/locales/de/update.json` and `assets/locales/en/update.json`
   under the `changes` key. **Use underscores instead of dots for the version key** (e.g., `"1_4_0"`
   instead of `"1.4.0"`).
3. Use a sequential list starting from `"0"`.

Example:

```json
"1_4_0": {
"0": "New feature description",
"1": "Bug fix description"
}
```

---

## 📂 Project Structure

- `lib/model/database/`: ObjectBox entities and database access logic.
- `lib/model/api_server/`: GraphQL queries and server interaction.
- `lib/view/`: UI components and screens.
- `lib/view_model/`: Business logic and state management.
- `assets/icons/`: SVG icons and branding assets.
- `assets/locales/`: Translation files for i18n.
