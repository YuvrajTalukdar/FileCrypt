import 'dart:async';
import 'dart:io';

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
}