import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class vaultContent
{
  int id=-1;
  String fileName="",encryptedFileName="";
  String encryptedFilePath="";
  int iconCode=-1;
  late Image thumbnail;
  bool selected=false;
}

class vaultContentBackup
{
  int index=0;
  late vaultContent contentBackup;
}

class exploreGrid extends StatefulWidget
{
  exploreGrid(
    { required Key key,
      required this.vaultContentList,
      required this.is_vault_open,
      required this.select_mode,
      required this.selected_items_counter,
      required this.get_selected_mode,
      required this.get_no_of_selected_items
    }) : super(key: key);
  List<vaultContent> vaultContentList;
  final select_mode;
  final get_selected_mode;
  final selected_items_counter;
  final get_no_of_selected_items;
  final is_vault_open;

  @override
  exploreGridWidget createState() => exploreGridWidget();
}

class exploreGridWidget extends State<exploreGrid> {

  var tapPosition;

  void showCustomMenu(int id) {
    final RenderBox overlay = Overlay.of(context)!.context
        .findRenderObject() as RenderBox;
    showMenu(
        position: RelativeRect.fromRect(
            tapPosition & Size(40, 40), Offset.zero & overlay.size),
        items: <PopupMenuEntry>[
          PopupMenuItem(
            value: 0,
            child: Row(
              children: <Widget>[
                Icon(Icons.delete, color: Theme
                    .of(context)
                    .primaryColor),
                SizedBox(width: 8,),
                Text("Delete", style: Theme.of(context).textTheme.bodyText1,),
              ],
            ),
          )
        ],
        context: context,
        color: Colors.grey[850]
    ).then((value) =>
    {
      //widget.delete_vault(id,value.toString())
    });
  }

  void storePosition(TapDownDetails details) {
    tapPosition = details.globalPosition;
  }

  Icon getIcon(int code) {
    if (code == 0)
    { return Icon(Icons.archive, size: 62, color: Theme.of(context).primaryColor,);} //docs
    else if (code == 1)
    { return Icon(Icons.picture_as_pdf, size: 62, color: Theme.of(context).primaryColor,);} //pdf
    else if (code == 2)
    { return Icon(Icons.slideshow, size: 62, color: Theme.of(context).primaryColor,);} //video
    else
    { return Icon(Icons.description, size: 62, color: Theme.of(context).primaryColor,);} //
  }

  void long_press_selected(vaultContent content)
  {
    if(!widget.get_selected_mode())
    {
      widget.select_mode(true);
      widget.selected_items_counter(widget.get_no_of_selected_items()+1,content);
      setState(() {
        content.selected = true;
      });
    }
  }

  void tap_selected(vaultContent content)
  {
    if(content.selected)
    {
      if(widget.get_no_of_selected_items()-1==0)
      { widget.select_mode(false);}
      setState(() {
        content.selected=false;
      });
      widget.selected_items_counter(widget.get_no_of_selected_items()-1,content);
    }
    else
    {
      if(widget.get_selected_mode())
      {
        setState(() {
          content.selected=true;
        });
        widget.selected_items_counter(widget.get_no_of_selected_items()+1,content);
      }
    }
  }

  Widget gridContent(vaultContent content) {
    if (content.iconCode == -1) {
      return Column
      (
        children: <Widget>
        [
          Expanded(
            child:Material(
              color: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              clipBehavior: Clip.hardEdge,
              child:
              Ink.image
              (
                image: content.thumbnail.image,
                fit: BoxFit.cover,
                child: InkWell(
                  onTap: () {
                    tap_selected(content);
                  },
                  onLongPress: (){
                    long_press_selected(content);
                  },
                ),
              )
            ),
          ),
        ]
      );
    }
    else {
      return
      Padding(
        padding: const EdgeInsets.all(5.0),
        child:
        Column
        (
          children: <Widget>
          [
            Expanded(
              child:Row(
                children:<Widget>[
                  Expanded(
                    child:Material(
                      color: Colors.transparent,
                      child: InkWell(
                        child: Column(
                          children: [
                            Expanded(
                              child:getIcon(content.iconCode),
                            ),
                            SizedBox(height: 5,),
                            Text(
                              content.fileName,
                              style:TextStyle(color:Theme.of(context).primaryColor,fontSize:10),
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.fade,
                            )
                          ],
                        ),
                        onTap: () {
                          tap_selected(content);
                        },
                        onLongPress: (){
                          long_press_selected(content);
                        },
                      ),
                    ),
                  )
                ]
              )
            ),
          ]
        )
     );
    }
  }

  @override
  Widget build(BuildContext context) {
    if(widget.vaultContentList.length==0)
    {
      String msg="";
      if(widget.is_vault_open())
      { msg="Vault Empty";}
      else
      { msg="Vault Closed";}
      return
      Center(child: Text(msg, style: Theme.of(context).textTheme.bodyText1,));
    }
    else
    {
      bool selected=false;
      return
      GestureDetector(
        onTapDown: storePosition,
        child:
        Container(
          child: GridView.builder(
            itemCount: widget.vaultContentList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:4,
              crossAxisSpacing:4,
              mainAxisSpacing:4
            ),
            itemBuilder: (context, index) {
              return
              Stack(
                children:<Widget>
                [
                  Container(height: 294,
                    decoration:
                    BoxDecoration
                    (
                      color: Colors.grey[850],
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      border: Border.all(color: widget.vaultContentList[index].selected==false? Colors.transparent : Theme.of(context).primaryColor)
                    ),
                    child:
                    Opacity(
                        opacity: widget.vaultContentList[index].selected==false? 1: 0.5,
                        child: gridContent(widget.vaultContentList[index]),
                    ),
                  ),
                ]
              );

            },
          )
        )
      );
    }
  }
}