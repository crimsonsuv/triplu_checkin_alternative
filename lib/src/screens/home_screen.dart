import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/assets.dart';
import 'list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        color: kColor_white,
        child: SafeArea(
          child: DefaultTabController(
            initialIndex: 0,
            length: 5,
            child: new Scaffold(
              backgroundColor: kColor_white,
              body: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                children: [
                  new ListScreen(),
                ],
              ),
              floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
              floatingActionButton: Container(
                margin: EdgeInsets.only(top: 30),
                decoration: BoxDecoration(
                  //borderRadius: BorderRadius.circular(80)
                    color: Colors.transparent
                ),
                height: 110.0,
                width: 65.0,
                child: FittedBox(
                  child: FloatingActionButton(onPressed: () => Navigator.pushNamed(context, '/Scanning'),
                    backgroundColor: kColor_white,
                    child: Container(
                      margin: EdgeInsets.all(0),
                      padding: EdgeInsets.all(0),
                      constraints: BoxConstraints.expand(),
                      decoration: BoxDecoration(
                        color: kColor_green_theme,
                        borderRadius: BorderRadius.circular(78),
                      ),
                      child: Image.asset(ic_scan, fit: BoxFit.cover, height: 30, width: 30,),
                    ),
                  ),
                ),
              ),
              bottomNavigationBar: Container(
                height: 58,
                decoration: BoxDecoration(
                    color: kColor_white,
                    boxShadow: [BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0, -20),
                      spreadRadius: 1,
                      blurRadius:  20,
                    )]
                ),
                child: new TabBar(
                  tabs: [
                    Tab(
                      icon: Container(
                        child: FittedBox(child: ImageIcon(AssetImage(ic_listIcon)), fit: BoxFit.cover,),
                        height: 30,
                        width: 30,
                      ),
                    ),
                    Tab(
                      icon: Container(
                        child: null,
                        height: 30,
                        width: 30,
                      ),
                    ),
                    Tab(
                      icon: GestureDetector(
                        onTap: (){
                          SharedPreferences.getInstance().then((prefs){
                            prefs.setString('api_key', '');
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          child: FittedBox(child: ImageIcon(AssetImage(ic_logout)), fit: BoxFit.cover,),
                          height: 30,
                          width: 30,
                        ),
                      ),
                    )
                  ],
                  labelColor: kColor_dark_text,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorPadding: EdgeInsets.all(0.0),
                  labelStyle: TextStyle(fontSize: 10),
                  labelPadding: EdgeInsets.only(top: 0, bottom: 0),
                  indicatorColor: Colors.transparent,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
