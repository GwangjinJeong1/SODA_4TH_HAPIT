import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:soda_4th_hapit/firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'page/home.dart';

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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: HomeScreen(),
    );
  }
}
