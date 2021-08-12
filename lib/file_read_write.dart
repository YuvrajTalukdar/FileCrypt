import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:ext_storage/ext_storage.dart';

class PathInfo
{
  String path="",name="";
  bool is_dir=false;
}

class file_read_write {
  Future<String> get _localPath async
  {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  /*Future<String> get_ext_path() async
  {
    var path = await ExtStorage.getExternalStorageDirectory();
    return path;
  }*/

  /*Future<String> get_menu_item_path(int item_code) async
  {
    String path="";
    if(item_code==0)
    { path = await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_PICTURES);}
    else if(item_code==1)
    { path = await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_MUSIC);}
    else if(item_code==2)
    { path = await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_MOVIES);}
    else if(item_code==3)
    { path = await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_DOCUMENTS);}
    else if(item_code==4)
    { path = await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_DOWNLOADS);}

    return path;
  }*/

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

  void create_folder(String folder_name,String pass) async
  {
    String appPath = await _localPath;
    print("path1="+appPath);
    final path= Directory(appPath+"/"+folder_name);
    if(!await path.exists())
    {
      path.create();
    }
  }

  void delete_folder() {

  }
}