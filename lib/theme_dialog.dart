import 'package:flutter/material.dart';
import 'package:stacked_themes/stacked_themes.dart';

int? themeCode=0;

class ThemeDialog
{
  static start(context) => showDialog(context: context, builder: (context) => CreateThemeDialog());
}

class CreateThemeDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: DialogContent(key:Key(''),title: 'File Crypt'),
    );
  }
}

class DialogContent extends StatefulWidget
{
  DialogContent({required Key key, required this.title}) : super(key: key);
  final String title;

  @override
  DialogContentHolder createState() => DialogContentHolder();
}

class DialogContentHolder extends State<DialogContent>  {
  bool? green=false,red=false,grey=false,blue=false,violet=false,pink=false;
  DialogContentHolder()
  {
    if(themeCode==0)
    { green=true;}
    else if(themeCode==1)
    { red=true;}
    else if(themeCode==2)
    { grey=true;}
    else if(themeCode==3)
    { blue=true;}
    else if(themeCode==4)
    { violet=true;}
    else if(themeCode==5)
    { pink=true;}
  }

  @override
  Widget build(BuildContext context)
  {
    return
      Container(height: 245,
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
                child: Text("Select Theme"),
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
              Row
                (
                mainAxisSize: MainAxisSize.min,
                //crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>
                [
                  Expanded(
                    child:Container
                      (
                      child: Padding(
                        padding: const EdgeInsets.all(0),
                        child:

                        CheckboxListTile
                          (
                            value: green,
                            onChanged: (value) {
                              setState(() {
                                green = value;
                                red=false;
                                grey=false;
                                blue=false;
                                violet=false;
                                pink=false;
                                getThemeManager(context).selectThemeAtIndex(0);
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
                          ),
                      ),
                      width: double.infinity,
                      decoration:
                      BoxDecoration
                      (
                          color: Color(0xff5cef1c),
                          shape: BoxShape.rectangle,
                          borderRadius:
                          BorderRadius.only
                          (
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12)
                          )
                      ),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child:Container
                      (
                      child: Padding(
                        padding: const EdgeInsets.all(0),
                        child: CheckboxListTile
                          (
                          value: red,
                          onChanged: (value) {
                            setState(() {
                              green=false;
                              red=value;
                              grey=false;
                              blue=false;
                              violet=false;
                              pink=false;
                              getThemeManager(context).selectThemeAtIndex(1);
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
                        ),
                      ),
                      width: double.infinity,
                      decoration:
                      BoxDecoration
                        (
                          color: Color(0xffed3f08),
                          shape: BoxShape.rectangle,
                          borderRadius:
                          BorderRadius.only
                            (
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12)
                          )
                      ),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child:Container
                      (
                      child: Padding(
                        padding: const EdgeInsets.all(0),
                        child: CheckboxListTile
                          (
                          value: grey,
                          onChanged: (value) {
                            setState(() {
                              green=false;
                              red=false;
                              grey=value;
                              blue=false;
                              violet=false;
                              pink=false;
                              getThemeManager(context).selectThemeAtIndex(2);
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
                        ),
                      ),
                      width: double.infinity,
                      decoration:
                      BoxDecoration
                        (
                          color: Color(0x92FFF7F7),
                          shape: BoxShape.rectangle,
                          borderRadius:
                          BorderRadius.only
                            (
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12)
                          )
                      ),
                    ),
                  ),
                ],
              )
            ),

            Padding(
              padding: const EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 0,),
              child:
              Row
              (
                mainAxisSize: MainAxisSize.min,
                //crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>
                [
                  Expanded(
                    child:Container
                    (
                      child: Padding(
                        padding: const EdgeInsets.all(0),
                        child: CheckboxListTile
                          (
                          value: blue,
                          onChanged: (value) {
                            setState(() {
                              green=false;
                              red=false;
                              grey=false;
                              blue=value;
                              violet=false;
                              pink=false;
                              getThemeManager(context).selectThemeAtIndex(3);
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
                        ),
                      ),
                      width: double.infinity,
                      decoration:
                      BoxDecoration
                        (
                          color: Color(0xff02dac5),
                          shape: BoxShape.rectangle,
                          borderRadius:
                          BorderRadius.only
                            (
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12)
                          )
                      ),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child:Container
                    (
                      child: Padding(
                        padding: const EdgeInsets.all(0),
                        child: CheckboxListTile
                          (
                          // title: Text("title text"),
                          value: violet,
                          onChanged: (value) {
                            setState(() {
                              green=false;
                              red=false;
                              grey=false;
                              blue=false;
                              violet=value;
                              pink=false;
                              getThemeManager(context).selectThemeAtIndex(4);
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
                        ),
                      ),
                      width: double.infinity,
                      decoration:
                      BoxDecoration
                      (
                          color: Color(0xff6738b9),
                          shape: BoxShape.rectangle,
                          borderRadius:
                          BorderRadius.only
                            (
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12)
                          )
                      ),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child:Container
                    (
                      child: Padding(
                        padding: const EdgeInsets.all(0),
                        child: CheckboxListTile
                          (
                          value: pink,
                          onChanged: (value) {
                            setState(() {
                              green=false;
                              red=false;
                              grey=false;
                              blue=false;
                              violet=false;
                              pink=value;
                              getThemeManager(context).selectThemeAtIndex(5);
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
                        ),
                      ),
                      width: double.infinity,
                      decoration:
                      BoxDecoration
                        (
                          color: Color(0xffff0e60),
                          shape: BoxShape.rectangle,
                          borderRadius:
                          BorderRadius.only
                            (
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12)
                          )
                      ),
                    ),
                  ),
                ],
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
                  ElevatedButton(
                      onPressed: ()
                      { Navigator.of(context).pop();},
                      child: Text('OK'),
                      style: ElevatedButton.styleFrom(primary: Theme.of(context).primaryColor,onPrimary: Colors.black)
                  ),
                ),
                SizedBox(width: 10,),
              ],
            )
          ],
        ),
      );
  }
}
