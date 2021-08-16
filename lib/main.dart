import 'package:filecrypt/database.dart';
import 'package:filecrypt/vaultOpenDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:filecrypt/theme.dart';
import 'package:filecrypt/theme_dialog.dart';
import 'package:filecrypt/vaultGrid.dart';
import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked_themes/stacked_themes.dart';
import 'package:filecrypt/floating_action_button.dart';
import 'package:filecrypt/file_read_write.dart';
import 'package:filecrypt/aes.dart';

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
          home: Home(key:Key(''),title: 'File Crypt'),
          theme: regularTheme,
          darkTheme: darkTheme,
          themeMode: themeMode,
        ),
    );
  }
}

class Home extends StatefulWidget {
  Home({required Key key, required this.title}) : super(key: key);
  final String title;

  String searchText="";
  String searchHint="Search Vault";
  var search_textfield_controller = TextEditingController();


  List<vaultData> vaultDataList=[];
  List<vaultData> vaultDataListViewer=[];
  bool onceExecuted=false;

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> with TickerProviderStateMixin {

  late TabController _tabController;
  late file_read_write frw;
  late aes aes_obj;
  String password="";
  String vaultName="";

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 2);
    _tabController.addListener(() {
      setState(() {
        if(_tabController.index==0)
        { widget.searchHint="Search Vault";}
        else
        { widget.searchHint="Search File";}
      });
    });
    frw=file_read_write();
    frw.load_path();
    aes_obj=aes();
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
    Fluttertoast.showToast(
      msg: "Vault Locked",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void add_files_to_vault(List<File> fileList)
  {
    frw.add_files_to_vault(vaultName,password,fileList);
  }

  void openVault(int vault_id,String vault_name,String pass) async
  {
    List<PathInfo> pathinfoList=frw.get_path_list(frw.localPath+"/"+vault_name);
    bool pass_ok=false;
    for(int a=0;a<pathinfoList.length;a++)
    {
      if(pathinfoList[a].name.contains("passcheck_"))
      {
        File passCheckFile = File(pathinfoList[a].path);
        String text = await passCheckFile.readAsString();
        text=aes_obj.decrypt(text,pass);
        if(text.compareTo(pass)==0)
        { pass_ok=true;}
        break;
      }
    }
    if(pass_ok)
    {
      password=pass;
      vaultName=vault_name;
      FocusScope.of(context).unfocus();
      return Navigator.of(context).pop(true);
    }
    else
    {
      Fluttertoast.showToast(
        msg: "Incorrect Password !",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
    //decrypt the files
    //String encrypted_text=aes_obj.encrypt("hello world", "123pass");
    //print("encrypred_text= "+encrypted_text);
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
    List<vaultData> temp_vaultData_list=[];
    widget.vaultDataListViewer.clear();
    for(int a=0;a<widget.vaultDataList.length;a++)
    {
      if(widget.vaultDataList[a].vaultName.contains(searchText) || searchText.length==0)
      { temp_vaultData_list.add(widget.vaultDataList[a]);}
    }
    setState(() {
      widget.vaultDataListViewer=temp_vaultData_list;
    });
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
          child: Text("No", style: Theme
              .of(context)
              .textTheme
              .bodyText1),
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ButtonStyle(overlayColor: MaterialStateProperty.all(Theme
              .of(context)
              .primaryColorDark)),
        );
        Widget continueButton = TextButton(
          child: Text("Yes", style: Theme
              .of(context)
              .textTheme
              .bodyText1,),
          style: ButtonStyle(overlayColor: MaterialStateProperty.all(Theme
              .of(context)
              .primaryColorDark)),
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
          title: Text("Delete Vault", style: Theme
              .of(context)
              .textTheme
              .bodyText1),
          content: Text("Do you want to delete vault '" +
              widget.vaultDataList[itemIndex].vaultName + "' ?", style: Theme
              .of(context)
              .textTheme
              .bodyText2),
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

    Widget hidingIcon()
    {
      if (widget.searchText.length > 0)
      {
        return IconButton
        (
          icon:
          IconButton(
            padding: EdgeInsets.zero,
            icon:Icon(Icons.cancel,color:Theme.of(context).primaryColor),
            onPressed: (){
              widget.search_textfield_controller.clear();
              search("");
              setState(()
              { widget.searchText = "";});
              FocusScope.of(context).unfocus();
            },
          ),
          onPressed: (){},
        );
      }
      else
      { return SizedBox.shrink();}
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
                child:InkWell(
                  splashColor: Theme.of(context).primaryColorDark,
                  child:
                  new TextField(
                    //focusNode: _searchFocusNode,
                    controller: widget.search_textfield_controller,
                    textInputAction: TextInputAction.search,
                    style: Theme.of(context).textTheme.bodyText1,
                    onChanged: (text) {
                      search(text);
                      setState(()
                      { widget.searchText = text;});},
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0x92575757),
                      suffixIcon: hidingIcon(),
                      contentPadding: new EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      hintText: widget.searchHint,
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
                )
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
                        { debugPrint("About");}
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
                child: ListView.builder(
                itemCount: 100,
                itemBuilder: (context,index){
                  return Text("Item $index");
                })),
            ],
          ),
        ),
      ),
      floatingActionButton:  floatingActionButton(tabController: _tabController,add_vault: add_vault,is_vault_open: is_vault_open,closeVault: closeVault,add_files_to_vault: add_files_to_vault)
    );
  }
}