import 'package:flutter/material.dart';
import 'package:gbsw_capstone_appsters/const/color.dart';
import 'package:gbsw_capstone_appsters/screens/eyedid/eyedid.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.science),
            title: const Text('실험실(Beta)'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Eyedid()),
              );
            },
          ),
          Spacer(),
          ListTile(
            onTap: () {},
            leading: Icon(
              Icons.delete,
              color: AppColors.errorColor,
            ),
            title: Text(
              "계정 삭제",
              style: TextStyle(
                color: AppColors.errorColor,
              ),
            ),
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}
