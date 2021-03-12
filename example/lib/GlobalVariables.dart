import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Chat

MethodChannel chatMethodPlatform =
    const MethodChannel("mesibo.flutter.io/messaging");
EventChannel eventChannel = EventChannel('mesibo.flutter.io/mesiboEvents');
String mesiboStatus = 'Mesibo status: Not Connected.';
bool isOnline = false;

BuildContext currentContext;
Size screenSize;
