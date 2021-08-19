import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:opt_test/screens/home_screen.dart';

enum MobileVerificationState { SHOW_MOBILE_FORM_STATE, SHOW_OTP_FORM_STATE }

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  MobileVerificationState currentState =
      MobileVerificationState.SHOW_MOBILE_FORM_STATE;

  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;
  String verificationId = 'nameId';

  bool showLoading = false;

  void signInWithPhoneAuthCredential(
      PhoneAuthCredential phoneAuthCredential) async {
    setState(() {
      showLoading = true;
    });
    try {
      final authCredential =
          await _auth.signInWithCredential(phoneAuthCredential);
      setState(() {
        showLoading = false;
      });

      if(authCredential.user != null){
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      }

    } on FirebaseAuthException catch (e) {
      setState(() {
        showLoading = false;
      });

      _scaffoldKey.currentState!
          .showSnackBar(SnackBar(content: Text('$e.message')));
    }
  }

  getMobileFormWidget(BuildContext context) {
    return Column(
      children: [
        Spacer(),
        TextField(
          controller: phoneController,
          // keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter Mobile Number',
          ),
        ),
        SizedBox(
          height: 16,
        ),
        FlatButton(
          onPressed: () async {
            setState(() {
              showLoading = true;
            });
            await _auth.verifyPhoneNumber(
              phoneNumber: phoneController.text,
              verificationCompleted: (phoneAuthCredential) async {
                setState(() {
                  showLoading = false;
                });
                // signInWithPhoneAuthCredential(phoneAuthCredential);
              },
              verificationFailed: (verificationFailed) async {
                setState(() {
                  showLoading = false;
                });
                _scaffoldKey.currentState!.showSnackBar(
                    SnackBar(content: Text('$verificationFailed.message')));
              },
              codeSent: (verificationId, resendingToken) async {
                setState(() {
                  showLoading = false;

                  currentState = MobileVerificationState.SHOW_OTP_FORM_STATE;
                  this.verificationId = verificationId;
                });
              },
              codeAutoRetrievalTimeout: (verificationId) async {},
            );
          },
          child: Text('SEND'),
          color: Colors.blue,
        ),
        Spacer()
      ],
    );
  }

  getOtpFormWidget(BuildContext context) {
    return Column(
      children: [
        Spacer(),
        TextField(
          controller: otpController,
          decoration: InputDecoration(hintText: 'Enter OTP'),
        ),
        SizedBox(
          height: 16,
        ),
        FlatButton(
          onPressed: () async {
            PhoneAuthCredential phoneAuthCredential =
                PhoneAuthProvider.credential(
                    verificationId: verificationId, smsCode: otpController.text);
            signInWithPhoneAuthCredential(phoneAuthCredential);

            // print('user $verificationId');
          },
          child: Text('VERIFY'),
          color: Colors.blue,
        ),
        Spacer()
      ],
    );
  }

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Container(
          padding: EdgeInsets.all(16),
          child: showLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : currentState == MobileVerificationState.SHOW_MOBILE_FORM_STATE
                  ? getMobileFormWidget(context)
                  : getOtpFormWidget(context),
        ));
  }
}
