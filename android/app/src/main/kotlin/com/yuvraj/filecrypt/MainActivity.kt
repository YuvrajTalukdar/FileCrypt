package com.yuvraj.filecrypt

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import android.content.Intent
import android.net.Uri
import androidx.documentfile.provider.DocumentFile

class MainActivity: FlutterActivity() {
    private val CHANNEL = "flutter.native/helper"
    lateinit var folder_uri:Uri

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when {
                call.method.equals("changeColor") -> {
                    var color = call.argument<String>("color");
                    println("check from kotlin!!!1= "+color);
                    val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE);
                    startActivityForResult(intent, 0);
                }
            }
        }

        /*private fun changeColor(call: MethodCall, result: MethodChannel.Result) {
        var color = call.argument<String>("color");
        result.success(color);
    }*/
    }
    override fun onActivityResult(request: Int, result: Int, data: Intent?) //for the account selection activity
    {
        println("check_ok");
        var uri: Uri? = data?.data;
        if(uri!=null)
        {   folder_uri=uri;}
        if(this::folder_uri.isInitialized)
        println("uri==="+folder_uri);
    }
}
