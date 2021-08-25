import 'package:flutter/material.dart';
import 'package:filecrypt/exploreGrid.dart';

class FileRenameDialog
{
  static start(context,Key key,rename_file,vaultContent content)
  {
    showDialog(context: context,
        builder: (context)
        { return fileRenameDialog(key,rename_file,content);}
    );
  }
}

class fileRenameDialog extends StatefulWidget
{
  fileRenameDialog(Key key,this.rename_file,this.content) : super(key: key);
  final rename_file;
  vaultContent content;

  @override
  DialogContentHolder createState() => DialogContentHolder();
}

class DialogContentHolder extends State<fileRenameDialog>  {

  String newName="";
  var newName_textfield_controller = TextEditingController();
  Widget vaultPassClearIcon()
  {
    if (newName.length > 0)
    {
      return IconButton
        (
        icon:
        IconButton(
          padding: EdgeInsets.zero,
          icon:Icon(Icons.cancel,color:Theme.of(context).primaryColor),
          onPressed: (){
            newName_textfield_controller.clear();
            setState(()
            { newName = "";});
            FocusScope.of(context).unfocus();
          },
        ),
        onPressed: (){},
      );
    }
    else
    { return SizedBox.shrink();}
  }

  @override
  Widget build(BuildContext context)
  {
    return
      Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child:
        Container(//height: 235,
          decoration:
          BoxDecoration
            (
              color: Colors.grey[800],
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(12))
          ),
          child:
          Column
            (
            mainAxisSize: MainAxisSize.min,
            children: <Widget>
            [
              Container
                (
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text("Rename File",style:Theme.of(context).textTheme.bodyText1),
                ),
                width: double.infinity,
                decoration:
                BoxDecoration
                  (
                    color: Colors.grey[900],
                    shape: BoxShape.rectangle,
                    borderRadius:
                    BorderRadius.only
                      (
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12)
                    )
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 0,),
                child:
                Container(
                  child:
                  Center(
                    child:
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 15, 0, 10),
                      child:
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,//.horizontal
                        child:RichText(
                          text: TextSpan(text: widget.content.fileName,style: Theme.of(context).textTheme.bodyText1,),
                        ),
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    border: Border.all(
                      color: Theme.of(context).primaryColorDark,
                    ),
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 0,),
                child:
                new TextField
                  (
                  controller: newName_textfield_controller,
                  style: Theme.of(context).textTheme.bodyText1,
                  onChanged: (text)
                  {
                    setState(()
                    { newName = text;});
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0x92575757),
                    suffixIcon: vaultPassClearIcon(),
                    contentPadding: new EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    hintText: 'Enter New Name',
                    hintStyle: Theme.of(context).textTheme.bodyText2,
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).primaryColorDark),
                        borderRadius: BorderRadius.all(Radius.circular(90.0))
                    ),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).primaryColor),
                        borderRadius: BorderRadius.all(Radius.circular(90.0))
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Row
                (
                mainAxisSize: MainAxisSize.min,
                //crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>
                [
                  SizedBox(width: 10,),
                  Expanded(
                    child:
                    ElevatedButton(
                        onPressed: ()
                        {
                          widget.rename_file(widget.content,newName);
                          return Navigator.of(context).pop(true);
                        },
                        child: Text('OK'),
                        style: ElevatedButton.styleFrom(primary: Theme.of(context).primaryColor,onPrimary: Colors.black)
                    ),
                  ),
                  SizedBox(width: 8,),
                  Expanded(
                      child:
                      ElevatedButton
                        (
                        onPressed: ()
                        {
                          FocusScope.of(context).unfocus();
                          return Navigator.of(context).pop(true);
                        },
                        child: Text('CANCEL'),
                        style: ElevatedButton.styleFrom(primary: Theme.of(context).primaryColor,onPrimary: Colors.black),

                      )
                  ),
                  SizedBox(width: 10,),
                ],
              ),
              SizedBox(height: 10,),
            ],
          ),
        ),
      );
  }
}
