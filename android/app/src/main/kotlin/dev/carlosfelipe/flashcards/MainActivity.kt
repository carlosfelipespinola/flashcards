package dev.carlosfelipe.flashcards
import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.BufferedWriter
import java.io.FileNotFoundException
import java.io.IOException
import java.io.InputStreamReader
import java.io.OutputStreamWriter
import java.util.Objects



object BackupRestoreErrorCodes {
    const val UNKNOWN_ERROR_CODE = "unknown-error"
    const val FILE_NOT_FOUND_ERROR_CODE = "file-not-found-error"
    const val UNSUPPORTED_FILE_ERROR_CODE = "unsupported-file-error"
    const val USER_CANCELED_ACTION_ERROR_CODE = "user-canceled-action-error"
    const val IO_ERROR_CODE = "io-error"
}

object EventChannelEventsCodes {
    const val INTENT_WITH_IMPORTABLE_DATA = "intent-with-importable-data"
}

object ActivityResultsCodes {
    const val BACKUP_DATA_CODE = 1
    const val RESTORE_DATA_CODE = 2
}

const val CHANNEL = "carlosfelipe.dev/flashcards"
const val EVENT_CHANNEL = "carlosfelipe.dev/flashcards/events"

class UnsupportedFileException : Exception {
    constructor() : super()
    constructor(message: String) : super(message)
    constructor(message: String, cause: Throwable) : super(message, cause)
    constructor(cause: Throwable) : super(cause)
}

class MainActivity: FlutterActivity(), EventChannel.StreamHandler {

    private var sharedUri: Uri? = null
    private var eventSink: EventChannel.EventSink? = null

    private lateinit var _backupDataResult: MethodChannel.Result
    private var _linesOfFileToBackup: ArrayList<String>? = null

    private lateinit var _restoreResult: MethodChannel.Result

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }
    private fun handleIntent(intent: Intent) {
        if (hasContentToHandle(intent)) {
           sharedUri = getContentUriFromIntent(intent)
        }

        if (sharedUri != null && eventSink != null) {
            eventSink!!.success(EventChannelEventsCodes.INTENT_WITH_IMPORTABLE_DATA)
        }
    }

    private fun hasContentToHandle(intent: Intent): Boolean {
        if ((Intent.ACTION_SEND == intent.action || Intent.ACTION_VIEW == intent.action) && intent.type != null) {
            if ("application/octet-stream" == intent.type) {
                return true
            }
        }
        return false
    }

    private fun getContentUriFromIntent(intent: Intent): Uri? {
        var uri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java)
        } else {
            intent.getParcelableExtra(Intent.EXTRA_STREAM)
        }

        if (uri == null) {
            uri = intent.data
        }

        return uri
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->

            when (call.method) {
                "backupData" -> {
                    _linesOfFileToBackup = call.argument<ArrayList<String>>("fileLines")
                    startBackupDataActivity(result)
                }
                "restoreData" -> startRestoreActivity(result)
                "hasSharedContent" -> hasSharedContent(result)
                "discardSharedContent" -> discardSharedContent(result)
                "restoreSharedContent" -> restoreSharedContent(result)
                else -> result.notImplemented()
            }
        }
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(this)
    }

    override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) { eventSink = sink }

    override fun onCancel(arguments: Any?) { eventSink = null }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun hasSharedContent(result: MethodChannel.Result) {
        result.success(sharedUri != null)
    }

    private fun discardSharedContent(result: MethodChannel.Result) {
        sharedUri = null
        result.success(true)
    }
    private fun restoreSharedContent(result: MethodChannel.Result) {
        if (sharedUri != null) {
            try {
                val lines = readFileLines(sharedUri!!)
                sharedUri = null
                result.success(lines)
            }
            catch (e: UnsupportedFileException) {
                result.error(BackupRestoreErrorCodes.UNSUPPORTED_FILE_ERROR_CODE, null, null)
            }
            catch (e: FileNotFoundException) {
                result.error(BackupRestoreErrorCodes.FILE_NOT_FOUND_ERROR_CODE, null, e.stackTrace)
            }
            catch (e: IOException) {
                e.printStackTrace()
                result.error(BackupRestoreErrorCodes.IO_ERROR_CODE, null, e.stackTrace)
            }

        } else {
            result.error("shared-content-unavailable-error", null, null)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        when (requestCode) {
            ActivityResultsCodes.BACKUP_DATA_CODE -> {
                onDataBackupActivityResult(resultCode, data)
            }
            ActivityResultsCodes.RESTORE_DATA_CODE -> {
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
            type = "application/octet-stream"
        }

        startActivityForResult(intent, ActivityResultsCodes.RESTORE_DATA_CODE)
    }

    private fun onDataRestoreActivityResult(resultCode: Int, data: Intent?) {
        if(resultCode != Activity.RESULT_OK) {
            return _restoreResult.error(BackupRestoreErrorCodes.USER_CANCELED_ACTION_ERROR_CODE, null, null)
        }

        try {
            data!!.data!!.also {
                val lines = readFileLines(it)
                _restoreResult.success(lines)
            }
        }
        catch (e: UnsupportedFileException) {
            return _restoreResult.error(BackupRestoreErrorCodes.UNSUPPORTED_FILE_ERROR_CODE, null, null)
        }
        catch (e: NullPointerException) {
            e.printStackTrace()
            return _restoreResult.error(BackupRestoreErrorCodes.UNKNOWN_ERROR_CODE, null, e.stackTrace)
        }
        catch (e: FileNotFoundException) {
            _restoreResult.error(BackupRestoreErrorCodes.FILE_NOT_FOUND_ERROR_CODE, null, e.stackTrace)
        }
        catch (e: IOException) {
            e.printStackTrace()
            return _restoreResult.error(BackupRestoreErrorCodes.IO_ERROR_CODE, null, e.stackTrace)
        }
    }

    private fun readFileLines(uri: Uri): ArrayList<String> {
        val lines: ArrayList<String> = ArrayList()

        activity.contentResolver.openInputStream(uri).use { inputStream ->
            BufferedReader(InputStreamReader(Objects.requireNonNull(inputStream), Charsets.UTF_8)).use { reader ->
                val firstLine = reader.readLine() ?: return lines

                if (firstLine.startsWith("{") && firstLine.endsWith("}")) {
                    lines.add(firstLine)
                    lines.addAll(reader.readLines())
                } else {
//                    Log.wtf("wtf", "will throw unsupported error")
                    throw UnsupportedFileException("file must be json lines");
                }

                reader.close()
                return lines
            }
        }
    }

    private fun startBackupDataActivity(result: MethodChannel.Result) {
        _backupDataResult = result

        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            type = "application/octet-stream"
            putExtra(Intent.EXTRA_TITLE, "backup")
        }

        startActivityForResult(intent, ActivityResultsCodes.BACKUP_DATA_CODE)
    }

    private fun onDataBackupActivityResult(resultCode: Int, data: Intent?) {
        if(resultCode != Activity.RESULT_OK) {
            return _backupDataResult.error(BackupRestoreErrorCodes.USER_CANCELED_ACTION_ERROR_CODE, null, null)
        }
        try {
            val uri = data!!.data!!

            writeLinesToFile(uri, _linesOfFileToBackup!!)

            _backupDataResult.success("SUCCESS")
        }
        catch (e: NullPointerException) {
            e.printStackTrace()
            _backupDataResult.error(BackupRestoreErrorCodes.UNKNOWN_ERROR_CODE, null, e.stackTrace)
        }
        catch (e: FileNotFoundException) {
            _backupDataResult.error(BackupRestoreErrorCodes.FILE_NOT_FOUND_ERROR_CODE, null, e.stackTrace)
        }
        catch (e: IOException) {
            e.printStackTrace()
            _backupDataResult.error(BackupRestoreErrorCodes.IO_ERROR_CODE, null, null)
        }
    }

    private fun writeLinesToFile(uri: Uri, lines: ArrayList<String>) {
        activity.contentResolver.openOutputStream(uri, "wt").use { outputStream ->
            BufferedWriter(OutputStreamWriter(Objects.requireNonNull(outputStream), Charsets.UTF_8)).use { writer ->

                for (line in lines) {
                    writer.write(line)
                    writer.newLine()
                }
                writer.close()
            }
        }
    }
}
