import 'package:flutter/material.dart';

class SideDrawer extends StatefulWidget {
  const SideDrawer({super.key});

  @override
  State<SideDrawer> createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    const DrawerHeader(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            CircleAvatar(
                              radius: 40.0,
                              backgroundColor: Colors.white,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'John',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ListTile(
                      title: const Text(
                        'Reporting and Analytics',
                        style: TextStyle(color: Colors.black),
                      ),
                      onTap: () {},
                    ),
                    ListTile(
                      title: const Text(
                        'Settings and Preferences',
                        style: TextStyle(color: Colors.black),
                      ),
                      onTap: () {},
                    ),
                    ListTile(
                      title: const Text(
                        'Support and Help',
                        style: TextStyle(color: Colors.black),
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
