import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gbsw_capstone_appsters/screens/auth/sign_in_screen.dart';

/* 
2024 12 29
김진현 2일 해커톤 렛츠고
*/

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(color: Colors.white),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'JuaRegular',
      ),
      home: SignInScreen(),
    );
  }
}
