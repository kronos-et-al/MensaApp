# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# ObjectBox
-keep class io.objectbox.** { *; }
-dontwarn io.objectbox.**
-keep class io.objectbox.relation.ToOne { *; }
-keep class io.objectbox.relation.ToMany { *; }

# If you have custom Java/Kotlin code in your app
-keep class de.mensa_ka.app.** { *; }

# Flutter Play Store Split compatibility (ignore if not using deferred components)
-dontwarn com.google.android.play.core.**
