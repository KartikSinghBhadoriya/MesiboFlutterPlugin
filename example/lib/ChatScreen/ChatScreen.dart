import 'package:flutter/material.dart';
import 'package:mesibo_plugin/mesibo_plugin.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  MesiboPlugin mesibo = MesiboPlugin();

  @override
  void initState() {
    // TODO: implement initState

    mesibo.setAccessTocken(
        chatToken: "f0ea2f4173903fa9c11dc2ff601028aba6a33152943e7715141d",
        // "d61f2395f676c6b5c417e99a59881b4ebccabc2418482fe1115141b",
        deviceToken:
            "e2sfnpyZSuGtVhHAlzmAEP:APA91bGbkl2Ut13gO5dI-KsN95L4U9xGi6ayU2stC6y8uhnPXrpoVpPeSdVPZGSdZN25bPF6e4oQbGm6Q6pMT54HhWAWw5uxNIXhZkDxcBJ7HwwxhFLnVSFJ5JMzRaiC59M-FXlIw7-h"
        // "dgv_fe9r2kT6mqYriiW7Yk:APA91bEU2gtB04tH2BLsM_lEA4yQJyOPbY5EKeIlsGQMjz9hZBJQ9NwJkKMuYKRvk7QKFt8U1o-dGU6NyCSnqmSUERKmwWT9gTUJ1lpehxQ1fUigUC3w55tCYcxpLXi6_oE4M6Rp1ubZ"
        );
    mesibo.mesiboEventsCall.listen(_onEventCall, onError: _onError);
  }

  void _onEventCall(Object event) {
    print("ChatList Event Call");
    print(event);
  }

  void _onError(Object error) {
    print(error);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RaisedButton(
                onPressed: () {
                  mesibo.setGroupParam("121294");
                  // mesibo.getOneToOneConversation("medcytes@gmail.com");
                },
                child: Text("Get Conversation"),
              ),
              RaisedButton(
                onPressed: () {
                  mesibo.sendMessage("Hi");
                },
                child: Text("Send Hi message"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
