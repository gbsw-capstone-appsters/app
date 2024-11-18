import 'package:flutter/material.dart';
import 'package:gbsw_capstone_appsters/style/colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Text('Home'),
    );
  }
}
