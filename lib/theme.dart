import 'package:flutter/material.dart';

ThemeData get redTheme{
  return ThemeData(
    primaryColor: Color(0xffed3f08),
    primaryColorDark: Color(0xff7e0000),
    backgroundColor: Colors.black,
    scaffoldBackgroundColor: Colors.black,
    textTheme: TextTheme(
        headline1: TextStyle(color:Color(0xffff3535),fontSize: 18),
        bodyText1: TextStyle(color:Color(0xffff0000),fontSize: 18),
        bodyText2: TextStyle(color:Color(0xffed3f08),fontSize: 18)
    ),
  );
}

ThemeData get greenTheme{
  return ThemeData(
    primaryColor: Color(0xff5cef1c),
    primaryColorDark: Color(0x973AC300),
    //highlightColor: Color(0x973AC300),
    splashColor: Color(0x973AC300),
    backgroundColor: Colors.black,
    scaffoldBackgroundColor: Colors.black,
    textTheme: TextTheme(
        headline1: TextStyle(color:Colors.lightGreenAccent,fontSize: 18),
        bodyText1: TextStyle(color:Color(0xff5cef1c),fontSize: 18),
        bodyText2: TextStyle(color:Color(0xffcddc39),fontSize: 18),
    ),
  );
}

ThemeData get pinkTheme{
  return ThemeData(
    primaryColor: Color(0xffff0e60),
    primaryColorDark: Color(0xff9b0538),
    splashColor: Color(0xff9b0538),
    backgroundColor: Colors.black,
    scaffoldBackgroundColor: Colors.black,
    textTheme: TextTheme(
        headline1: TextStyle(color:Color(0xffdb316b),fontSize: 18),
        bodyText1: TextStyle(color:Color(0xffff0e60),fontSize: 18),
        bodyText2: TextStyle(color:Color(0xffe20c2c),fontSize: 18)
    ),
  );
}

ThemeData get greyTheme{
  return ThemeData(
    primaryColor: Color(0xFFFFFFFF),
    primaryColorDark: Color(0xff6b6b6b),
    splashColor: Color(0xff6b6b6b),
    backgroundColor: Colors.black,
    scaffoldBackgroundColor: Colors.black,
    textTheme: TextTheme(
        headline1: TextStyle(color:Color(0xFFD2DBD5),fontSize: 18),
        bodyText1: TextStyle(color:Color(0xFFC9C9C9),fontSize: 18),
        bodyText2: TextStyle(color:Color(0xFFFCFAFA),fontSize: 18)
    ),
  );
}

ThemeData get blueTheme{
  return ThemeData(
      primaryColor: Color(0xff02dac5),
      primaryColorDark: Color(0xff0050d1),
      splashColor: Color(0xff0050d1),
      backgroundColor: Colors.black,
      scaffoldBackgroundColor: Colors.black,
      textTheme: TextTheme(
          headline1: TextStyle(color:Color(0xff4cd6c9),fontSize: 18),
          bodyText1: TextStyle(color:Color(0xff02dac5),fontSize: 18),
          bodyText2: TextStyle(color:Color(0xff66f9b0),fontSize: 18)
      ),
  );
}

ThemeData get violetTheme{
  return ThemeData(
    primaryColor: Color(0xffa865fe),
    primaryColorDark: Color(0xff6d3cc9),
    splashColor: Color(0xffb198db),
    backgroundColor: Colors.black,
    scaffoldBackgroundColor: Colors.black,
    textTheme: TextTheme(
        headline1: TextStyle(color:Color(0xffb29bd4),fontSize: 18),
        bodyText1: TextStyle(color:Color(0xffac5eff),fontSize: 18),
        bodyText2: TextStyle(color:Color(0xffc232ff),fontSize: 18)
    ),
    /*checkboxTheme:  CheckboxThemeData(
      fillColor: MaterialStateColor.resolveWith(
            (states) {
          if (states.contains(MaterialState.selected)) {
            return Color(0xff875cdc); // the color when checkbox is selected;
          }
          return Color(0xff875cdc); //the color when checkbox is unselected;
        },
      ),
    ),*/
  );
}

List<ThemeData> getThemes()
{
  List<ThemeData> themeList=[];
  themeList.add(greenTheme);
  themeList.add(redTheme);
  themeList.add(greyTheme);
  themeList.add(blueTheme);
  themeList.add(violetTheme);
  themeList.add(pinkTheme);

  return themeList;
}