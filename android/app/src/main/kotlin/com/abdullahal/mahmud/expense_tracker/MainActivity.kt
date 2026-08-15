package com.abdullahal.mahmud.expense_tracker

import android.content.ContentValues
import android.os.Build
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

private const val CHANNEL_NAME = "expense_tracker/csv_export"

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
            .setMethodCallHandler { call, result ->
                if (call.method != "saveCsvToDownloads") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val fileName = call.argument<String>("fileName")
                val content = call.argument<String>("content")
                if (fileName == null || content == null) {
                    result.error("invalid_args", "fileName and content are required", null)
                    return@setMethodCallHandler
                }
                try {
                    saveCsvToDownloads(fileName, content)
                    result.success(null)
                } catch (e: Exception) {
                    result.error("save_failed", e.message, null)
                }
            }
    }

    private fun saveCsvToDownloads(fileName: String, content: String) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            throw Exception("Exporting requires Android 10 or newer")
        }
        val values = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
            put(MediaStore.MediaColumns.MIME_TYPE, "text/csv")
            put(MediaStore.MediaColumns.RELATIVE_PATH, "Download/")
        }
        val resolver = applicationContext.contentResolver
        val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
            ?: throw Exception("Could not create file in Downloads")
        val stream = resolver.openOutputStream(uri)
            ?: throw Exception("Could not open output stream")
        stream.use { it.write(content.toByteArray(Charsets.UTF_8)) }
    }
}
