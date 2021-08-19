import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:opt_test/screens/home_screen.dart';
import 'package:opt_test/screens/logIn_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home:

      // Initializer()
      LoginScreen(),
    );
  }
}

class Initializer extends StatefulWidget {
  const Initializer({Key? key}) : super(key: key);

  @override
  _InitializerState createState() => _InitializerState();
}

class _InitializerState extends State<Initializer> {

  late FirebaseAuth _auth;

  late User _user;

  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _auth = FirebaseAuth.instance;
    _user = _auth.currentUser!;
    isLoading = false;

    print(_user);
  }
  @override
  Widget build(BuildContext context) {
    return isLoading ? Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    ) : _user.uid.isEmpty ? LoginScreen() : HomeScreen() ;
  }
}