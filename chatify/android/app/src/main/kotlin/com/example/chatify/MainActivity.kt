package com.example.chatify

import android.os.Bundle
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import androidx.annotation.NonNull

import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Environment
import android.os.Build
import android.provider.MediaStore
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.IOException
import android.text.TextUtils
import android.webkit.MimeTypeMap
import java.io.OutputStream
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES



import android.database.Cursor;
import android.provider.OpenableColumns;
import android.provider.DocumentsContract;
import android.content.ContentUris;




class MainActivity: FlutterActivity(){
    // private lateinit var methodChannel: MethodChannel
    private var CHANNEL = "com.example.Chatify/FileSaver"
    private var appContext: Context? = null
     override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(FlutterEngine(this))
        appContext = applicationContext
    }
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
   MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "saveFileToGallery"){
                val path = call.argument<String?>("file")
                    val name = call.argument<String?>("name")
                    val subDir = call.argument<String?>("subDir")
                    result.success( saveFileToGallery(path, name,subDir))
            }
            
        }
  }


    private fun generateUri(extension: String = "", name: String? = null,subDir: String = ""): Uri? {
        var fileName = name ?: System.currentTimeMillis().toString()
        val mimeType = getMIMEType(extension)
        var mediaStoreContentUri: Any? = null
        var mediaStoreMimeType: Any? = null
        var enviromentDirectory: Any? = null
        println("MIME TYPE $mimeType")
        when{
        mimeType?.startsWith("video") ==true -> {
            println("VIDEO FILE")
            mediaStoreContentUri = MediaStore.Video.Media.EXTERNAL_CONTENT_URI
            mediaStoreMimeType = MediaStore.Video.Media.MIME_TYPE
            enviromentDirectory = Environment.DIRECTORY_MOVIES+"/VirtueNetzVideos"
        }
        mimeType?.startsWith("image") ==true -> {
            println("IMAGE FILE")
            mediaStoreContentUri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI
            mediaStoreMimeType = MediaStore.Images.Media.MIME_TYPE
            enviromentDirectory = Environment.DIRECTORY_PICTURES +"/VirtueNetzImages"

        }
        mimeType?.startsWith("audio") ==true -> {
            println("Audio FILE")
            mediaStoreContentUri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
            mediaStoreMimeType = MediaStore.Audio.Media.MIME_TYPE
            enviromentDirectory = Environment.DIRECTORY_MUSIC +"/VirtueNetzAudio"

        }
        mimeType?.startsWith("application") ==true || mimeType?.startsWith("text") ==true -> {
            println("DOCUMENT FILE")
            mediaStoreContentUri = MediaStore.Files.getContentUri("external")
            mediaStoreMimeType = MediaStore.MediaColumns.MIME_TYPE
            enviromentDirectory = Environment.DIRECTORY_DOCUMENTS +"/VirtueNetzDocuemnts"
        }
      
        else -> {
            println("OTHER FILE IN DOCUMENT DIRECTORY")
            mediaStoreContentUri = MediaStore.Files.getContentUri("external")
            mediaStoreMimeType = MediaStore.MediaColumns.MIME_TYPE
            enviromentDirectory = Environment.DIRECTORY_DOCUMENTS +"/VirtueNetzDocuemnts" 
        }
    }

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // >= android 10
            

            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, if (extension.isNotEmpty()) "$fileName.$extension" else fileName)
                put(
                    MediaStore.MediaColumns.RELATIVE_PATH,enviromentDirectory+ subDir)
                if (!TextUtils.isEmpty(mimeType)) {
                    put(mediaStoreMimeType, mimeType)
                }
            }

            appContext?.contentResolver?.insert(mediaStoreContentUri, values)

        } else {
            // < android 10
            val storePath =
                Environment.getExternalStoragePublicDirectory(
                enviromentDirectory).absolutePath
            println("STORE PATH $storePath")
           
            File(storePath).apply {
                println("APP DIR $this")
                if (!exists()) {
                    println("Dir not exists")
                    mkdir()
                    
                }
            }
            var appDir= File(storePath,subDir).apply {
                println("APP DIR $this")
                if (!exists()) {
                    println("Dir not exists")
                    mkdir()
                    
                }
            }
            
           

            val file =
                File(appDir, if (extension.isNotEmpty()) "$fileName.$extension" else fileName)
            Uri.fromFile(file)
        }
    }

    /**
     * get file Mime Type
     *
     * @param extension extension
     * @return file Mime Type
     */
    private fun getMIMEType(extension: String): String? {
        return if (!TextUtils.isEmpty(extension)) {
            MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension.lowercase())
        } else {
            null
        }
    }

    /**
     * Send storage success notification
     *
     * @param context context
     * @param fileUri file path
     */
    private fun sendBroadcast(context: Context, fileUri: Uri?) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            val mediaScanIntent = Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE)
            mediaScanIntent.data = fileUri
            context.sendBroadcast(mediaScanIntent)
        }
    }
fun getRealPathFromURI(context: Context, uri: Uri): String? {
    if ("content" == uri.scheme) {
        return getDataColumn(context, uri, null, null)
    }
    return null
}

private fun getDataColumn(context: Context, uri: Uri, selection: String?, selectionArgs: Array<String>?): String? {
    val column = "_data"
    val projection = arrayOf(column)
    var cursor: Cursor? = null

    try {
        cursor = context.contentResolver.query(uri, projection, selection, selectionArgs, null)
        cursor?.let {
            if (it.moveToFirst()) {
                val columnIndex = it.getColumnIndexOrThrow(column)
                return it.getString(columnIndex)
            }
        }
    } finally {
        cursor?.close()
    }
    return null
}


    private fun saveFileToGallery(filePath: String?, name: String?,subDir: String?): HashMap<String, Any?> {
        // check parameters
        if (filePath == null) {
            return SaveResultModel(false, null, "parameters error").toHashMap()
        }
        val context = appContext ?: return SaveResultModel(
            false,
            null,
            "appContext null"
        ).toHashMap()
        var fileUri: Uri? = null
        var outputStream: OutputStream? = null
        var fileInputStream: FileInputStream? = null
        var success = false
        
        try {
            val originalFile = File(filePath)
            if(!originalFile.exists()) return SaveResultModel(false, null, "$filePath does not exist").toHashMap()
            fileUri = generateUri(originalFile.extension, name,subDir?:"")
            println("FILE URI $fileUri")
            if (fileUri != null) {
                
                outputStream = context.contentResolver?.openOutputStream(fileUri)
                
                if (outputStream != null) {
                
                    fileInputStream = FileInputStream(originalFile)
                
                    val buffer = ByteArray(10240)
                
                    var count = 0
                    while (fileInputStream.read(buffer).also { count = it } > 0) {
                        outputStream.write(buffer, 0, count)
                    }
                
                    outputStream.flush()
                
                    success = true
                }
            }
            println("Success $success")
        } catch (e: IOException) {
            return SaveResultModel(false, null, e.toString()).toHashMap()

        } finally {
            outputStream?.close()
            fileInputStream?.close()
        }
        return if (success) {
            sendBroadcast(context, fileUri)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                SaveResultModel(fileUri.toString().isNotEmpty(),getRealPathFromURI(context, fileUri!!), null).toHashMap()
            }else{
                SaveResultModel(fileUri.toString().isNotEmpty(),fileUri?.toString(), null).toHashMap()
            }
            
        } else {
            SaveResultModel(false, null, "saveFileToGallery fail").toHashMap()
        }
    }
}

class SaveResultModel(var isSuccess: Boolean,
                      var filePath: String? = null,
                      var errorMessage: String? = null) {
    fun toHashMap(): HashMap<String, Any?> {
        val hashMap = HashMap<String, Any?>()
        hashMap["isSuccess"] = isSuccess
        hashMap["filePath"] = filePath
        hashMap["errorMessage"] = errorMessage
        return hashMap
    }
}