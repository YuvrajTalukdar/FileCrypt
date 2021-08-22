import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:base32/base32.dart';
import 'package:path_provider/path_provider.dart';

import 'package:filecrypt/aes.dart';
import 'package:filecrypt/exploreGrid.dart';

class PathInfo
{
  String path="",name="";
  bool is_dir=false;
}

class file_read_write {
  String localPath="";
  late aes aes_handler;

  Future<String> get _localPath async//ok check
  {
    final dir=await getApplicationSupportDirectory();
    //final directory = await getApplicationDocumentsDirectory();
    return dir.path;
  }
  
  load_path() async//ok check
  {
    localPath=await _localPath;
    aes_handler = aes();
  }

  String get_name_from_dir(String path) //ok check
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

  List<PathInfo> get_path_list(String path) //ok check
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
    //DateTime now = new DateTime.now();
    final File file = File('${path.path}/passcheck'/*+now.year.toString()+
    now.month.toString()+now.day.toString()+now.hour.toString()+now.minute.toString()+now.second.toString()*/);
    await file.writeAsString(aes_handler.encrypt(pass, pass));
  }

  void delete_folder(String folderName)//ok check
  {
    String path=localPath+"/"+folderName;
    final dir = Directory(path);
    dir.deleteSync(recursive: true);
  }

  Future<List<int>> decrypt_file(String path,String pass) async//ok check
  {
    File encryptedFile = File(path);
    final iterator = ChunkedStreamReader(encryptedFile.openRead());
    List<int> decrypted_byte_list=[];
    while(true)
    {
      List<int> lengthBytes = await iterator.readChunk(5472);//16,16,32,1376,2736
      if (lengthBytes.isEmpty)
      { break;}
      String encrypted_text=base64.encode(lengthBytes);
      String decrypted_text=aes_handler.decrypt(encrypted_text,pass);
      //print("enc_len1= "+lengthBytes.length.toString()+" dec_len1="+decrypted_text.length.toString());
      List<int> decrypted_byte_block=base64.decode(decrypted_text);

      decrypted_byte_list.addAll(decrypted_byte_block);
    }
    return decrypted_byte_list;
  }

  int get_icon_code(String ext)//ok check
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

  Future<Image> get_thumbnail(String encryptedFilePath,String pass) async//ok check
  {
    List<int> bytes = await decrypt_file(encryptedFilePath, pass);
    return Image(image: ResizeImage(MemoryImage(Uint8List.fromList(bytes)), width: 80, height: 80));
    //return Image.memory(Uint8List.fromList(bytes));
  }

  Future<vaultContent> decrypt_file_and_load_data(String path,String pass) async//ok check
  {
    vaultContent content=vaultContent();
    content.encryptedFileName=get_name_from_dir(path);
    content.fileName=aes_handler.decrypt(base32.decodeAsString(content.encryptedFileName),pass);

    content.iconCode=get_icon_code(get_ext(content.fileName));
    if(content.iconCode==-1)
    { content.thumbnail=await get_thumbnail(path, pass);}

    return content;
  }

  String get_ext(String file_name)//ok check
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

  Future<List<vaultContent>> add_files_to_vault(int startId,String vaultName,String pass, List<File> fileList) async //ok check
  {
    //Stopwatch watch=new Stopwatch()..start();
    List<vaultContent> contentList=[];
    for(int a=0;a<fileList.length;a++)
    {
      vaultContent content=new vaultContent();
      content.id=startId;
      startId++;
      content.fileName=get_name_from_dir(fileList[a].path);
      content.iconCode=get_icon_code(get_ext(content.fileName));
      content.encryptedFileName=base32.encodeString(aes_handler.encrypt(get_name_from_dir(fileList[a].path),pass));
      String path=localPath+"/"+vaultName+"/"+content.encryptedFileName;
      content.encryptedFilePath=path;
      List<int> decrypted_byte_list=[];

      File encryptedFile = File(path);
      if(!(await encryptedFile.exists())) {
        final iterator = ChunkedStreamReader(fileList[a].openRead());
        while (true) {
          List<int> lengthBytes = await iterator.readChunk(4096); //4,8,16,1024,2048
          if(lengthBytes.isEmpty)
          { break;}
          decrypted_byte_list.addAll(lengthBytes);

          String plain_text = base64.encode(lengthBytes);
          String encrypted_text = aes_handler.encrypt(plain_text, pass);
          List<int> encrypted_bytes = base64.decode(encrypted_text);
          encryptedFile.writeAsBytesSync(encrypted_bytes, mode: FileMode.append, flush: false);
          //print("enc_len= "+encrypted_bytes.length.toString()+" dec_len="+plain_text.length.toString()+" orig_len="+lengthBytes.length.toString());
          //encryptedFile.writeAsBytesSync(lengthBytes,mode:FileMode.append,flush: false);//for writing non encrypted bytes
        }
        if (content.iconCode == -1)
        { content.thumbnail = Image(image: ResizeImage(MemoryImage(Uint8List.fromList(decrypted_byte_list)), width: 80, height: 80));}
        contentList.add(content);
      }
    }
    //print('fx executed in ${watch.elapsed}');
    return contentList;
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
    content.encryptedFileName=base32.encodeString(aes_handler.encrypt(newName,pass));
    content.encryptedFilePath=localPath+"/"+vaultName+"/"+content.encryptedFileName;
    File(currentFilePath).rename(content.encryptedFilePath);
    return content;
  }

  Future<void> move_file_out(vaultContent content,String pass) async//ok check
  {
    String destination="uri_to_file";
    String temp_path=localPath+"/"+destination;
    Directory path= Directory(temp_path);
    if(!await path.exists())
    {
      path.create();
    }
    File decryptedFile = File(temp_path+"/"+content.fileName);
    File encryptedFile = File(content.encryptedFilePath);
    final iterator = ChunkedStreamReader(encryptedFile.openRead());
    while(true)
    {
      List<int> lengthBytes = await iterator.readChunk(5472);//16,16,32,1376,2736
      if (lengthBytes.isEmpty)
      { break;}
      String encrypted_text=base64.encode(lengthBytes);
      String decrypted_text=aes_handler.decrypt(encrypted_text,pass);
      //print("enc_len1= "+lengthBytes.length.toString()+" dec_len1="+decrypted_text.length.toString());
      List<int> decrypted_byte_block=base64.decode(decrypted_text);

      decryptedFile.writeAsBytesSync(decrypted_byte_block,mode:FileMode.append,flush:false);
    }
  }
}