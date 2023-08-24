import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:soda_4th_hapit/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:soda_4th_hapit/page/home.dart';
import 'package:soda_4th_hapit/page/login_signup.dart';
import 'package:soda_4th_hapit/page/tasks.dart';
import 'page/friendPage.dart';
import 'page/profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          '/friend': (context) => const FriendPage(),
          '/home': (context) => const HomeScreen(),
          '/profile': (context) => const ProfilePage(),
        },
        title: 'Flutter Demo',
        theme: ThemeData(),
        home: const AuthPage());
  }
}

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else {
                if (snapshot.hasData) {
                  return const LoginAndSignUp();
                } else {
                  return const LoginAndSignUp();
                }
              }
            }));
  }
}

class LoginAndSignUp extends StatefulWidget {
  const LoginAndSignUp({super.key});

  @override
  State<LoginAndSignUp> createState() => _LoginAndSignUpState();
}

class _LoginAndSignUpState extends State<LoginAndSignUp> {
  bool islogin = true;

  void togglePage() {
    setState(() {
      islogin = !islogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (islogin) {
      return LoginPage(
        onPressed: togglePage,
      );
    } else {
      return SignUP(
        onPressed: togglePage,
      );
    }
  }
}
