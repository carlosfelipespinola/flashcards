package dev.carlosfelipe.flashcards

import android.app.Activity
import android.content.ContentUris
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.database.Cursor
import android.net.Uri
import android.os.BatteryManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.os.Environment
import android.provider.DocumentsContract
import android.provider.MediaStore
import androidx.annotation.NonNull
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.BufferedWriter
import java.io.IOException
import java.io.InputStreamReader
import java.io.OutputStreamWriter
import java.util.Objects


class MainActivity: FlutterActivity() {
    private val CHANNEL = "carlosfelipe.dev/flashcards"

    private val BACKUP_DATA_CODE = 1
    private lateinit var _pickFolderResult: MethodChannel.Result
    private var _linesOfFileToBackup: ArrayList<String>? = null

    private val RESTORE_DATA_CODE = 2
    private lateinit var _restoreResult: MethodChannel.Result
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->

            when (call.method) {
                "backupData" -> {
                    _linesOfFileToBackup = call.argument<ArrayList<String>>("fileLines")
                    startBackupDataActivity(result);
                }
                "restoreData" -> {
                    startRestoreActivity(result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        when (requestCode) {
            BACKUP_DATA_CODE -> {
                onDataBackupActivityResult(resultCode, data)
            }
            RESTORE_DATA_CODE -> {
                onDataRestoreActivityResult(resultCode, data)
            }
            else -> {

            }
        }
    }

    private fun startRestoreActivity(result: MethodChannel.Result) {
        _restoreResult = result

        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "*/*"
        }

        startActivityForResult(intent, RESTORE_DATA_CODE)
    }

    private fun onDataRestoreActivityResult(resultCode: Int, data: Intent?) {
        if(resultCode !== Activity.RESULT_OK) {
            return _restoreResult.error("error", "error", null)
        }

        try {
            data!!.data!!.also {
                val lines = readFileLines(it);
                _restoreResult.success(lines)
            }
        }
        catch (e: NullPointerException) {
            e.printStackTrace()
            return _restoreResult.error("error", "error", null)
        }
        catch (e: IOException) {
            e.printStackTrace()
            return _restoreResult.error("error", "error", null)
        }
    }

    private fun readFileLines(uri: Uri): ArrayList<String> {
        val lines: ArrayList<String>

        return activity.contentResolver.openInputStream(uri).use { inputStream ->
            BufferedReader(InputStreamReader(Objects.requireNonNull(inputStream))).use { reader ->
                lines = ArrayList(reader.readLines())
                reader.close()
                return lines
            }
        }
    }

    private fun startBackupDataActivity(result: MethodChannel.Result) {
        _pickFolderResult = result

        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            type = "text/plain"
            putExtra(Intent.EXTRA_TITLE, "backup.jsonl.txt")
        }

        startActivityForResult(intent, BACKUP_DATA_CODE)
    }

    private fun onDataBackupActivityResult(resultCode: Int, data: Intent?) {
        if(resultCode !== Activity.RESULT_OK) {
            return _pickFolderResult.error("error", "error", null)
        }
        try {
            val uri = data!!.data!!

            writeLinesToFile(uri, _linesOfFileToBackup!!)

            _pickFolderResult.success("SUCCESS")
        }
        catch (e: NullPointerException) {
            e.printStackTrace()
            _pickFolderResult.error("error", "error", null)
        }
        catch (e: IOException) {
            e.printStackTrace()
            _pickFolderResult.error("error", "error", null)
        }
    }

    private fun writeLinesToFile(uri: Uri, lines: ArrayList<String>) {
        activity.contentResolver.openOutputStream(uri, "w").use { outputStream ->
            BufferedWriter(OutputStreamWriter(Objects.requireNonNull(outputStream))).use { writer ->
                for (line in lines) {
                    writer.write(line)
                    writer.newLine()
                }
                writer.close()
            }
        }
    }
}
