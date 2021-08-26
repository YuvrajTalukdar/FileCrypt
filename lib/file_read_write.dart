import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:base32/base32.dart';
import 'package:path_provider/path_provider.dart';

import 'package:filecrypt/aes.dart';
import 'package:filecrypt/exploreGrid.dart';

import 'dart:isolate';

class PathInfo
{
  String path="",name="";
  bool is_dir=false;
}

class progressBarData
{
  int total=0;
  int complete=0;
  double progressVal=0;
}

class file_read_write {
  String localPath="";

  Future<String> get _localPath async//ok check
  {
    final dir=await getApplicationSupportDirectory();
    //final directory = await getApplicationDocumentsDirectory();
    return dir.path;
  }
  
  load_path() async//ok check
  {
    localPath=await _localPath;
  }

  static String get_name_from_dir(String path) //ok check
  {
    String name = "";
    for (int a = path.length - 1; a >= 0; a--) {
      if (path[a] == '/') {
        break;
      }
      else {
        name = path[a] + name;
      }
    }
    return name;
  }

  static List<PathInfo> get_path_list(String path) //ok check
  {
    var dir = new Directory(path);
    List contents = dir.listSync();
    List<PathInfo> pathInfoList = [];
    for (var fileOrDir in contents) {
      PathInfo info = PathInfo();
      info.path = fileOrDir.path;
      if (fileOrDir is File) {
        info.is_dir = false;
      }
      else {
        info.is_dir = true;
      }
      info.name = get_name_from_dir(fileOrDir.path);
      pathInfoList.add(info);
    }
    return pathInfoList;
  }

  void create_folder(String folder_name,String pass) async//ok check
  {
    String new_path=localPath+"/"+folder_name;
    Directory path= Directory(new_path);
    if(!await path.exists())
    {
      path.create();
    }
    final File file = File('${path.path}/passcheck');
    await file.writeAsString(aes.encrypt(pass, pass));
  }

  void delete_folder(String folderName)//ok check
  {
    String path=localPath+"/"+folderName;
    final dir = Directory(path);
    dir.deleteSync(recursive: true);
  }

  //static Future<Uint8List> decrypt_file(String path,String pass) async//ok check
  static Future<List<int>> decrypt_file(String path,String pass) async//ok check
  {
    File encryptedFile = File(path);
    final iterator = ChunkedStreamReader(encryptedFile.openRead());
    //BytesBuilder decrypted_byte_list=BytesBuilder();
    List<int> decrypted_byte_list=[];
    while(true)
    {
      List<int> lengthBytes = await iterator.readChunk(5472);//16,16,32,1376,2736
      if (lengthBytes.isEmpty)
      { break;}
      String encrypted_text=base64.encode(lengthBytes);
      String decrypted_text=aes.decrypt(encrypted_text,pass);
      //print("enc_len1= "+lengthBytes.length.toString()+" dec_len1="+decrypted_text.length.toString());
      //Uint8List decrypted_byte_block=base64.decode(decrypted_text);
      //List<int> decrypted_byte_block=base64.decode(decrypted_text).toList();

      //decrypted_byte_list.add(decrypted_byte_block);
      decrypted_byte_list.addAll(base64.decode(decrypted_text).toList());
    }
    //return decrypted_byte_list.toBytes();
    return decrypted_byte_list;
  }

  static int get_icon_code(String ext)//ok check
  {
    if(ext.length!=0) {
      if (ext.toLowerCase().compareTo("jpeg") == 0 ||
          ext.toLowerCase().compareTo("png") == 0 ||
          ext.toLowerCase().compareTo("bmp") == 0 ||
          ext.toLowerCase().compareTo("gif") == 0 ||
          ext.toLowerCase().compareTo("jpg") == 0)
      { return -1;}
      else if (ext.toLowerCase().compareTo("pdf") == 0)
      { return 1;}
      else if (ext.toLowerCase().compareTo("avi") == 0 ||
              ext.toLowerCase().compareTo("mp4") == 0 ||
              ext.toLowerCase().compareTo("webm") == 0 ||
              ext.toLowerCase().compareTo("mkv") == 0)
      { return 2;}
      else if(ext.toLowerCase().compareTo("zip") == 0||
              ext.toLowerCase().compareTo("7z") == 0||
              ext.toLowerCase().compareTo("rar") == 0)
      { return 0;}
      else
      { return -2;}
    }
    else
    { return -2;}//may need to change
  }

  static Future<Image> get_thumbnail(String encryptedFilePath,String pass) async//ok check
  {
    List<int> bytes = await decrypt_file(encryptedFilePath, pass);
    Uint8List list=Uint8List.fromList(bytes);
    MemoryImage memoryImage=MemoryImage(list);
    Image image = Image(image: ResizeImage(memoryImage, width: 80, height: 80));

    bytes.clear();
    return image;
  }

  static Future<vaultContent> decrypt_file_and_load_data(String path,String pass) async//ok check
  {
    vaultContent content=vaultContent();
    content.encryptedFileName=get_name_from_dir(path);
    content.fileName=aes.decrypt(base32.decodeAsString(content.encryptedFileName),pass);

    content.iconCode=get_icon_code(get_ext(content.fileName));
    if(content.iconCode==-1)
    { content.thumbnail=await get_thumbnail(path, pass);}

    return content;
  }

  static void openVault(List<Object> arguments) async
  {
    SendPort sendPort = arguments[0] as SendPort;
    String vaultName = arguments[1] as String;
    String localPath2 = arguments[2] as String;
    String password = arguments[3] as String;

    List<PathInfo> pathinfoList=get_path_list(localPath2+"/"+vaultName);
    //decrypt data
    //progressBarData progress=progressBarData();
    //progress.total=pathinfoList.length;
    List<vaultContent> contentList=[];
    for(int a=0;a<pathinfoList.length;a++)
    {
      if(pathinfoList[a].name.compareTo("passcheck")!=0)
      {
        vaultContent content=await decrypt_file_and_load_data(pathinfoList[a].path,password);
        content.encryptedFilePath=pathinfoList[a].path;
        content.id=contentList.length;
        contentList.add(content);
      }
      //progress.progressVal=(a+1).toDouble()/(pathinfoList.length).toDouble();
      //progress.complete=a+1;
      //sendPort.send(progress);
    }
    sendPort.send(contentList);
  }

  static String get_ext(String file_name)//ok check
  {
    bool ext_found=false;
    String ext="";
    for(int a=file_name.length-1;a>=0;a--)
    {
      if(file_name[a]=='.')
      {
        ext_found=true;
        break;
      }
      else
      { ext=file_name[a]+ext;}
    }
    if(!ext_found)
    { ext="";}

    return ext;
  }

  static add_files_to_vault(List<Object> arguments) async
  {
    SendPort sendPort = arguments[0] as SendPort;
    int startId=arguments[1] as int;
    String vaultName = arguments[2] as String;
    String pass = arguments[3] as String;
    List<File> fileList = arguments[4] as List<File>;
    String localPath2 = arguments[5] as String;
    List<vaultContent> contentList=[];
    //Stopwatch watch=Stopwatch()..start();
    for(int a=0;a<fileList.length;a++)
    {
      vaultContent content=new vaultContent();
      content.id=startId;
      startId++;
      content.fileName=get_name_from_dir(fileList[a].path);
      content.iconCode=get_icon_code(get_ext(content.fileName));
      content.encryptedFileName=base32.encodeString(aes.encrypt(get_name_from_dir(fileList[a].path),pass));

      String path=localPath2+"/"+vaultName+"/"+content.encryptedFileName;
      content.encryptedFilePath=path;
      List<int> decrypted_byte_list=[];

      File encryptedFile = File(path);
      if(!(await encryptedFile.exists())) {
        final iterator = ChunkedStreamReader(fileList[a].openRead());
        while (true) {
          List<int> lengthBytes = await iterator.readChunk(4096); //4096
          if(lengthBytes.isEmpty)
          { break;}
          if(content.iconCode==-1)
          { decrypted_byte_list.addAll(lengthBytes);}

          String plain_text = base64.encode(lengthBytes);
          String encrypted_text = aes.encrypt(plain_text, pass);
          List<int> encrypted_bytes = base64.decode(encrypted_text);
          encryptedFile.writeAsBytesSync(encrypted_bytes, mode: FileMode.append, flush: false);
          //print("enc_len= "+encrypted_bytes.length.toString()+" dec_len="+plain_text.length.toString()+" orig_len="+lengthBytes.length.toString());
          //encryptedFile.writeAsBytesSync(lengthBytes,mode:FileMode.append,flush: false);//for writing non encrypted bytes
        }
        if (content.iconCode == -1)
        { content.thumbnail = Image(image: ResizeImage(MemoryImage(Uint8List.fromList(decrypted_byte_list)), width: 80, height: 80));}
        contentList.add(content);
        decrypted_byte_list.clear();
      }
      sendPort.send(a+1);
    }
    //print('fx executed in ${watch.elapsed}');
    sendPort.send(contentList);
  }

  void delete_vault_file(String encrypted_file_path)//ok check
  { File(encrypted_file_path).delete();}
  
  vaultContent rename_vault_file(String newName,String oldName,String currentFilePath,String vaultName,String pass)//ok check
  {
    vaultContent content=new vaultContent();
    String ext=get_ext(oldName);
    if(ext.length!=0)
    { newName=newName+"."+ext;}
    content.fileName=newName;
    content.encryptedFileName=base32.encodeString(aes.encrypt(newName,pass));
    content.encryptedFilePath=localPath+"/"+vaultName+"/"+content.encryptedFileName;
    File(currentFilePath).rename(content.encryptedFilePath);
    return content;
  }

  static void move_file_out(List<Object> arguments) async//ok check
  {
    SendPort sendPort = arguments[0] as SendPort;
    String pass = arguments[1] as String;
    List<vaultContent> fileList = arguments[2] as List<vaultContent>;
    String localPath2 = arguments[3] as String;
    String destination="uri_to_file";
    String temp_path=localPath2+"/"+destination;
    Directory path= Directory(temp_path);
    if(!await path.exists())
    {
      path.create();
    }
    for(int a=0;a<fileList.length;a++)
    {
      File decryptedFile = File(temp_path + "/" + fileList[a].fileName);
      File encryptedFile = File(fileList[a].encryptedFilePath);
      final iterator = ChunkedStreamReader(encryptedFile.openRead());
      while (true) {
        List<int> lengthBytes = await iterator.readChunk(5472); //16,16,32,1376,2736
        if (lengthBytes.isEmpty)
        { break;}
        String encrypted_text = base64.encode(lengthBytes);
        String decrypted_text = aes.decrypt(encrypted_text, pass);
        //print("enc_len1= "+lengthBytes.length.toString()+" dec_len1="+decrypted_text.length.toString());
        List<int> decrypted_byte_block = base64.decode(decrypted_text);
        decryptedFile.writeAsBytesSync(decrypted_byte_block, mode: FileMode.append, flush: false);
        //sendPort.send(a+1);
      }
    }
    sendPort.send("complete");
  }

  double get_file_size(String path)
  { return File(path).lengthSync().toDouble();}

  DateTime get_file_added_date(String path)
  { return File(path).lastModifiedSync();}
}