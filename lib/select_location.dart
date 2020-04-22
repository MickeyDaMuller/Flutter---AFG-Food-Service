import 'package:afg_service/login_page.dart';
import 'package:afg_service/record_service_call.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();
int myInts;
String url;
String _email = '';
String _fullname = '';
String _id;
bool _isEnabled = false;

class Country {
  const Country(this.country);

  final String country;
}

class SelectLocationPage extends StatefulWidget {
  SelectLocationPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SelectLocationPageState createState() => _SelectLocationPageState();
}

class _SelectLocationPageState extends State<SelectLocationPage> {
  TextStyle style = TextStyle(
      fontFamily: 'Montserrat', fontSize: 15.0, color: Colors.black54);
  final _formKey = GlobalKey<FormState>();
  SharedPreferences sharedPreferences;

  bool _isLoading = false;
  var response;

  String _mySelection;

  List data = List(); //edited line
  var isLoading = false;

  @override
  void initState() {
    super.initState();

    _loadCounter();

    this.getSWData();
  }

  _loadCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      myInts = prefs.getInt('id') ?? 0;
      _email = (prefs.getString('email') ?? '');
      _fullname = (prefs.getString('fullname') ?? '');
      _fullname = (prefs.getString('fullname') ?? '');

      print("$myInts");
      debugPrint("myID:$myInts");
    });
    url =
        "https://service.afgfood.com/api/select_location_dropdown.aspx?user_id=$myInts";

    //this.getSWData();
    //_fetchData();
  }

  //final String url = "http://truewordblog.site/afg_api/select_location_dropdown.php?user_id=3";

  Future<String> getSWData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');

        var res = await http
            .get(Uri.encodeFull(url), headers: {"Accept": "application/json"});
        var resBody = json.decode(res.body);

        setState(() {
          data = resBody;
          isLoading = false;
        });

        print(resBody);
        debugPrint("mybody:$resBody");

        return "Sucess";
      } else {
        throw Exception('Failed to load profile');
      }
    } on SocketException catch (_) {
      print('not connected');
      setState(() => isLoading = false);

      //debugPrint("No internet:");

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: Text('Internet Error!'),
              content: Text('Check your internet connection and press Ok.'),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext ctx) =>
                                  SelectLocationPage()));
                    },
                    child: Text('Ok')),
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginButon = Material(
      elevation: 3.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Colors.red,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () async {
          if (_mySelection == null) {
            showDialog(
              barrierDismissible: false,
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(
                      'Error!',
                      style: TextStyle(color: Colors.red),
                    ),
                    content: Text('Please fill all field'),
                    actions: <Widget>[
                      FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Close')),
                    ],
                  );
                });
          } else {
            Navigator.of(context).push(new AnimationPageRoute());
            SharedPreferences prefs = await SharedPreferences.getInstance();
            //prefs.setInt('id', res);
            prefs.setString('client_id', _mySelection);

          }
        },
        child: Text(
          "Continue",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );

    choiceAction(String choice) async {
      if (choice == Constants.SignOut) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.remove('email');
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext ctx) => MyLoginPage()));
      }
      /*else if(choice == Constants.Subscribe){
    print('Subscribe');
  }else if(choice == Constants.Settings){
    print('SignOut');
  }*/
    }

    return Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.red,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset(
              "assets/afg_logo.png",
              fit: BoxFit.contain,
            ),
          ],
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: choiceAction,
            itemBuilder: (BuildContext context) {
              return Constants.choices.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(
                    choice,
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }).toList();
            },
          )
        ],
      ),
      key: _scaffoldState,
      body: WillPopScope(
        //Wrap out body with a `WillPopScope` widget that handles when a user is cosing current route
        onWillPop: () async {
          Future.value(
              false); //return a `Future` with false value so this route cant be popped or closed.
        },

        child: Stack(
          //padding: EdgeInsets.only(top: 30.0, left: 10.0, right: 10.0),
          // child: ListView(
          children: <Widget>[
            Form(
              key: _formKey,
              //color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ListView(
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 20.0),
                    SizedBox(
                      height: 100.0,
                      child: Icon(
                        Icons.store, // Add this
                        color: Colors.red, size: 100, // Add this
                      ),
                    ),
                    SizedBox(
                        //height: 155.0,
                        child: Text("SELECT SERVICE LOCATION",
                            style: TextStyle(
                                fontSize: 20.0,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.red),
                            textAlign: TextAlign.center)),
                    SizedBox(height: 45.0),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          // contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                          border: Border.all(color: Colors.red)),
                      child: DropdownButtonHideUnderline(
                        child: ButtonTheme(
                          alignedDropdown: true,
                          child: DropdownButton(
                            hint: new Text(
                              "Select Company Name",
                              style: style,
                            ),
                            style: style,
                            //value: selectedCountry,
                            onChanged: (newVal) {
                              setState(() {
                                _mySelection = newVal;
                              });
                            },
                            value: _mySelection,
                            items: data.map((item) {
                              return new DropdownMenuItem(
                                child: Row(children: <Widget>[
                                  new Text(item['ID']),
                                  SizedBox(width: 5,),
                                  new Text("-"),
                                  SizedBox(width: 5,),
                                  new Text(item['ShortName']),
                                ],),
                                value: item['ID'].toString(),
                              );
                            }).toList(),

                            isExpanded: false,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 25.0),
                   /* Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          // contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                          border: Border.all(color: Colors.red)),
                      child: DropdownButtonHideUnderline(
                        child: ButtonTheme(
                          alignedDropdown: true,
                          child: DropdownButton(
                            hint: new Text(
                              "Select Store Number",
                              style: style,
                            ),
                            style: style,
                            //value: selectedCountry,
                            onChanged: (newVal) {
                              setState(() {
                                _mySelectionNumber = newVal;
                              });
                            },
                            value: _mySelectionNumber,
                            items: data.map((item) {
                              return new DropdownMenuItem(
                                child: new Text(item['ID']),
                                value: item['ID'].toString(),
                              );
                            }).toList(),

                            isExpanded: false,
                          ),
                        ),
                      ),
                    ),*/
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
      ),
    );
  }
}

class Users {
  int id;
  String name;
  String username;
  String email;

  Users({
    this.id,
    this.name,
    this.username,
    this.email,
  });

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      username: json['username'],
    );
  }
}

class Constants {
  static const String Subscribe = 'Select Service Location';
  static const String Settings = 'Record Work Done';
  static const String SignOut = 'Sign out';

  static const List<String> choices = <String>[
    //Subscribe,
    //Settings,
    SignOut
  ];
}

class AnimationPageRoute extends MaterialPageRoute {
  AnimationPageRoute()
      : super(builder: (BuildContext context) => new RecordServiceCallPage());

  // OPTIONAL IF YOU WISH TO HAVE SOME EXTRA ANIMATION WHILE ROUTING
  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return new RotationTransition(
        turns: animation,
        child: new ScaleTransition(
          scale: animation,
          child: new FadeTransition(
            opacity: animation,
            child: new RecordServiceCallPage(),
          ),
        ));
  }
}
