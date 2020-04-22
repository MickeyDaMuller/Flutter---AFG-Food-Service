import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:afg_service/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notifcation_dialog.dart';
import 'select_location.dart';

int myInts;
String url;
String _email = '';
String _fullname = '';
String _client_id = '';
String _id;
bool _isEnabled = false;
String resSubmit;

class ApiService {
  final String baseUrl =
      "https://service.afgfood.com/api/record_work_doneJSON.aspx";
  Client client = Client();
  var response;

  Future<List<Profile>> getProfiles() async {
    response = await client.get("$baseUrl");
    if (response.statusCode == 200) {
      return profileFromJson(response.body);
    } else {
      print(response.body);
      //return null;
    }
  }

  Future<bool> createProfile(Profile data) async {
    response = await client.post(
      "$baseUrl",
      headers: {"content-type": "application/json"},
      body: profileToJson(data),
    );

    resSubmit = response.body;
    debugPrint("myresd:$resSubmit");

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }
}

class Profile {
  //int id;
  String ClientID;
  String EquipmentID;
  String Technician;
  String PartsNeeded;
  String JobNumber;
  String Problem;
  String StartDateTime;

  //int age;

  Profile(
      { //this.id = 0,
      this.ClientID,
      this.EquipmentID,
      this.Technician,
      this.PartsNeeded,
      this.JobNumber,
      this.Problem,
      this.StartDateTime});

  factory Profile.fromJson(Map<String, dynamic> map) {
    return Profile(
      //id: map["ID"],
      ClientID: map["ClientID"],
      EquipmentID: map["EquipmentID"],
      Technician: map["Technician"],
      PartsNeeded: map["PartsNeeded"],
      JobNumber: map["JobNumber"],
      Problem: map["Problem"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      //"ID": id,
      "ClientID": ClientID,
      "EquipmentID": EquipmentID,
      "Technician": Technician,
      "PartsNeeded": PartsNeeded,
      "JobNumber": JobNumber,
      "Problem": Problem,
      "StartDateTime": StartDateTime
    };
  }

  @override
  String toString() {
    return 'Profile{ClientID: $ClientID, EquipmentID: $EquipmentID,Technician: $Technician,PartsNeeded: $PartsNeeded,JobNumber: $JobNumber, Problem: $Problem,StartDateTime: $StartDateTime}';
  }
}

List<Profile> profileFromJson(String jsonData) {
  final data = json.decode(jsonData);
  return List<Profile>.from(data.map((item) => Profile.fromJson(item)));
}

String profileToJson(Profile data) {
  final jsonData = data.toJson();
  return json.encode(jsonData);
}

class RecordServiceCallPage extends StatefulWidget {
  RecordServiceCallPage({Key key, this.title}) : super(key: key);
  Profile profile;
  final String title;

  @override
  _RecordServiceCallPageState createState() => _RecordServiceCallPageState();
}

class _RecordServiceCallPageState extends State<RecordServiceCallPage> {
  TextStyle style = TextStyle(
      fontFamily: 'Montserrat', fontSize: 15.0, color: Colors.black54);
  var resBody;
  final _formKey = GlobalKey<FormState>();
  String textValue = 'Hello World !';
  final FocusNode _nodeText1 = FocusNode();
  final FocusNode _nodeText2 = FocusNode();
  final FocusNode _nodeText3 = FocusNode();
  SharedPreferences sharedPreferences;
  ApiService _apiService = ApiService();
  bool _isLoading = false;
  var response;
  DateTime selectedDate = DateTime.now();
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  String _mySelectionEquipment;

  List data = List(); //edited line
  var isLoading = false;

  TextEditingController _controllerJobNumber = TextEditingController();
  TextEditingController _controllerProblem = TextEditingController();
  TextEditingController _controllerPart = TextEditingController();
  bool _autoValidate = false;
  bool _isFieldProblemValid;
  bool _isFieldJobNumberValid;
  bool _isFieldPartValid;

  @override
  void initState() {
    _loadCounter();

    this.getSWData();

    super.initState();
  }

  _loadCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      myInts = prefs.getInt('id') ?? 0;
      _email = (prefs.getString('email') ?? '');
      _client_id = (prefs.getString('client_id') ?? '');
      _fullname = (prefs.getString('fullname') ?? '');

      print("$myInts");
      debugPrint("myID:$myInts");

      debugPrint("myclientID:$_client_id");
    });
    url =
        "https://service.afgfood.com/api/select_equipment_dropdown.aspx?user_id=$_client_id";
  }

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
        resBody = json.decode(res.body);

        setState(() {
          data = resBody;
          isLoading = false;
        });

        print(resBody);
        debugPrint("equip:$resBody");

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
                                  RecordServiceCallPage()));
                    },
                    child: Text('Ok')),
              ],
            );
          });
    }
  }

  String problem;
  String part;

  String validatePart(String value) {
    if (value.length < 3)
      return 'Field must be more than 2 charater';
    else
      return null;
  }

  String validateProblem(String value) {
    if (value.length < 3)
      return 'Field must be more than 2 charater';
    else
      return null;
  }

  String validateJobNumber(String value) {
    if (value.length < 3)
      return 'Field must be more than 2 charater';
    else
      return null;
  }

  @override
  Widget build(BuildContext context) {
    final partsField = TextFormField(
      obscureText: false,
      style: style,
      maxLines: 5,
      autovalidate: _autoValidate,
      //autovalidate: true,
      validator: validatePart,
      onSaved: (String val) {
        part = val;
      },
      controller: _controllerPart,
      focusNode: _nodeText1,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        labelText: "Part Needed...",
        prefixText: ' ',
        hintText: "Part Needed",
        labelStyle: new TextStyle(color: Colors.black54),
        hintStyle: new TextStyle(color: Colors.black54),
        suffixIcon: const Icon(
          Icons.build,
          color: Colors.black54,
        ),
        errorText: _isFieldPartValid == null || _isFieldPartValid
            ? null
            : "Part needed is required",
        enabledBorder: const OutlineInputBorder(
          // width: 0.0 produces a thin "hairline" border
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
      /*onChanged: (value) {
        bool isFieldValid = value.trim().isNotEmpty;
        if (isFieldValid != _isFieldEmailValid) {
          setState(() => _isFieldEmailValid = isFieldValid);
        }
      },*/
    );

    final jobNumberField = TextFormField(
      obscureText: false,
      style: style,
      autovalidate: _autoValidate,
      //autovalidate: true,
      validator: validateJobNumber,
      onSaved: (String val) {
        problem = val;
      },
      controller: _controllerJobNumber,
      focusNode: _nodeText3,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        labelText: "Job Number",
        hintText: "Job Number",
        prefixText: ' ',
        labelStyle: new TextStyle(color: Colors.black54),
        hintStyle: new TextStyle(color: Colors.black54),
        suffixIcon: const Icon(
          Icons.format_list_numbered,
          color: Colors.black54,
        ),
        errorText: _isFieldJobNumberValid == null || _isFieldJobNumberValid
            ? null
            : "Job number is required",
        enabledBorder: const OutlineInputBorder(
          // width: 0.0 produces a thin "hairline" border
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
    );

    final problemField = TextFormField(
      obscureText: false,
      style: style,
      maxLines: 5,
      autovalidate: _autoValidate,
      //autovalidate: true,
      validator: validateProblem,
      onSaved: (String val) {
        problem = val;
      },
      controller: _controllerProblem,
      focusNode: _nodeText2,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        labelText: "Describe Problem...",
        hintText: "Describe Problem",
        prefixText: ' ',
        labelStyle: new TextStyle(color: Colors.black54),
        hintStyle: new TextStyle(color: Colors.black54),
        suffixIcon: const Icon(
          Icons.report_problem,
          color: Colors.black54,
        ),
        errorText: _isFieldProblemValid == null || _isFieldProblemValid
            ? null
            : "Describe problem is required",
        enabledBorder: const OutlineInputBorder(
          // width: 0.0 produces a thin "hairline" border
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
    );

    final loginButon = Material(
      elevation: 3.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Colors.red,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () async {
          if (!_formKey.currentState.validate() ||
              _mySelectionEquipment == null ||
              _mySelectionEquipment == 0.toString()) {
            if (!_formKey.currentState.validate()) {
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(
                        'Error!',
                        style: TextStyle(color: Colors.red),
                      ),
                      content: Text('Please fill all field.'),
                      actions: <Widget>[
                        FlatButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Close')),
                      ],
                    );
                  });
            } else if (_mySelectionEquipment == null) {
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(
                        'Error!',
                        style: TextStyle(color: Colors.red),
                      ),
                      content: Text('Select Equipment From The Dropdown.'),
                      actions: <Widget>[
                        FlatButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Close')),
                      ],
                    );
                  });
            } else if (_mySelectionEquipment == 0.toString()) {
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(
                        'Error!',
                        style: TextStyle(color: Colors.red),
                      ),
                      content: Text('No Equipment Registered.'),
                      actions: <Widget>[
                        FlatButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Close')),
                      ],
                    );
                  });
            }
          } else {
            setState(() => _isLoading = true);
            //Dialogs.showLoadingDialog(context, _formKey); //invoking login

            String Problem = _controllerProblem.text.toString();
            String Parts = _controllerPart.text.toString();
            String JobNumber = _controllerJobNumber.text.toString();
            String Equipment = _mySelectionEquipment.toString();
            String ClientID = _client_id.toString();
            String StartDateTime = dateFormat.format(selectedDate).toString();
            print("problem:$Problem");
            print("part:$Parts");
            print("equipment:$Equipment");
            print("clientid:$ClientID");
            print("email:$_email");

            try {
              final result = await InternetAddress.lookup('google.com');
              if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                print('connected');

                Profile profile = Profile(
                  Technician: _email,
                  ClientID: ClientID,
                  Problem: Problem,
                  PartsNeeded: Parts,
                  JobNumber: JobNumber,
                  EquipmentID: Equipment,
                  StartDateTime: StartDateTime,
                );

                _apiService.createProfile(profile).then((isSuccess) async {
                  setState(() => _isLoading = false);
                  debugPrint("email:$profile");

                  /* Navigator.push(context, MaterialPageRoute(builder: (context) {
                return AnotherHomePage();
              }));*/
                  //SystemChrome.setEnabledSystemUIOverlays([]);

                  print(Problem);
                  print(Equipment);

                  if (resSubmit == "Work Saved Successfully") {
                    Navigator.of(_formKey.currentContext, rootNavigator: true)
                        .pop(); //close the dialoge

                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Congratulation!"),
                            content: Text("Submitted Successful"),
                            actions: <Widget>[
                              FlatButton(
                                  onPressed: () {
                                    Navigator.popUntil(context,
                                        (_) => !Navigator.canPop(context));

                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext ctx) =>
                                                SelectLocationPage()));
                                  },
                                  child: Text('Close')),
                            ],
                          );
                        });
                  } else {
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(
                              "Error!",
                              style: TextStyle(color: Colors.red),
                            ),
                            content: Text("Oops. Something went wrong."),
                            actions: <Widget>[
                              FlatButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('Close')),
                            ],
                          );
                        });
                  }
                });
              }
            } on SocketException catch (_) {
              print('not connected');
              //debugPrint("No internet:");
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Internet Error!'),
                      content: Text('Check your internet connection.'),
                      actions: <Widget>[
                        FlatButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Close')),
                      ],
                    );
                  });
            }
          }
        },
        child: Text(
          "Update Job Status",
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
      body: Stack(
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
                  SizedBox(height: 5.0),
                  SizedBox(
                      //height: 155.0,
                      child: Text("RECORD YOUR TIME",
                          style: TextStyle(
                              fontSize: 20.0,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                          textAlign: TextAlign.center)),
                  SizedBox(height: 10.0),
                  SizedBox(
                    height: 100.0,
                    child: Icon(
                      Icons.timer, // Add this
                      color: Colors.red, size: 100, // Add this
                    ),
                  ),
                  Center(
                      child: Text(
                    dateFormat.format(selectedDate),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                  Material(
                      elevation: 3.0,
                      borderRadius: BorderRadius.circular(30.0),
                      color: Colors.red,
                      child: MaterialButton(
                        child: Text(
                          'Choose start date & time',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          showDateTimeDialog(context, initialDate: selectedDate,
                              onSelectedDate: (selectedDate) {
                            setState(() {
                              this.selectedDate = selectedDate;
                            });
                          });
                        },
                      )),
                  SizedBox(height: 50.0),
                  SizedBox(
                      //height: 155.0,
                      child: Text("RECORD WORK DONE",
                          style: TextStyle(
                              fontSize: 20.0,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                          textAlign: TextAlign.center)),
                  SizedBox(height: 10.0),
                  jobNumberField,
                  SizedBox(height: 10.0),
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
                            "Select Equipment",
                            style: style,
                          ),
                          style: style,
                          //value: selectedCountry,
                          onChanged: (newVal) {
                            setState(() {
                              _mySelectionEquipment = newVal;
                            });
                          },
                          value: _mySelectionEquipment,
                          items: data.length > 0
                              ? data.map((item) {
                                  return new DropdownMenuItem(
                                    child: Row(
                                      children: <Widget>[
                                        Text(item['EquipmentMake'] ??
                                            "No Equipment Registered"),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(item['EquipmentModel'] ?? ""),
                                      ],
                                    ),
                                    value: item['ID'],
                                  );
                                }).toList()
                              : [
                                  DropdownMenuItem(
                                      child: Row(
                                        children: <Widget>[
                                          Text("No Equipment Registered"),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(""),
                                        ],
                                      ),
                                      value: 0.toString())
                                ],

                          isExpanded: false,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  problemField,
                  SizedBox(height: 10.0),
                  partsField,
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
    );
  }
}

class Constants {
  //static const String Subscribe = 'Subscribe';
  //static const String Settings = 'Settings';
  static const String SignOut = 'Sign out';

  static const List<String> choices = <String>[
    //Subscribe,
    //Settings,
    SignOut
  ];
}
