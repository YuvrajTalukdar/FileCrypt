import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewer extends StatefulWidget {
  ImageViewer({required Key key,required this.imageName,required this.image}) : super(key: key);
  String imageName;
  Image image;

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<ImageViewer> with TickerProviderStateMixin {
  bool visible=true;
  bool backButtonEnable=true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    //PaintingBinding.instance!.imageCache!.clear();
    //PaintingBinding.instance!.imageCache!.clearLiveImages();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AnimatedOpacity(
          onEnd: (){
            if(!visible)
            {
              //SystemChrome.setEnabledSystemUIOverlays([]);//status bar
              setState(() {
                backButtonEnable=false;
              });
            }

          },
          opacity: visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 100),
          child: AppBar(
            iconTheme: IconThemeData(
              color: Theme.of(context).primaryColor,
            ),
            automaticallyImplyLeading: backButtonEnable,
            title: Text(widget.imageName,style:Theme.of(context).textTheme.bodyText1),
            backgroundColor: Colors.transparent,
          ),
        ),
      ),
      body: Center(
        child:GestureDetector(
          onTap: ()
          {
            if(!visible)
            {
              //SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
              setState(() {
                backButtonEnable=true;
              });
            }
            setState(() {
              visible=!visible;
            });
          },
          child: Container(
              child: PhotoView(
                imageProvider: widget.image.image,
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 1.8,
              )
          )
        )
      ),
    );
  }
}