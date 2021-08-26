import 'dart:typed_data';

import 'package:filecrypt/database.dart';
import 'package:filecrypt/exploreGrid.dart';
import 'package:filecrypt/vaultOpenDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:filecrypt/theme.dart';
import 'package:filecrypt/theme_dialog.dart';
import 'package:filecrypt/vaultGrid.dart';
import 'dart:io';
import 'dart:async';
import 'dart:isolate';
import 'package:flutter/services.dart';

import 'package:uri_to_file/uri_to_file.dart';//uri
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked_themes/stacked_themes.dart';
import 'package:filecrypt/floating_action_button.dart';
import 'package:filecrypt/file_read_write.dart';
import 'package:filecrypt/aes.dart';
import 'package:filecrypt/FileRenameDialog.dart';
import 'package:filecrypt/AboutFile.dart';
import 'package:filecrypt/ImageViewer.dart';
import 'package:filecrypt/AboutDialog.dart';

Future main() async
{
  await ThemeManager.initialise();
  runApp(const FileCrypt());
}

class FileCrypt extends StatelessWidget
{
  const FileCrypt({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      themes:getThemes(),
      builder: (context,regularTheme,darkTheme,themeMode)=>
        MaterialApp(
          title: 'File Crypt',
          home: Home(key:Key('')),
          theme: regularTheme,
          darkTheme: darkTheme,
          themeMode: themeMode,
        ),
    );
  }
}

class Home extends StatefulWidget {
  Home({required Key key}) : super(key: key);

  List<vaultData> vaultDataList=[];
  List<vaultData> vaultDataListViewer=[];
  bool onceExecuted=false;

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> with TickerProviderStateMixin {

  String searchText="";
  String searchHint="Search Vault";
  var search_textfield_controller = TextEditingController();

  late TabController _tabController;

  late file_read_write frw;

  String password="";
  String vaultName="";

  List<vaultContent> vaultContentList=[];
  List<vaultContentBackup> vaultContentBackupList=[];//used for searching and holds only the items which are not required to be displayed.
  List<vaultContent> selectedItems=[];

  bool is_select_mode_on=false;
  int no_of_selected_items=0;
  bool select_all_items=false;

  static const platform = const MethodChannel('flutter.native/helper');

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 2);
    _tabController.addListener(() {
      setState(() {
        if(_tabController.index==0)
        { searchHint="Search Vault";}
        else
        { searchHint="Search File";}
      });
    });
    frw=file_read_write();
    frw.load_path();

    platform.setMethodCallHandler(this.kotlin_method_call_handler);
  }

  Future<void> kotlin_method_call_handler(MethodCall call) async {
    switch(call.method) {
      case "writePermissionStatus":
        String utterance = call.arguments;
        if (utterance.compareTo("cancel") == 0) {
          Fluttertoast.showToast(
            msg: "Folder not selected.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        }
        else if (utterance.compareTo("ok") == 0)
        { move_files_out();}
        break;
      case "readPermissionStatus":
        String encodedPath = call.arguments;
        String decodedPath = "";
        List<File> fileList=[];
        if (encodedPath.length > 0)
        {
          for (int a = 0; a < encodedPath.length; a++) {
            if (encodedPath[a] == '*')
            {
              Uri uri = Uri.parse(decodedPath); // Parsing uri string to uri
              File file = await toFile(uri);
              fileList.add(file);
              decodedPath = "";
            }
            else
            { decodedPath=decodedPath+encodedPath[a];}
          }
          add_files_to_vault(fileList);
        }
        else
        {
          Fluttertoast.showToast(
            msg: "File not selected.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        }
        break;
      case "move_file_out_postprocesing":
        move_file_out_postprocesing();
        break;
    }
  }

  void pick_files()
  {
    try
    { platform.invokeMethod("requestReadPermission");}
    on PlatformException catch (e)
    {}
  }

  void move_file_out_postprocesing()
  {
    delete_items();
    check_all(false);
    setState(() {
      select_all_items = false;
    });
    frw.delete_folder("uri_to_file");
    Fluttertoast.showToast(
      msg: "Files moved out of vault.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
    Navigator.of(context).pop(true);
  }

  String progressMsg="";
  void progressCircle()
  {
    AlertDialog alert = AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircularProgressIndicator(color: Theme.of(context).primaryColor,),
          SizedBox(height: 15,),
          Text(progressMsg,style: Theme.of(context).textTheme.bodyText2),
        ],
      ),
      backgroundColor: Colors.grey[850],
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void getData() async{
    List<vaultData> vaultDataList=await ArchiveDatabase.instance.readAllVault();
    setState(() {
      widget.vaultDataList=vaultDataList;
      widget.vaultDataListViewer=[]..addAll(vaultDataList);
    });
    //vaultDataList.clear();
  }

  bool is_vault_open()
  {
    if(password.length==0)
    { return false;}
    else
    { return true;}
  }

  void closeVault()
  {
    password="";
    vaultName="";
    selectedItems.clear();
    setState(() {
      vaultContentList.clear();
      is_select_mode_on=false;
      no_of_selected_items=0;
      select_all_items=false;
    });
    PaintingBinding.instance!.imageCache!.clear();
    PaintingBinding.instance!.imageCache!.clearLiveImages();
    Fluttertoast.showToast(
      msg: "Vault Locked",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  static void getImage(List<Object> arguments) async
  {
    SendPort sendPort = arguments[0] as SendPort;
    String encryptedPath = arguments[1] as String;
    String password = arguments[2] as String;
    Image image=Image.memory(Uint8List.fromList((await file_read_write.decrypt_file(encryptedPath, password))));
    sendPort.send(image);
  }

  late Isolate imageViewerIsolate;
  void openImageViewer(vaultContent content) async
  {
    ReceivePort receivePort = ReceivePort();
    imageViewerIsolate=await Isolate.spawn((getImage),[receivePort.sendPort,content.encryptedFilePath,password]);
    progressMsg="Loading";
    progressCircle();
    receivePort.listen((data) {
      if(data is Image)
      {
        Navigator.pop(context);
        Navigator.push(context,MaterialPageRoute(builder: (context) => ImageViewer(key:Key(''),imageName: content.fileName,image:data)),);
        //Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => ImageViewer(key:Key(''),imageName: content.fileName,image:data)), (e) => false);
        //imageViewerIsolate.kill();
      }
    });
  }

  void move_files_out() async
  {
    Stopwatch watch=Stopwatch()..start();
    int size_of_one_list=(selectedItems.length/no_of_threads).toInt();
    List<List<vaultContent>> list_of_selectedItemList=[];
    //print("list_size="+size_of_one_list.toString());
    int listLen=selectedItems.length;
    for(int a=0;a<no_of_threads;a++)
    { print("a="+a.toString());
      List<vaultContent> new_file_list=[];
      for(int b=listLen-1;b>=listLen-size_of_one_list;b--)
      {   print("b="+b.toString()+" less="+(listLen-size_of_one_list).toString());
        new_file_list.add(selectedItems[b]);
      }
      listLen-=size_of_one_list;
      list_of_selectedItemList.add(new_file_list);
    }
    if(listLen>0)
    {
      for(int a=0;a<listLen;a++)
      {
        list_of_selectedItemList[list_of_selectedItemList.length-1].add(selectedItems[a]);
      }
    }
    for(int a=0;a<list_of_selectedItemList.length;a++)
    {
      ReceivePort receivePort= ReceivePort();
      await Isolate.spawn((file_read_write.move_file_out),[receivePort.sendPort,password,list_of_selectedItemList[a],frw.localPath]);
      receivePort.listen((data) {
        if(data is String)
        {
          no_of_complete_thread++;
          if(no_of_complete_thread==no_of_threads)
          {
            try
            { platform.invokeMethod("moveFilesOut");}
            on PlatformException catch (e)
            {}
            list_of_selectedItemList.clear();
            print('fx executed in ${watch.elapsed}');
          }
        }
        else if(data is int)
        {

        }
      });
    }
    progressMsg="Moving Files Out";
    progressCircle();
  }

  int no_of_threads=4;
  int no_of_complete_thread=0;
  void add_files_to_vault(List<File> fileList) async
  {
    Stopwatch watch=Stopwatch()..start();
    search("");
    int size_of_one_list=(fileList.length/no_of_threads).toInt();
    List<List<File>> list_of_fileList=[];
    //print("list_size="+size_of_one_list.toString());
    int listLen=fileList.length;
    for(int a=0;a<no_of_threads;a++)
    { //print("a="+a.toString());
      List<File> new_file_list=[];
      for(int b=fileList.length-1;b>=listLen-size_of_one_list;b--)
      {   //print("b="+b.toString()+" less="+(listLen-size_of_one_list).toString());
          new_file_list.add(fileList.removeAt(b));
      }
      listLen-=size_of_one_list;
      list_of_fileList.add(new_file_list);
    }

    if(fileList.length>0)
    {
      for(int a=0;a<fileList.length;a++)
      {
        list_of_fileList[list_of_fileList.length-1].add(fileList[a]);
      }
      fileList.clear();
    }
    int first_id;
    if(vaultContentList.length==0)
    { first_id=0;}
    else
    { first_id=vaultContentList[vaultContentList.length-1].id+1;}
    for(int a=0;a<list_of_fileList.length;a++)
    {
      ReceivePort receivePort= new ReceivePort();
      await Isolate.spawn((file_read_write.add_files_to_vault),[receivePort.sendPort,first_id,vaultName,password,list_of_fileList[a],frw.localPath]);
      receivePort.listen((data) {
        if(data is List<vaultContent>) {
          List<vaultContent> contentList = data;
          setState(() {
            vaultContentList.addAll(contentList);
          });
          no_of_complete_thread++;
          if(no_of_complete_thread==no_of_threads)
          {
            frw.delete_folder("uri_to_file");
            Navigator.of(context).pop(true);
            no_of_complete_thread=0;
            list_of_fileList.clear();
            print('fx executed in ${watch.elapsed}');
          }
        }
        else if(data is int)
        {

        }
      });
      first_id+=size_of_one_list;
    }
    progressMsg="Adding Files";
    progressCircle();
  }

  void delete_items()
  {
    List<vaultContent> contentList=[]..addAll(vaultContentList);
    for(int a=0;a<selectedItems.length;a++)
    {
      frw.delete_vault_file(selectedItems[a].encryptedFilePath);
      contentList.removeWhere((element) => element.id==selectedItems[a].id);
    }
    setState(() {
      vaultContentList=contentList;
      no_of_selected_items=0;
      is_select_mode_on=false;
    });
    selectedItems.clear();
  }

  void rename_file(vaultContent content,String newName)
  {
    for(int a=0;a<vaultContentList.length;a++)
    {
      if(vaultContentList[a].id==content.id)
      {
        vaultContent content=frw.rename_vault_file(newName,vaultContentList[a].fileName,vaultContentList[a].encryptedFilePath,vaultName,password);
        selectedItems=[];
        setState(() {
          vaultContentList[a].fileName=content.fileName;
          vaultContentList[a].encryptedFilePath=content.encryptedFilePath;
          vaultContentList[a].encryptedFileName=content.encryptedFileName;
        });
        check_all(false);
        setState(() {
          select_all_items = false;
        });
        break;
      }
    }
  }

  late Isolate openVaultIsolate;
  void openVault(int vault_id,String vault_name,String pass) async
  {
    File passCheckFile = File(frw.localPath+"/"+vault_name+"/passcheck");
    String text = await passCheckFile.readAsString();
    text=aes.decrypt(text,pass);

    if(text.compareTo(pass)==0)
    {
      password=pass;
      vaultName=vault_name;
      FocusScope.of(context).unfocus();
      ReceivePort receivePort= ReceivePort();
      openVaultIsolate = await Isolate.spawn((file_read_write.openVault),[receivePort.sendPort,vaultName,frw.localPath,password]);
      receivePort.listen((data) {
        if(data is List<vaultContent>)
        {
          List<vaultContent> contentList=data;
          setState(() {
            vaultContentList=contentList;
          });
          Fluttertoast.showToast(
            msg: "Vault Unlocked",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
          Navigator.of(context).pop();
          //openVaultIsolate.kill();
        }
        else if(data is progressBarData)
        {

        }
      });
      Navigator.of(context).pop(true);
      progressMsg="Opening Vault";
      progressCircle();
    }
    else
    {
      Fluttertoast.showToast(
        msg: "Incorrect Password !",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void openVaultDialog(int id,String vaultName)
  {
    if(!is_vault_open())
    { VaultOpenDialog.start(context,new Key(""),openVault,id,vaultName);}
    else
    {
      Fluttertoast.showToast(
        msg: "Close the already open vault first.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void search(String searchText)
  {
    if(_tabController.index==0)
    {
      List<vaultData> temp_vaultData_list = [];
      widget.vaultDataListViewer.clear();
      for (int a = 0; a < widget.vaultDataList.length; a++) {
        if (widget.vaultDataList[a].vaultName.toLowerCase().contains(searchText.toLowerCase()) ||
            searchText.length == 0) {
          temp_vaultData_list.add(widget.vaultDataList[a]);
        }
      }
      setState(() {
        widget.vaultDataListViewer = temp_vaultData_list;
      });
    }
    else
    {
      List<vaultContent> ContentList=[];
      if(vaultContentBackupList.length>0)
      {
        for(int a=vaultContentBackupList.length-1;a>=0;a--)
        {
          if(vaultContentBackupList[a].index<vaultContentList.length)
          { vaultContentList.insert(vaultContentBackupList[a].index,vaultContentBackupList[a].contentBackup);}
          else
          { vaultContentList.add(vaultContentBackupList[a].contentBackup);}
        }
        vaultContentBackupList.clear();
      }
      for(int a=vaultContentList.length-1;a>=0;a--)
      {
        if(vaultContentList[a].fileName.toLowerCase().contains(searchText.toLowerCase()) ||
          searchText.length==0)
        {
          ContentList.add(vaultContentList[a]);
        }
        else
        {
          vaultContentBackup backup=new vaultContentBackup();
          backup.index=a;
          backup.contentBackup=vaultContentList[a];
          vaultContentBackupList.add(backup);
        }
      }
      setState(() {
        vaultContentList=ContentList.reversed.toList();
      });
    }
  }

  Widget cancelIcon()
  {
    if (searchText.length > 0)
    {
      return IconButton
        (
        icon:
        IconButton(
          padding: EdgeInsets.zero,
          icon:Icon(Icons.cancel,color:Theme.of(context).primaryColor),
          onPressed: (){
            search_textfield_controller.clear();
            search("");
            setState(()
            { searchText = "";});
            FocusScope.of(context).unfocus();
          },
        ),
        onPressed: (){},
      );
    }
    else
    { return SizedBox.shrink();}
  }

  void select_mode(bool mode)
  {
    setState(() {
      is_select_mode_on=mode;
    });
  }

  bool get_selected_mode()
  { return is_select_mode_on;}

  void selected_items_counter(int nos,vaultContent content)
  {
    if(nos>no_of_selected_items)
    { selectedItems.add(content);}
    else
    {
      for(int a=selectedItems.length-1;a>=0;a--)
      {
        if(content.id==selectedItems[a].id)
        { selectedItems.removeAt(a);}
      }
    }
    setState(() {
      no_of_selected_items=nos;
    });
    print("nos= "+selectedItems.length.toString());
  }

  int get_no_of_selected_items()
  { return no_of_selected_items;}

  Widget rename_button()
  {
    if(no_of_selected_items==1)
    {
      return
      Material(
          elevation: 4.0,
          shape: CircleBorder(),
          clipBehavior: Clip.hardEdge,
          color: Colors.grey[850],
          child: Ink(
            width: 30.0,
            height: 30.0,
            child: InkWell(
              child: Icon(Icons.drive_file_rename_outline, size: 20, color: Theme.of(context).primaryColor,),
              onTap: ()
              {
                FileRenameDialog.start(context,new Key(""),rename_file,selectedItems[0]);
              },
            ),
          )
      );
    }
    else
    { return Container();}
  }

  Widget about_button()
  {
    if(no_of_selected_items==1) {
      return
      Material(
          elevation: 4.0,
          shape: CircleBorder(),
          clipBehavior: Clip.hardEdge,
          color: Colors.grey[850],
          child: Ink(
            width: 30.0,
            height: 30.0,
            child: InkWell(
              child: Icon(Icons.info, size: 20, color: Theme.of(context).primaryColor,),
              onTap: ()
              {
                AboutFilenDialog.start(
                    context,new Key(""),
                    frw.get_file_size(selectedItems[0].encryptedFilePath),
                    frw.get_file_added_date(selectedItems[0].encryptedFilePath),
                    selectedItems[0].fileName);
              },
            ),
          )
      );
    }
    else
    { return Container();}
  }

  Color getColor(Set<MaterialState> states)
  { return Theme.of(context).primaryColor;}

  void check_all(bool check)
  {
    List<vaultContent> ContentList=[]..addAll(vaultContentList);
    for(int a=0;a<ContentList.length;a++)
    { ContentList[a].selected=check;}
    setState(() {
      vaultContentList=ContentList;
    });
    select_mode(check);
    if(check)
    {
      selectedItems=vaultContentList;
      setState(() {
        no_of_selected_items=ContentList.length;
      });
    }
    else
    {
      selectedItems=[];
      setState(() {
        no_of_selected_items=0;
      });
    }
  }

  late Timer searchOnStoppedTyping=new Timer(Duration(milliseconds:500),()=>{});
  Widget search_bar_or_options()
  {
    if(is_select_mode_on)
    {
      return
      Container(
        child:  Row(
          children:<Widget> [
            Checkbox(
              fillColor: MaterialStateProperty.resolveWith(getColor),
              value: select_all_items,
              onChanged: (bool? value) {
                check_all(value!);
                setState(() {
                  select_all_items = value;
                });
              },
            ),
            Text(no_of_selected_items.toString(), style: Theme.of(context).textTheme.bodyText2,),
            Text(" Selected", style: Theme.of(context).textTheme.bodyText1,),
            Spacer(),
            rename_button(),
            SizedBox(width: 5,),
            Material(
                elevation: 4.0,
                shape: CircleBorder(),
                clipBehavior: Clip.hardEdge,
                color: Colors.grey[850],
                child: Ink(
                  width: 30.0,
                  height: 30.0,
                  child: InkWell(
                    child: Icon(Icons.delete, size: 20, color: Theme.of(context).primaryColor,),
                    onTap: ()
                    {
                      Widget cancelButton = TextButton(
                        child: Text("No", style: Theme.of(context).textTheme.bodyText1),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ButtonStyle(overlayColor: MaterialStateProperty.all(Theme.of(context).primaryColorDark)),
                      );
                      Widget continueButton = TextButton(
                        child: Text("Yes", style: Theme.of(context).textTheme.bodyText1,),
                        style: ButtonStyle(overlayColor: MaterialStateProperty.all(Theme.of(context).primaryColorDark)),
                        onPressed: () {
                          Navigator.of(context).pop();
                          delete_items();
                        },
                      );
                      AlertDialog alert = AlertDialog(
                        title: Text("Delete Files", style: Theme.of(context).textTheme.bodyText1),
                        content: Text("Do you want to delete "+selectedItems.length.toString()+" files ?",style: Theme.of(context).textTheme.bodyText2),
                        actions: [
                          cancelButton,
                          continueButton,
                        ],
                        backgroundColor: Colors.grey[850],
                      );
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return alert;
                        },
                      );
                    },
                  ),
                )
            ),
            SizedBox(width: 5,),
            Material(
                elevation: 4.0,
                shape: CircleBorder(),
                clipBehavior: Clip.hardEdge,
                color: Colors.grey[850],
                child: Ink(
                  width: 30.0,
                  height: 30.0,
                  child: InkWell(
                    child: Icon(Icons.drive_file_move, size: 20, color: Theme.of(context).primaryColor,),
                    onTap: ()
                    {
                      try
                      { platform.invokeMethod("requestWritePermission");}
                      on PlatformException catch (e)
                      {}
                    },
                  ),
                )
            ),
            SizedBox(width: 5,),
            about_button()
          ],
        )
      );
    }
    else
    {
      return
      InkWell
      (
        splashColor: Theme.of(context).primaryColorDark,
        child: TextField(
          //focusNode: _searchFocusNode,
          controller: search_textfield_controller,
          textInputAction: TextInputAction.search,
          style: Theme.of(context).textTheme.bodyText1,
          onChanged: (text) {
            if (searchOnStoppedTyping.isActive)
            { setState(() => searchOnStoppedTyping.cancel());}
            setState(() => searchOnStoppedTyping = new Timer(Duration(milliseconds:500), () => search(text)));
            setState(()
            { searchText = text;});},
            decoration: InputDecoration(
            filled: true,
            fillColor: Color(0x92575757),
            suffixIcon: cancelIcon(),
            contentPadding: new EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            hintText: searchHint,
            hintStyle: Theme.of(context).textTheme.bodyText2,
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).primaryColorDark),
                borderRadius: BorderRadius.all(Radius.circular(90.0))
            ),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
                borderRadius: BorderRadius.all(Radius.circular(90.0))
            ),
          ),
        ),
        onTap: (){},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.grey[950], //or set color with: Color(0xFF0000FF)
    ));
    if(!widget.onceExecuted)
    {
      getData();
      widget.onceExecuted=true;
    }

    void add_vault(String pass,String vaultName)
    {
      if(widget.vaultDataList.length!=widget.vaultDataListViewer)
      { search("");}

      bool duplicate=false;
      for(int a=0;a<widget.vaultDataList.length;a++)
      {
        if(widget.vaultDataList[a].vaultName.compareTo(vaultName)==0)
        { duplicate=true;break;}
      }
      if(duplicate)
      {
        Fluttertoast.showToast(
          msg: "Vault with name '"+vaultName+"' already present",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
      else
      {
        Navigator.of(context).pop(true);
        FocusScope.of(context).unfocus();
        ArchiveDatabase.instance.add_new_archive(vaultName).whenComplete(() => {getData()});
        frw.create_folder(vaultName,pass);
      }
    }

    void delete_vault(int id,String value)
    {
      if(widget.vaultDataList.length!=widget.vaultDataListViewer)
      { search("");}

      if(value.compareTo("0")==0)
      {
        int itemIndex = -1;
        for (int a = 0; a < widget.vaultDataList.length; a++) {
          if (widget.vaultDataList[a].id == id) {
            itemIndex = a;
            break;
          }
        }
        // set up the buttons
        Widget cancelButton = TextButton(
          child: Text("No", style: Theme.of(context).textTheme.bodyText1),
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ButtonStyle(overlayColor: MaterialStateProperty.all(Theme.of(context).primaryColorDark)),
        );
        Widget continueButton = TextButton(
          child: Text("Yes", style: Theme.of(context).textTheme.bodyText1,),
          style: ButtonStyle(overlayColor: MaterialStateProperty.all(Theme.of(context).primaryColorDark)),
          onPressed: () {
            frw.delete_folder(widget.vaultDataList[itemIndex].vaultName);
            ArchiveDatabase.instance.delete(id);
            setState(() {
              widget.vaultDataList.removeAt(itemIndex);
              widget.vaultDataListViewer.removeAt(itemIndex);
            });
            Navigator.of(context).pop();
          },
        );

        // set up the AlertDialog
        AlertDialog alert = AlertDialog(
          title: Text("Delete Vault", style: Theme.of(context).textTheme.bodyText1),
          content: Text("Do you want to delete vault '" +
              widget.vaultDataList[itemIndex].vaultName + "' ?", style: Theme.of(context).textTheme.bodyText2),
          actions: [
            cancelButton,
            continueButton,
          ],
          backgroundColor: Colors.grey[850],
        );

        // show the dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return alert;
          },
        );
      }
    }

    return Scaffold(
      body:DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, value)
          {
            return [
              SliverAppBar(
                floating: true,
                pinned: true,
                snap:true,
                backgroundColor: Colors.grey[900],
                title: Padding(
                  padding: const EdgeInsets.fromLTRB(5, 15, 0, 10),
                  child:search_bar_or_options()
                ),
                actions: [
                  PopupMenuButton(
                      color: Colors.grey[850],
                      elevation: 40,
                      icon: Icon(Platform.isAndroid ? Icons.more_vert : Icons.more_horiz,color:Theme.of(context).primaryColor),
                      onSelected: (value) {
                        setState(() {
                          //menuOption = value.toString();
                          if(value.toString().compareTo("Theme")==0)
                          {
                            themeCode=getThemeManager(context).selectedThemeIndex;
                            return  ThemeDialog.start(context);
                          }
                          else if(value.toString().compareTo("About")==0)
                          {
                            AboutDialogApp.start(context,Key(""));
                          }
                        });
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Text("Theme"),
                          textStyle: TextStyle(color: Theme.of(context).primaryColor),
                          value: "Theme",
                        ),
                        PopupMenuItem(
                          child: Text("About"),
                          textStyle: TextStyle(color: Theme.of(context).primaryColor),
                          value: "About",
                        )
                      ]
                  )
                ],
                bottom:
                TabBar(
                  tabs: [Tab( text: "Vaults"),Tab( text: "Vault Explorer"),],
                  indicatorColor:Theme.of(context).primaryColor,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Theme.of(context).primaryColorDark,
                  controller: _tabController,
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              Container(
                  decoration: new BoxDecoration(
                      color: Colors.black
                  ),
                  child: vaultGrid(key: new Key(""),vaultDataList: widget.vaultDataListViewer,delete_vault:delete_vault,openVaultDialog: openVaultDialog,is_vault_open: is_vault_open),
                ),
              Container(
                decoration: new BoxDecoration(
                      color: Colors.black
                ),
                child:
                exploreGrid
                (
                    key:Key(""),
                    vaultContentList:vaultContentList,
                    is_vault_open: is_vault_open,
                    select_mode: select_mode,
                    selected_items_counter: selected_items_counter,
                    get_selected_mode: get_selected_mode,
                    get_no_of_selected_items: get_no_of_selected_items,
                    openImageViewer:openImageViewer
                )
              ),
            ],
          ),
        ),
      ),
      floatingActionButton:
      floatingActionButton(
        tabController: _tabController,
        add_vault: add_vault,
        is_vault_open: is_vault_open,
        closeVault: closeVault,
        pick_files:pick_files)
    );
  }
}