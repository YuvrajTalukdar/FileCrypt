import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutDialogApp
{
  static start(context,Key key)
  {
    showDialog(context: context,
        builder: (context)
        { return aboutDialog(key);}
    );
  }
}

class aboutDialog extends StatefulWidget
{
  aboutDialog(Key key) : super(key: key);

  @override
  DialogContentHolder createState() => DialogContentHolder();
}

class DialogContentHolder extends State<aboutDialog>  {
  var text = new RichText(
    text: new TextSpan(
      style: TextStyle(
        fontSize: 14.0,
        color: Colors.black,
      ),
      children: <TextSpan>[
        TextSpan(text: 'For more information and also help the project: ',style:TextStyle(color:Color(0xff12d586),fontSize: 12)),
        TextSpan(text: 'https://github.com/YuvrajTalukdar/FileCrypt', style: TextStyle(color:Color(0xff00c7d8),fontSize:12,decoration: TextDecoration.underline),
          recognizer: new TapGestureRecognizer()
            ..onTap = () { launch('https://github.com/YuvrajTalukdar/FileCrypt');
            },),
        TextSpan(text: '\nFile Crypt is a Free as in Freedom software for encrypting you files.',style:TextStyle(color:Color(0xff12d586),fontSize: 12)),
        TextSpan(text: 'File Crypt is released under the terms of GNU General Public License v3 (GPLv3): \n',style:TextStyle(color:Color(0xff12d586),fontSize: 12)),
        TextSpan(text: 'https://www.gnu.org/licenses/gpl-3.0.en.html', style: TextStyle(color:Color(0xff00c7d8),fontSize:12,decoration: TextDecoration.underline),
          recognizer: new TapGestureRecognizer()
            ..onTap = () { launch('https://www.gnu.org/licenses/gpl-3.0.en.html');
            },),
      ],
    ),
  );
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
        Container(//height: 350,
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
                  child: Text("About",style:Theme.of(context).textTheme.bodyText2),
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
              SizedBox(height: 10,),
              Image.asset('assets/images/test_icon.png',width: 50,height: 50,),
              SizedBox(height: 10,),
              Text("File Crypt",style:Theme.of(context).textTheme.bodyText2),
              SizedBox(height: 6,),
              Text("Version 1.0",style:TextStyle(color:Color(0xff12d586),fontSize: 12)),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: text,
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
                          Navigator.of(context).pop();
                        },
                        child: Text('OK'),
                        style: ElevatedButton.styleFrom(primary: Theme.of(context).primaryColor,onPrimary: Colors.black)
                    ),
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
