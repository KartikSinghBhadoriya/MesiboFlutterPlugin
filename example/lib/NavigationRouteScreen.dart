import 'package:flutter/material.dart';
import 'package:mesibo_plugin_example/ChatScreen/ChatScreen.dart';

import 'GlobalVariables.dart';

class NavigationRouteScreen extends StatefulWidget {
  @override
  _NavigationRouteScreenState createState() => _NavigationRouteScreenState();
}

class _NavigationRouteScreenState extends State<NavigationRouteScreen> {
  Widget _defaultHome = ChatScreen();
  final _routes = <String, WidgetBuilder>{
    '/chat': (BuildContext context) => ChatScreen(),
  };
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(builder: (cont) {
        currentContext = cont;
        screenSize = MediaQuery.of(cont).size;
        return _defaultHome == null
            ? Container()
            : Scaffold(
                body: _defaultHome,
              );
      }),
      routes: _routes,
    );
  }
}
