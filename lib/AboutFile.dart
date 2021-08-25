import 'package:flutter/material.dart';

class AboutFilenDialog
{
  static start(context,Key key,double fileSize,DateTime dateTime,String fileName)
  {
    showDialog(context: context,
        builder: (context)
        { return aboutFilenDialog(key,fileSize,dateTime,fileName);}
    );
  }
}

class aboutFilenDialog extends StatefulWidget
{
  aboutFilenDialog(Key key,this.fileSize,this.dateTime,this.fileName) : super(key: key);
  double fileSize;
  String fileName;
  DateTime dateTime;

  @override
  DialogContentHolder createState() => DialogContentHolder();
}

class DialogContentHolder extends State<aboutFilenDialog>  {

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
        Container(//height: 310,
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
                  child: Text("Details",style:Theme.of(context).textTheme.bodyText1),
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
                Row(
                  children:<Widget>
                  [
                    Container(
                        constraints: BoxConstraints(minWidth: 100, maxWidth: 100),
                        child: RichText(text: TextSpan(text:"File Name",style: Theme.of(context).textTheme.bodyText2,),)
                    ),
                    SizedBox(width: 10,),
                    Expanded(
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
                                  text: TextSpan(text: widget.fileName,style: Theme.of(context).textTheme.bodyText1,),
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
                    )
                  ]
                )
              ),
              SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 0,),
                child:
                Row(
                  children:<Widget>
                  [
                    Container(
                        constraints: BoxConstraints(minWidth: 100, maxWidth: 100),
                        child: RichText(text: TextSpan(text:"File Size",style: Theme.of(context).textTheme.bodyText2,),)
                    ),
                    SizedBox(width: 10,),
                    Expanded(
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
                              text: TextSpan(text: (widget.fileSize/(1048576)).toStringAsFixed(3)+" MB",style: Theme.of(context).textTheme.bodyText1,),
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
                    )
                  ]
                )
              ),
              SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 0,),
                child:
                Row(
                  children:<Widget>
                  [
                    Container(
                        constraints: BoxConstraints(minWidth: 100, maxWidth: 100),
                        child: RichText(text: TextSpan(text:"Import Date",style: Theme.of(context).textTheme.bodyText2,),)
                    ),
                    SizedBox(width: 10,),
                    Expanded(
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
                                text: TextSpan(text:widget.dateTime.day.toString()+"/"+widget.dateTime.month.toString()+"/"+widget.dateTime.year.toString(),style: Theme.of(context).textTheme.bodyText1,),
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
                    )
                  ]
                )
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
                      ElevatedButton
                        (
                        onPressed: ()
                        {
                          FocusScope.of(context).unfocus();
                          return Navigator.of(context).pop(true);
                        },
                        child: Text('OK'),
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
