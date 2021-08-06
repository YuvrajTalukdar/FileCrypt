import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class VaultOpenDialog
{
  static start(context,Key key,openVault)
  {
    showDialog(context: context,
        builder: (context)
        { return vaultOpenDialog(key,openVault);}
    );
  }
}

class vaultOpenDialog extends StatefulWidget
{
  vaultOpenDialog(Key key,this.openVault) : super(key: key);
  final openVault;

  @override
  DialogContentHolder createState() => DialogContentHolder();
}

class DialogContentHolder extends State<vaultOpenDialog>  {

  String vaultName="";
  var vaultName_textfield_controller = TextEditingController();
  Widget vaultNameClearIcon()
  {
    if (vaultName.length > 0)
    {
      return IconButton
        (
        icon:
        IconButton(
          padding: EdgeInsets.zero,
          icon:Icon(Icons.cancel,color:Theme.of(context).primaryColor),
          onPressed: (){
            vaultName_textfield_controller.clear();
            setState(()
            { vaultName = "";});
            FocusScope.of(context).unfocus();
          },
        ),
        onPressed: (){},
      );
    }
    else
    { return SizedBox.shrink();}
  }

  String vaultPass="";
  var vaultPass_textfield_controller = TextEditingController();
  Widget vaultPassClearIcon()
  {
    if (vaultPass.length > 0)
    {
      return IconButton
        (
        icon:
        IconButton(
          padding: EdgeInsets.zero,
          icon:Icon(Icons.cancel,color:Theme.of(context).primaryColor),
          onPressed: (){
            vaultPass_textfield_controller.clear();
            setState(()
            { vaultPass = "";});
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
        Container(height: 235,
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
            children: <Widget>
            [
              Container
                (
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text("Open Vault",style:Theme.of(context).textTheme.bodyText1),
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
                new TextField
                (
                  controller: vaultName_textfield_controller,
                  //textInputAction: TextInputAction.search,
                  style: Theme.of(context).textTheme.bodyText1,
                  onChanged: (text)
                  {
                    setState(()
                    { vaultName = text;});
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0x92575757),
                    suffixIcon: vaultNameClearIcon(),
                    contentPadding: new EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    hintText: 'Vault Name',
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
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 0,),
                child:
                new TextField
                  (
                  controller: vaultPass_textfield_controller,
                  obscureText:true,
                  style: Theme.of(context).textTheme.bodyText1,
                  onChanged: (text)
                  {
                    setState(()
                    { vaultPass = text;});
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0x92575757),
                    suffixIcon: vaultPassClearIcon(),
                    contentPadding: new EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    hintText: 'Enter Password',
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
                        { },
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
              )
            ],
          ),
        ),
      );
  }
}
