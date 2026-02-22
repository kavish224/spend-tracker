# Keep Flutter and plugin entry points.
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Kotlin metadata and annotations.
-keep class kotlin.Metadata { *; }
-keepattributes *Annotation*

# Keep sqflite classes used via reflection.
-keep class com.tekartik.sqflite.** { *; }
