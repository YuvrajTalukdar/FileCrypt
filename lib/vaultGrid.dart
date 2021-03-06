import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class vaultGrid extends StatefulWidget
{
  vaultGrid({required Key key, required this.vaultDataList,required this.delete_vault,required this.openVaultDialog,required this.is_vault_open}) : super(key: key);
  List<vaultData> vaultDataList;
  final delete_vault;
  final openVaultDialog;
  final is_vault_open;

  @override
  vaultGridWidget createState() => vaultGridWidget();
}

class vaultData
{
  int id=-1;
  String vaultName="";
}

class vaultGridWidget extends State<vaultGrid>  {

  var tapPosition;
  void showCustomMenu(int id) {
    final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
    showMenu(
      position: RelativeRect.fromRect(tapPosition & Size(40,40), Offset.zero & overlay.size),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          value: 0,
          child: Row(
            children: <Widget>[
              Icon(Icons.delete,color: Theme.of(context).primaryColor),
              SizedBox(width: 8,),
              Text("Delete",style: Theme.of(context).textTheme.bodyText1,),
            ],
          ),
        )
      ],
      context: context,
      color: Colors.grey[850]
    ).then((value) =>
    {
      widget.delete_vault(id,value.toString())
    });
  }

  void storePosition(TapDownDetails details) {
    tapPosition = details.globalPosition;
  }

  Widget body()
  {
    if(widget.vaultDataList.length==0)
    {
      return Center(child: Text("No vault present", style: Theme.of(context).textTheme.bodyText1,));
    }
    else
    {
      return Container(
          child: GridView.builder(
            itemCount: widget.vaultDataList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:3,
            ),
            itemBuilder: (context,index){
              return
                Container(height: 294,
                  decoration:
                  BoxDecoration
                    (
                      color: Colors.black,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(12))
                  ),
                  child:
                  Column
                    (
                      children: <Widget>
                      [
                        MaterialButton(
                          child: Icon(Icons.snippet_folder_rounded,size:100,color: Theme.of(context).primaryColor,),
                          elevation: 1.0,
                          shape: CircleBorder(),
                          splashColor: Theme.of(context).primaryColorDark,
                          onPressed: () {widget.openVaultDialog(widget.vaultDataList[index].id,widget.vaultDataList[index].vaultName);},
                          onLongPress: ()
                          {
                            if(widget.is_vault_open())
                            {
                              Fluttertoast.showToast(
                                msg: "Lock all open vaults first.",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                              );
                            }
                            else
                            { showCustomMenu(widget.vaultDataList[index].id);}
                          },
                        ),
                        Text(widget.vaultDataList[index].vaultName,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                        )
                      ]
                  ),
                );
            },
          )
      );
    }
  }
  @override
  Widget build(BuildContext context)
  {
    return
      GestureDetector(
        onTapDown: storePosition,
        child:
        body()
      );
  }
}