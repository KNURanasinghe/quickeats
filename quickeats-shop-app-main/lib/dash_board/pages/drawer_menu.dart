import 'package:flutter/material.dart';
import 'package:shop_app/custom_widgets/back_button.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({super.key});

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color.fromARGB(255, 255, 204, 0),
                  const Color.fromARGB(255, 255, 153, 0),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/images/shop_image.png'),
                ),
                SizedBox(height: 10),
                Text(
                  'Welcome, User',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.5),
          ListTile(
            leading: CustomBackArrow(isExitNeeded: true,),
            title: Text('Logout'),
            onTap: () {
            },
          ),
        ],
      ),
    );
  }
}