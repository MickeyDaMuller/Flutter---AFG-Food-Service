import 'package:afg_service/select_location.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' show Client;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();
int myInt;
String _email = '';
String _fullname = '';
String _id;
bool _isEnabled = false;

class MyLoginPage extends StatefulWidget {
  MyLoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyLoginPageState createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {
  TextStyle style =
      TextStyle(fontFamily: 'Montserrat', fontSize: 15.0, color: Colors.white);
  final _formKey = GlobalKey<FormState>();
  String textValue = 'Hello World !';
  final FocusNode _nodeText1 = FocusNode();
  final FocusNode _nodeText2 = FocusNode();
  SharedPreferences sharedPreferences;

  bool _isLoading = false;
  var response;
  bool _isFieldPassValid;
  bool _isFieldEmailValid;
  bool _isFieldAgeValid;
  TextEditingController _controllerPassPhrase = TextEditingController();
  TextEditingController _controllerEmail = TextEditingController();
  bool _autoValidate = false;

  @override
  void initState() {
    super.initState();
  }



  String password;
  String email;

  String validatePassPhrase(String value) {
    if (value.length < 3)
      return 'Name must be more than 2 charater';
    else
      return null;
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
  }

  @override
  Widget build(BuildContext context) {
    final emailField = TextFormField(
      validator: validateEmail,
      onSaved: (String val) {
        email = val;
      },
      autovalidate: _autoValidate,
      obscureText: false,
      focusNode: _nodeText1,
      controller: _controllerEmail,
      keyboardType: TextInputType.emailAddress,
      style: style,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        //hintText: "Fullname",
        labelText: "User Email",
        labelStyle: new TextStyle(color: Colors.white),
        hintStyle: new TextStyle(color: Colors.white),
        //suffixText: '@',
        prefixIcon: const Icon(
          Icons.email,
          color: Colors.white,
        ),
        errorText: _isFieldEmailValid == null || _isFieldEmailValid
            ? null
            : "User email is required",
        errorStyle: TextStyle(
          color: Colors.blue,
        ),
        enabledBorder: const OutlineInputBorder(
          // width: 0.0 produces a thin "hairline" border
          borderSide: const BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        // border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: const BorderSide(color: Colors.white)),
      ),
      /*onChanged: (value) {
        bool isFieldValid = value.trim().isNotEmpty;
        if (isFieldValid != _isFieldNameValid) {
          setState(() => _isFieldNameValid = isFieldValid);
        }
      },*/
    );
    final passPhraseField = TextFormField(
      obscureText: true,
      style: style,
      autovalidate: _autoValidate,
      //autovalidate: true,
      validator: validatePassPhrase,
      onSaved: (String val) {
        email = val;
      },
      controller: _controllerPassPhrase,
      focusNode: _nodeText2,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        labelText: "Pass Phrase",
        prefixText: ' ',
        labelStyle: new TextStyle(color: Colors.white),
        hintStyle: new TextStyle(color: Colors.white),
        prefixIcon: const Icon(
          Icons.vpn_key,
          color: Colors.white,
        ),
        errorText: _isFieldPassValid == null || _isFieldPassValid
            ? null
            : "pass phrase is required",
        errorStyle: TextStyle(
          color: Colors.blue,
        ),
        enabledBorder: const OutlineInputBorder(
          // width: 0.0 produces a thin "hairline" border
          borderSide: const BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
      /*onChanged: (value) {
        bool isFieldValid = value.trim().isNotEmpty;
        if (isFieldValid != _isFieldEmailValid) {
          setState(() => _isFieldEmailValid = isFieldValid);
        }
      },*/
    );

    final String baseUrl = "https://service.afgfood.com/api/loginJSON.aspx";
    var response;
    Client client = Client();

    Future<bool> createProfile(LoginProfile data) async {
      response = await client.post(
        "$baseUrl",
        headers: {"content-type": "application/json"},
        body: loginProfileToJson(data),
      );
      String respond = response.body;
      debugPrint("loginres:$respond");

      if (response.statusCode == 201) {
        return true;
      } else {
        String respo = response.body;
        debugPrint("elseres:$respo");
        print(response.body);

        showDialog(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text('Login Error!'),
                content: Text('Oops! One or more of your login credential not valid.'),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Close',
                        style: TextStyle(color: Colors.blue),
                      )),
                ],
              );
            });


        //debugPrint("login now:$response.body");
        //return false;
      }
    }

    final loginButon = Material(
      elevation: 3.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Colors.white,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          //prefs.setInt('id', res);
          prefs.setString('email', email);
          prefs.setString('sharepass', password);
          setState(() => _isLoading = true);
          //Dialogs.showLoadingDialog(context, _scaffoldState);//invoking login
          _autoValidate = true;

          if (_formKey.currentState.validate()) {
            setState(() => _isLoading = true);
            password = _controllerPassPhrase.text.toString();
            email = _controllerEmail.text.toString();

            try {
              final result = await InternetAddress.lookup('google.com');
              if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                print('connected');

                LoginProfile profile = LoginProfile(
                  email: email,
                  password: password,

                );

                print("$profile");
                debugPrint("logger:$profile");

                createProfile(profile).then((isSuccess) async {
                  setState(() => _isLoading = false);
                  debugPrint("response:$response");
                  print(response.body);
                  int res = int.parse(response.body);
                 // SystemChrome.setEnabledSystemUIOverlays([]);
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setInt('id', res);
                  prefs.setString('email', email);
                  prefs.setString('password', password);

                  Navigator.popUntil(context, (_) => !Navigator.canPop(context));

                  Navigator.of(context)
                        .pushReplacement(new AnimationPageRoute());
                    //SystemChrome.setEnabledSystemUIOverlays([]);

                 /* Navigator.pushReplacement(
                      context, new CupertinoPageRoute(builder: (BuildContext context) => SelectLocationPage()));

                  SystemChrome.setEnabledSystemUIOverlays([]);*/

                });
              }
            } on SocketException catch (_) {
              print('not connected');
              setState(() => _isLoading = false);

              //debugPrint("No internet:");

              showDialog(
                  context: context,
                  builder: (context) {
                    return CupertinoAlertDialog(
                      title: Text('Internet Error!'),
                      content: Text('Check your internet connection.'),
                      actions: <Widget>[
                        FlatButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Close', style: TextStyle(color: Colors.blue),
                            )),
                      ],
                    );
                  });
            }

            // return;
          } else {
            setState(() => _isLoading = false);

            _scaffoldState.currentState.showSnackBar(
              SnackBar(
                content: Text(
                  "Please fill all fields",
                  textAlign: TextAlign.center,
                ),
              ),
            );

            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return CupertinoAlertDialog(
                    //backgroundColor: Colors.white,
                    title: Text(
                      'Login Error!',
                    ),
                    content: Text(
                      'Please fill all fields',
                    ),
                    actions: <Widget>[
                      FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Close',
                            style: TextStyle(color: Colors.blue),
                          )),
                    ],
                  );
                });
          }
        },
        child: Text(
          "Login",
          style: TextStyle(
            color: Colors.red,
          ),
        ),
      ),
    );

    Size size = MediaQuery.of(context).size;

    return WillPopScope(
        onWillPop: () =>
            SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
        // this is use to keep the app in background

        child: Scaffold(
          key: _scaffoldState,
          body: Stack(
            //padding: EdgeInsets.only(top: 30.0, left: 10.0, right: 10.0),
            // child: ListView(
            children: <Widget>[
              Center(
                child: new Image.asset(
                  'assets/red_background.jpg',
                  width: size.width,
                  height: size.height,
                  fit: BoxFit.fill,
                ),
              ),
              Form(
                key: _formKey,
                //color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ListView(
                    //crossAxisAlignment: CrossAxisAlignment.center,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 50.0),
                      SizedBox(
                        height: 200.0,
                        child: Image.asset(
                          "assets/afg_logo.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(
                          //height: 155.0,
                          child: Text(
                              "FOOD EQUIPMENT \n LOGISTICS, PARTS & SERVICE",
                              style: TextStyle(
                                  fontSize: 20.0,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              textAlign: TextAlign.center)),
                      SizedBox(height: 45.0),
                      emailField,
                      SizedBox(height: 25.0),
                      passPhraseField,
                      SizedBox(
                        height: 35.0,
                      ),
                      loginButon,
                      SizedBox(
                        height: 15.0,
                      ),
                    ],
                  ),
                ),
              ),
              _isLoading
                  ? Stack(
                      children: <Widget>[
                        Opacity(
                          opacity: 0.3,
                          child: ModalBarrier(
                            dismissible: false,
                            color: Colors.grey,
                          ),
                        ),
                        Center(
                          child: CircularProgressIndicator(),
                        ),
                      ],
                    )
                  : Container(),
            ],
            // ),
          ),
        ));
  }
}

class AnimationPageRoute extends CupertinoPageRoute {
  AnimationPageRoute()
      : super(builder: (BuildContext context) => new SelectLocationPage());

  // OPTIONAL IF YOU WISH TO HAVE SOME EXTRA ANIMATION WHILE ROUTING
  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return new FadeTransition(
        opacity: animation,
        child: new ScaleTransition(
          scale: animation,
          child: new FadeTransition(
            opacity: animation,
            child: new SelectLocationPage(),
          ),
        ));
  }
}

// class connecting value from the textfield to database with json
class LoginProfile {
  //int id;

  String email;
  String password;

  //int age;

  LoginProfile({this.email, this.password});

  factory LoginProfile.fromJson(Map<String, dynamic> map) {
    return LoginProfile(
          email: map["email"],password: map["password"]);
  }

  Map<String, dynamic> toJson() {
    return {"email": email, "password": password};
  }

  @override
  String toString() {
    return 'Profile{email: $email,password: $password }';
  }
}

List<LoginProfile> loginProfileFromJson(String jsonData) {
  final data = json.decode(jsonData);
  return List<LoginProfile>.from(
      data.map((item) => LoginProfile.fromJson(item)));
}

String loginProfileToJson(LoginProfile data) {
  final jsonData = data.toJson();
  return json.encode(jsonData);
}
