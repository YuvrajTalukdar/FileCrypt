import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:filecrypt/create_vault_dialog.dart';


class CircularButton extends StatelessWidget {

  final double width;
  final double height;
  final Color color;
  final Icon icon;
  final VoidCallback onClick;

  CircularButton({required this.color, required this.width, required this.height, required this.icon, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: color,shape: BoxShape.circle),
      width: width,
      height: height,
      child: IconButton(icon: icon,enableFeedback: true, onPressed: onClick),
    );
  }
}

class floatingActionButton extends StatefulWidget {
  @override
  floatingActionButton({required this.tabController,required this.add_vault,required this.is_vault_open,required this.closeVault,required this.pick_files});
  floatingActionButtonHolder createState() => floatingActionButtonHolder();
  final tabController;
  final add_vault;
  final is_vault_open;
  final closeVault;
  final pick_files;
}

class floatingActionButtonHolder extends State<floatingActionButton> with TickerProviderStateMixin {

  late AnimationController animationController;
  late Animation degOneTranslationAnimation,degTwoTranslationAnimation,degThreeTranslationAnimation;
  late Animation rotationAnimation;
  bool FABTextVisible=false;

  double getRadiansFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(vsync: this,duration: Duration(milliseconds: 250));
    degOneTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(tween: Tween<double >(begin: 0.0,end: 1.2), weight: 75.0),
      TweenSequenceItem<double>(tween: Tween<double>(begin: 1.2,end: 1.0), weight: 25.0),
    ]).animate(animationController);
    degTwoTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(tween: Tween<double >(begin: 0.0,end: 1.4), weight: 55.0),
      TweenSequenceItem<double>(tween: Tween<double>(begin: 1.4,end: 1.0), weight: 45.0),
    ]).animate(animationController);
    degThreeTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(tween: Tween<double >(begin: 0.0,end: 1.75), weight: 35.0),
      TweenSequenceItem<double>(tween: Tween<double>(begin: 1.75,end: 1.0), weight: 65.0),
    ]).animate(animationController);
    rotationAnimation = Tween<double>(begin: 0.0,end: 40.0).animate(CurvedAnimation(parent: animationController
        , curve: Curves.easeOut));
    super.initState();
    animationController.addListener((){
      setState(() {

      });
    });

    handleTabSelection();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
  int tab_index=0;
  handleTabSelection()
  {
    widget.tabController.addListener(() {
      if (animationController.isCompleted)
      {
        animationController.reverse();
        setState(() {
          FABTextVisible=false;
        });
      }
    });
  }

  void add_file_folder() async
  { widget.pick_files();}

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: <Widget>
        [
          Positioned(
              right: 10,
              bottom: 10,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: <Widget>[
                  IgnorePointer(
                    child: Container(
                      color: Colors.transparent,
                      height: 150.0,
                      width: 150.0,
                    ),
                  ),
                  Transform.translate(
                    offset: Offset.fromDirection(getRadiansFromDegree(270),degOneTranslationAnimation.value * 70),
                    child:Row(
                      children: [
                        AnimatedOpacity(
                          opacity: FABTextVisible ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 250),
                          // The green box must be a child of the AnimatedOpacity widget.
                          child: Container(
                            child: Text("Add Files",style: Theme.of(context).textTheme.bodyText1,),
                            padding: const EdgeInsets.fromLTRB(8, 7, 6, 5),
                            decoration: new BoxDecoration(
                                color:  Colors.grey[850],
                                borderRadius:BorderRadius.all(Radius.circular(50.0))
                            ),
                          ),
                        ),
                        SizedBox(width: 15,),
                        CircularButton(
                          color:Theme.of(context).primaryColor,
                          width: 50,
                          height: 50,
                          icon: Icon(
                            Icons.note_add,
                            color: Colors.black,
                          ),
                          onClick: (){
                            animationController.reverse();
                            setState(() {
                              FABTextVisible = false;
                            });
                            add_file_folder();
                          },
                        ),
                      ],
                    ),
                  ),
                  IgnorePointer(
                    child: Container(
                      color: Colors.transparent,
                      height: 200.0,
                      width: 150.0,
                    ),
                  ),
                  Transform.translate(
                    offset: Offset.fromDirection(getRadiansFromDegree(270),degTwoTranslationAnimation.value * 135),
                    child: Row(
                      children: [
                        AnimatedOpacity(
                          opacity: FABTextVisible ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 250),
                          // The green box must be a child of the AnimatedOpacity widget.
                          child: Container(
                            child: Text("Lock Archive",style: Theme.of(context).textTheme.bodyText1,),
                            padding: const EdgeInsets.fromLTRB(8, 7, 6, 5),
                            decoration: new BoxDecoration(
                                color:  Colors.grey[850],
                                borderRadius:BorderRadius.all(Radius.circular(50.0))
                            ),
                          ),
                        ),
                        SizedBox(width: 15,),
                        CircularButton(
                          color: Theme.of(context).primaryColor,
                          width: 50,
                          height: 50,
                          icon: Icon(
                            Icons.lock,
                            color: Colors.black,
                          ),
                          onClick: (){
                            widget.closeVault();
                            animationController.reverse();
                            setState(() {
                              FABTextVisible = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Transform(
                    transform: Matrix4.rotationZ(getRadiansFromDegree(rotationAnimation.value)),
                    alignment: Alignment.center,
                    child:FloatingActionButton(
                      child:Icon(Icons.add,color:Colors.black),
                      onPressed: ()
                      {
                        if(widget.tabController.index==0)
                        {
                          if(animationController.isCompleted)
                          { animationController.reverse();}
                          return  VaultDialog.start(context,new Key(""),widget.add_vault);
                        }
                        else
                        {
                          if (widget.is_vault_open())
                          {
                            if (animationController.isCompleted)
                            {
                              animationController.reverse();
                              setState(() {
                                FABTextVisible = false;
                              });
                            }
                            else
                            {
                              animationController.forward();
                              setState(() {
                                FABTextVisible = true;
                              });
                            }
                          }
                          else
                          {
                            Fluttertoast.showToast(
                              msg: "Open a vault first",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                            );
                          }
                        }
                      },
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                  )
                ],
              )
          )
        ]
    );
  }
}
