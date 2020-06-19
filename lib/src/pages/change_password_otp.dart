import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:food_delivery/src/pages/home_page.dart';
import 'package:food_delivery/src/pages/otp_page.dart';
import 'package:food_delivery/src/pages/sigin_page.dart';
import 'package:food_delivery/src/widgets/CustomPaint.dart';
import 'package:food_delivery/src/widgets/authentication.dart';
import 'package:food_delivery/src/widgets/constants.dart';
import 'package:food_delivery/src/widgets/customAppBar.dart';
import 'package:food_delivery/src/widgets/search_file.dart';
import 'package:http/http.dart' as http;

class ChangePasswordPageOTP extends StatefulWidget {
  static const routeName = '/change-password-otp';
  @override
  _ChangePasswordPageOTPState createState() => _ChangePasswordPageOTPState();
}

class _ChangePasswordPageOTPState extends State<ChangePasswordPageOTP> {
  var textColor = 0xff006c00;

  var appColor = 0xffc1ffe9;

  var leftIcon = Icons.keyboard_arrow_left;

  var rightIcon = Icons.search;

  var appBarText = " Change Password";

  var replaceRightIcon = false;

  Widget replacedRightWidget;

  var _oldPasswordController = TextEditingController();
  var _newPasswordController = TextEditingController();
  var _confirmNewPasswordController = TextEditingController();

  leftIconCallback() {
    Navigator.pop(context);
  }

  rightIconHandleClick() {
    setState(() {
      replaceRightIcon = !replaceRightIcon;
      replacedRightWidget = SearchField(
        textFieldColor: Color(0xffc1ffe9),
        hinttext: "Search",
        iconcolor: Color(0xffc1ffe9),
      );
    });
  }

  void displayDialog(context, title, text) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: Text(
              title,
              textAlign: TextAlign.center,
            ),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                heightFactor: 1,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      text,
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Text(
                        'Please try again',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    )
                  ],
                ),
              ),
            )),
      );

  Widget _buildChangePasswordFields(
      String text, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: true,

      // style: TextStyle(color: ),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: text,
          hintStyle: TextStyle(
            color: Color(0xFFBDC2CB),
            fontSize: 18.0,
          ),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
  }

  attmeptChangePassword(String otp, int number) async {
    final url = "$serverIp/api/v1/update_password/";

    var response = await http.post(url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(<String, dynamic>{
          'otp': otp,
          'phone': number,
          'password': _newPasswordController.text,
        }));
    if (response.statusCode == 401) //expired
    {
      //refresh token
      await refreshToken();

      response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
          body: jsonEncode(<String, dynamic>{
            'otp': otp,
            'phone': number,
            'password': _newPasswordController.text,
          }));
    }
    final responseBody = json.decode(response.body);
    print(responseBody);
    return responseBody["message"];
  }

  @override
  Widget build(BuildContext context) {
    String res;
    ScreenArguments arguments = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: CustomAppBarWithoutSliver(
        rightIcon: rightIcon,
        hasLeftIcon: true,
        hasRightIcon: false,
        appBarText: "",
        leftIcon: leftIcon,
        leftIconOnPressCallbackFunction: this.leftIconCallback,
        rightIconIsCart: false,
        rightIconOnPressCallbackFunction: this.rightIconHandleClick,
        replaceRightIcon: replaceRightIcon,
        replacedRightWidget: replacedRightWidget,
      ),
      body: CustomPaint(
        painter: DrawCustomAppBar(),
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Container(
            alignment: Alignment.center,
            // height: 200,
            child: Column(
              children: <Widget>[
                Text(
                  '$appBarText',
                  style: TextStyle(
                      color: Color(0xff006c00),
                      fontSize: 28,
                      fontStyle: FontStyle.italic),
                ),
                SizedBox(
                  height: 100,
                ),
                Text(
                  'Please Enter The New Password',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                SizedBox(
                  height: 20,
                ),
                Column(children: <Widget>[
                  SizedBox(
                    height: 40,
                  ),
                  _buildChangePasswordFields(
                      'Enter New Password', _newPasswordController),
                  SizedBox(
                    height: 20,
                  ),
                  _buildChangePasswordFields(
                      'Confirm New Password', _confirmNewPasswordController),
                  SizedBox(
                    height: 20,
                  ),
                ]),
                SizedBox(
                  height: 20,
                ),
                Container(
                    height: 50,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: RaisedButton(
                        textColor: Colors.white,
                        onPressed: () async {
                          res = await attmeptChangePassword(
                              arguments.otp, arguments.phoneNumber);
                          res == 'password reset successful'
                              ? Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => SignInPage()))
                              : displayDialog(context, "An Error Occurred",
                                  " Please Try again later ! ");
                        },
                        child: Text(
                          'Submit',
                          style: TextStyle(
                            color: Color(0xff006c00),
                          ),
                        ),
                        color: Color(0xffc1ffe9),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
