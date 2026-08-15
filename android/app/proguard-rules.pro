# sqflite accesses its plugin classes via reflection from platform channel
# calls; keep them so R8 doesn't strip anything it can't see is used.
-keep class com.tekartik.sqflite.** { *; }
