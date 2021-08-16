import 'dart:async';
import 'dart:io';

import 'dart:convert';
import 'dart:ui';
import 'package:async/async.dart';

import 'package:path_provider/path_provider.dart';
import 'package:filecrypt/aes.dart';

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
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
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
    DateTime now = new DateTime.now();
    final File file = File('${path.path}/passcheck_'+now.year.toString()+
    now.month.toString()+now.day.toString()+now.hour.toString()+now.minute.toString()+now.second.toString());
    await file.writeAsString(aes_handler.encrypt(pass, pass));
  }

  void delete_folder(String folderName)//ok check
  {
    String path=localPath+"/"+folderName;
    final dir = Directory(path);
    dir.deleteSync(recursive: true);
  }

  void read_file_from_vault(String vaultName,String path,String pass) async
  {
    File decryptedFile = File(localPath+"/"+vaultName+"/test.jpg");
    File encryptedFile = File(path);
    final iterator = ChunkedStreamReader(encryptedFile.openRead());
    while(true)
    {
      List<int> lengthBytes = await iterator.readChunk(5472);//16,16,32,1376,2736
      if (lengthBytes.isEmpty)
      { break;}
      String encrypted_text=base64.encode(lengthBytes);
      String decrypted_text=aes_handler.decrypt(encrypted_text,pass);
      //print("enc_len1= "+lengthBytes.length.toString()+" dec_len1="+decrypted_text.length.toString());
      List<int> decrypted_bytes=base64.decode(decrypted_text);

      decryptedFile.writeAsBytesSync(decrypted_bytes,mode:FileMode.append,flush: false);
    }
  }

  void add_files_to_vault(String vaultName,String pass, List<File> fileList) async //ok check
  {
    //Stopwatch watch=new Stopwatch()..start();
    for(int a=0;a<fileList.length;a++)
    {
      File encryptedFile = File(localPath+"/"+vaultName+"/"+get_name_from_dir(fileList[a].path));
      final iterator = ChunkedStreamReader(fileList[a].openRead());
      while (true) {
        List<int> lengthBytes = await iterator.readChunk(4096);//4,8,16,1024,2048
        if (lengthBytes.isEmpty)
        { break;}

        String plain_text=base64.encode(lengthBytes);
        String encrypted_text=aes_handler.encrypt(plain_text, pass);
        List<int> encrypted_bytes=base64.decode(encrypted_text);
        encryptedFile.writeAsBytesSync(encrypted_bytes,mode:FileMode.append,flush: false);
        //print("enc_len= "+encrypted_bytes.length.toString()+" dec_len="+plain_text.length.toString()+" orig_len="+lengthBytes.length.toString());
        //encryptedFile.writeAsBytesSync(lengthBytes,mode:FileMode.append,flush: false);//for writing non encrypted bytes
      }
      //testing
      //read_file_from_vault(vaultName,localPath+"/"+vaultName+"/"+get_name_from_dir(fileList[a].path),pass);
    }
    //print('fx executed in ${watch.elapsed}');
  }
}