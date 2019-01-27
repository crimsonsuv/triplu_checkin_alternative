import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../utils/colors.dart';
import '../../utils/assets.dart';
import '../../utils/extensions.dart';
import '../../services/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/check_credentials.dart';
import '../../utils/rounded_dialogs.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController _controller = new TextEditingController();

  final apiCall = new BehaviorSubject<bool>(seedValue: false);
  final apiKey = new BehaviorSubject<String>(seedValue: '');

  @override
  void dispose() async{
    super.dispose();
    await apiCall.drain();
    apiCall.close();
    await apiKey.drain();
    apiKey.close();
  }

  void _showAlert(BuildContext context, String title, String body) {

    showDialog( context: context,
        builder: (context) => CustomAlertDialog(
          title: Text(title, textAlign: TextAlign.center,),
          content: Text(body, textAlign: TextAlign.center,),
          actions: <Widget>[
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text('CLOSE', style: textStyle(kColor_green_theme, FontWeight.normal, 14),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            ),
          ],
        )
    );
  }


  void _checkCredential(String url){
    apiCall.add(true);
    checkCredential(url, context).then((CheckCredentials data){
      apiCall.add(false);
      if (data.pass) {
        SharedPreferences.getInstance().then((prefs){
          prefs.setString('api_key', apiKey.value);
          Navigator.pushNamed(context, "/Home");
          _controller.text = '';
          apiKey.add('');
        });
      } else {
        _showAlert(context, 'Authentication Failure', 'Your API key is invalid');
        apiKey.add('');
        _controller.text = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      body: Center(
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: new ConstrainedBox(
              constraints: BoxConstraints.expand(height: MediaQuery.of(context).size.height),
              child: new Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Image.asset(
                        login_bg,
                        fit: BoxFit.cover,
                      )),
                  Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        color: Colors.black26,
                      )),
                  Positioned(
                      top: 100,
                      child: Center(
                          child: Image.asset(
                            ic_logo,
                            fit: BoxFit.cover,
                            height: 80,
                          ))),
                  Positioned(
                    bottom: 80,
                    left: 60,
                    right: 60,
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Enter provided API key',
                          style: textStyle(Colors.white, FontWeight.w400, 18),
                        ),
                        Padding(padding: EdgeInsets.only(bottom: 20)),
                        new Container(
                          alignment: Alignment.centerLeft,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: new Row(
                            children: <Widget>[
                              new Expanded(
                                child: TextField(
                                  onChanged: (value){
                                    return apiKey.add(value);
                                  },
                                  controller: _controller,
                                  autocorrect: false,
                                  style: textStyle(Colors.white,
                                      FontWeight.w500, 16),
                                  decoration: new InputDecoration(
                                    hintText: 'API KEY',
                                    hintStyle: textStyle(Colors.white54,
                                        FontWeight.w600, 14),
                                    border: InputBorder.none,
                                    contentPadding:
                                    const EdgeInsets.all(10.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(bottom: 50)),
                        GestureDetector(
                          onTap: (){
                            String url = "https://www.triply.fun/tc-api/${apiKey.value}/check_credentials";
                            if(apiKey.value !='' && !apiCall.value){
                              return _checkCredential(url);
                            } else return;
                          },
                          child: StreamBuilder(
                              initialData: false,
                              stream: apiCall,
                              builder: (context, snapshot){
                                return Container(
                                  alignment: Alignment.center,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: kColor_green_theme,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: (!apiCall.value) ? Text(
                                    'SIGN IN',
                                    style:
                                    textStyle(Colors.white, FontWeight.normal, 15),
                                    textAlign: TextAlign.center,
                                  ) : CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                );
                              }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
