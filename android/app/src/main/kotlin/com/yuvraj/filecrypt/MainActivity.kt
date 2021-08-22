package com.yuvraj.filecrypt

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import android.content.Intent
import android.net.Uri
import androidx.documentfile.provider.DocumentFile
import android.content.ContextWrapper
import java.io.File
import android.content.ClipData
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    private val CHANNEL = "flutter.native/helper"
    lateinit var folder_uri:Uri
    lateinit var channel:MethodChannel

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {

        GeneratedPluginRegistrant.registerWith(flutterEngine);
        val channel1 = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel=channel1;

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when {
                call.method.equals("requestWritePermission") -> {
                    val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
                    startActivityForResult(intent, 0);
                }
                call.method.equals("requestReadPermission") -> {
                    val filePickerIntent = Intent(Intent.ACTION_OPEN_DOCUMENT)
                    filePickerIntent.setType("*/*")
                    filePickerIntent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true)
                    startActivityForResult(filePickerIntent, 1)
                }
                call.method.equals("moveFilesOut") -> {
                    move_files()
                }
            }
        }
    }

    fun move_files()
    {
        val context2 = ContextWrapper(this)
        var source = DocumentFile.fromFile(File(context2.getFilesDir().getPath()))
        source = source.findFile("uri_to_file")!!
        var documentFilesList=source.listFiles()
        var destinationDir=DocumentFile.fromTreeUri(context2,folder_uri)
        var a=0
        while(a<documentFilesList.size)
        {
            var destinationFile= destinationDir?.createFile("",documentFilesList[a].name.toString())
            var ins = context2.getContentResolver().openInputStream(documentFilesList[a].uri)
            var outs = context2.contentResolver.openOutputStream(destinationFile!!.uri)

            val buffer = ByteArray(5472)
            var read: Int
            while  (true) {
                read= ins!!.read(buffer)
                if(read==-1)
                {   break}
                outs?.write(buffer, 0, read)
            }
            ins.close()
            outs!!.flush()
            outs.close()
            a++
        }
        channel.invokeMethod("move_file_out_postprocesing", "")
    }

    override fun onActivityResult(request: Int, result: Int, data: Intent?)
    {
        if(request==0) {
            var uri: Uri? = data?.data;
            if (uri != null) {
                folder_uri = uri;
                channel.invokeMethod("writePermissionStatus", "ok")
            }
            else
            {   channel.invokeMethod("writePermissionStatus", "cancel")}
        }
        else if(request==1)//file picked
        {
            var encodedPath:String="";
            if(data!=null)
            {
                val clipData: ClipData? = data.getClipData()
                if(clipData==null)
                {
                    var uri: Uri? = data?.data;
                    if(uri!=null)
                    {   channel.invokeMethod("readPermissionStatus",uri.toString()+"*")}
                    else
                    {   channel.invokeMethod("readPermissionStatus","")}
                }
                else
                {
                    for (i in 0 until clipData!!.getItemCount()) {
                        val path: ClipData.Item = clipData.getItemAt(i)
                        encodedPath+=(path.uri.toString()+"*")
                    }
                    channel.invokeMethod("readPermissionStatus", encodedPath)
                }
            }
        }
    }
}
