import 'dart:async';

import 'package:flutter/services.dart';

class MesiboPlugin {
  static const MethodChannel _channel = const MethodChannel('mesibo_plugin');
  static EventChannel mesiboEventChannel =
      EventChannel('mesibo_plugin/mesiboEvents');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  setAccessTocken({String chatToken, String deviceToken}) async {
    print("Set Credentials clicked");
    //get AccessToken and Destination From TextField and add it in a list then send it to native mesibo activity where these can be used to start mesibo
    final List list = new List();
    list.add(chatToken);
    list.add(deviceToken);
    // list.add("destinationController.text");

    return _channel.invokeMethod("setAccessToken", {"Credentials": list});
  }

  setOfflineUserForChat() async {
    return _channel.invokeMethod("setUserOffline");
  }

  setOnlineUserForChat() async {
    return _channel.invokeMethod("setUserOnline");
  }

  setGroupParam(String groupId) async {
    final List list = new List();

    list.add(groupId);

    return _channel.invokeMethod("setToGroupParam", {"Param": list});
  }

  setOneToOneParam(String address) async {
    final List list = new List();

    list.add(address);

    return _channel.invokeMethod("setToUserParam", {"Param": list});
  }

  getGroupConversation(String groupId) {
    final List list = new List();
    String mpeer = "";
    list.add(mpeer);
    list.add(groupId);
    return _channel.invokeMethod("getRead", {"Param": list});
  }

  getOneToOneConversation(String address) {
    final List list = new List();
    String groupAddr = "0";
    list.add(address);
    list.add(groupAddr);
    return _channel.invokeMethod("getRead", {"Param": list});
  }

  getUserStatus() {
    return _channel.invokeMethod("getUserStatus");
  }

  sendMessage(String message) {
    return _channel.invokeMethod("sendMessage", {"message": message});
  }

  Stream<dynamic> get mesiboEventsCall {
    return mesiboEventChannel.receiveBroadcastStream();
  }

  // Future<List> initZoom(ZoomOptions options) async {
  //   assert(options != null);

  //   var optionMap = new Map<String, String>();
  //   optionMap.putIfAbsent("appKey", () => options.appKey);
  //   optionMap.putIfAbsent("appSecret", () => options.appSecret);
  //   optionMap.putIfAbsent("domain", () => options.domain);

  //   return _methodChannel.invokeMethod('init', optionMap);
  // }
}
