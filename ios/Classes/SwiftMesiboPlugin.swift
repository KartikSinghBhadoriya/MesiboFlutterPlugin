import Flutter
import UIKit
import mesibo

var MESIBO_MESSAGING_CHANNEL : String = "mesibo_plugin"
var MESIBO_ACTIVITY_CHANNEL : String = "mesibo_plugin/mesiboEvents"
var MesiboErrorMessage : String = "Mesibo has not started yet, Check Credentials"
//var mCall : MesiboCall? = nil
var mesibo : Mesibo = Mesibo.getInstance()
var mesiboReadSession : MesiboReadSession?
//var mesiboInstance = Mesibo.getInstance()
var mEventSink : FlutterEventSink?
var mUserAccessToken : String = ""
var mPushToken : String = ""
var mPeer : String = ""
var groupPeer : String = ""
var mParameter : mesibo.MesiboParams? = nil
var mUserDeviceToken : String = ""

public class SwiftMesiboPlugin: NSObject, FlutterPlugin,MesiboDelegate {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: MESIBO_MESSAGING_CHANNEL, binaryMessenger: registrar.messenger())
    let statusEventChannel = FlutterEventChannel(name: MESIBO_ACTIVITY_CHANNEL, binaryMessenger: registrar.messenger())
    statusEventChannel.setStreamHandler(StreamHandler())
    let instance = SwiftMesiboPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result("iOS " + UIDevice.current.systemVersion)
        
        switch call.method {
        case "setAccessToken":
            self.setAccessToken(call: call, result:result)
            break
        case "setToUserParam":
            self.setToUserParam(call: call, result:result)
            break
        case "setToGroupParam":
            self.setToGroupParam(call: call, result:result)
            break
        case "getRead":
            self.getConversation(call: call, result:result)
            break
        case "sendMessage":
            self.callSendMessage(call: call, result: result)
            break
        case "launchMesiboUI":
            // self.callLaunchMesiboUI(call: call, result: result)
            break
        case "audioCall":
            // self.callAudioCall(call: call, result: result)
            break
        case "videoCall":
            // self.callVideoCall(call: call, result: result)
            break
        case "getUserStatus":
            self.getUserStatus(call: call, result: result)
            break
        case "setUserOffline":
            self.setUserOffline(call: call, result: result)
            break
        case "setUserOnline":
            self.setUserOnline(call: call, result: result)
            break
        default:
            result(FlutterMethodNotImplemented)
            break
        }
    }
    
    public func setAccessToken(call: FlutterMethodCall, result: FlutterResult)
    {
        var dicCredential = NSDictionary()
        var credentials = NSMutableArray()
        
        //get credentials from flutter
        dicCredential = call.arguments as! NSDictionary
        credentials = dicCredential["Credentials"] as! NSMutableArray;
        if credentials.count > 0 {
            mUserAccessToken = credentials.object(at: 0) as! String // auth token
            mPushToken = credentials.object(at: 1) as! String // auth token
            //            mPeer = credentials.object(at: 1) as! String // "mobile number"
            
            //start mesibo here
            mesiboInit()
            //            mParameter = MesiboParams()
            //            // set Mesibo MessageParams
            //
            //            mParameter?.setParams(mPeer, groupid: 0, flag: UInt32(MESIBO_FLAG_DEFAULT), origin: 0)
        }
    }
    
    public func setUserOffline(call: FlutterMethodCall, result: FlutterResult)
    {
        mesibo.stop()
        //        getUserStatus(call: call, result: result)
    }
    
    public func setUserOnline(call: FlutterMethodCall, result: FlutterResult)
    {
        mesibo.start()
        //        getUserStatus(call: call, result: result)
    }
    
    public func setToUserParam(call: FlutterMethodCall, result: FlutterResult)
    {
        var dicCredentital = NSDictionary()
        var param = NSMutableArray()
        
        //get credentials from flutter
        dicCredentital = call.arguments as! NSDictionary
        param = dicCredentital["Param"] as! NSMutableArray;
        if param.count > 0 {
            // mUserAccessToken = param.object(at: 0) as! String // auth token
            mPeer = param.object(at: 0) as! String // "mobile number"
            
            //start mesibo here
            // mesiboInit()
            mParameter = MesiboParams()
            // set Mesibo MessageParams
            
            mParameter?.setParams(mPeer, groupid: 0, flag: UInt32(MESIBO_FLAG_DEFAULT), origin: 0)
        }
    }
    
    public func setToGroupParam(call: FlutterMethodCall, result: FlutterResult)
    {
        var dicCredentital = NSDictionary()
        var param = NSMutableArray()
        
        //get credentials from flutter
        dicCredentital = call.arguments as! NSDictionary
        param = dicCredentital["Param"] as! NSMutableArray;
        if param.count > 0 {
            // mUserAccessToken = param.object(at: 0) as! String // auth token
            groupPeer = param.object(at: 0) as! String // "mobile number"
            
            //start mesibo here
            // mesiboInit()
            mParameter = MesiboParams()
            // set Mesibo MessageParams
            print(UInt32(groupPeer))
            mParameter?.setGroup(UInt32(groupPeer) ?? 0)
            //            mParameter?.setParams("", groupid: UInt32(groupPeer) ?? 0, flag: UInt32(MESIBO_FLAG_READRECEIPT|MESIBO_FLAG_DELIVERYRECEIPT), origin: 0)
            mEventSink?("param set")
        }
    }
    
    
    public func callSendMessage(call: FlutterMethodCall, result: FlutterResult)
    {
        if !mPeer.isEmpty {
            //send message to desired user added in mParameter
            var dicCredentital = NSDictionary()
            var message : String = ""
            
            //get credentials from flutter
            dicCredentital = call.arguments as! NSDictionary
            message = dicCredentital["message"] as! String;
            mParameter?.expiry = Int32(3600*24*7)
            mParameter?.flag = UInt32(MESIBO_FLAG_READRECEIPT|MESIBO_FLAG_DELIVERYRECEIPT)
            mesibo.sendReadReceipt(mParameter, msgid: UInt64(arc4random()))
            mesibo.sendMessage(mParameter, msgid: arc4random(), string: message);
            mEventSink?("Message Sent to "+mPeer);
        }
        else if !groupPeer.isEmpty
        {
            var dicCredentital = NSDictionary()
            var message : String = ""
            
            //get credentials from flutter
            dicCredentital = call.arguments as! NSDictionary
            message = dicCredentital["message"] as! String;
            mParameter?.expiry = Int32(3600*24*7)
            mParameter?.flag = UInt32(MESIBO_FLAG_READRECEIPT|MESIBO_FLAG_DELIVERYRECEIPT)
            mesibo.sendMessage(mParameter, msgid: arc4random(), string: message);
            mEventSink?("Message Sent to "+groupPeer);
        }
        else{
            mEventSink?(MesiboErrorMessage);
        }
    }
    
    
    // private func callLaunchMesiboUI(call: FlutterMethodCall, result: FlutterResult)
    // {
    //     let ui = Mesibo.getInstance().getUiOptions()
    //     ui?.emptyUserListMessage = "No active conversations! Invite your family and friends to try mesibo."
        
    //     let mesiboController = MesiboUI.getViewController()
    //     var navigationController: UINavigationController? = nil
    //     if let mesiboController = mesiboController {
    //         navigationController = UINavigationController(rootViewController: mesiboController)
    //     }
    //     // setRootController(navigationController)
    //     //        if !mPeer.isEmpty {
    //     //
    //     ////
    //     ////
    //     ////            MesiboUIManager.setDefaultParent(navigationController)
    //     ////            MesiboCall.sharedInstance().start()
    //     //        }else{
    //     //            mEventSink?(MesiboErrorMessage);
    //     //        }
    // }
    
    // func setRootController(_ controller: UIViewController?) {
    //     window!.rootViewController = controller
    //     window!.rootViewController = controller
    //     window!.makeKeyAndVisible()
    //     //[[UIApplication sharedApplication].keyWindow setRootViewController:rootViewController];
    // }
    public func callAudioCall(call: FlutterMethodCall, result: FlutterResult)
    {
        if !mPeer.isEmpty {
            //            MesiboCall.sharedInstance()?.call(self, callid: arc4random(), address: mPeer, video: false, incoming: true)
        }else{
            mEventSink?(MesiboErrorMessage);
        }
    }
    
    public func callVideoCall(call: FlutterMethodCall, result: FlutterResult)
    {
        if !mPeer.isEmpty {
            //            MesiboCall.sharedInstance()?.call(self, callid: arc4random(), address: mPeer, video: true, incoming: true)
        }else{
            mEventSink?(MesiboErrorMessage);
        }
    }
    
    
    
    //    private func receiveBatteryLevel(result: FlutterResult) {
    //        let device = UIDevice.current
    //        device.isBatteryMonitoringEnabled = true
    //        if device.batteryState == UIDevice.BatteryState.unknown {
    //            result(FlutterError(code: "UNAVAILABLE",
    //                                message: "Battery info unavailable",
    //                                details: nil))
    //        } else {
    //            result(Int(device.batteryLevel * 100))
    //        }
    //    }
    public func mesiboInit(){
        mesibo = Mesibo.getInstance();
        
        //        mesibo.someInit()
        
        /** [OPTIONAL] Initializa calls if used  */
        //        mCall = MesiboCall.sharedInstance()
        //        mCall?.getConfig()
        
        /** [Optional] add listener for file transfer handler
         * you only need if you plan to send and receive files using mesibo
         * */
        //        MesiboFileTransferHelper fileTransferHelper = new MesiboFileTransferHelper();
        //        Mesibo.addListener(fileTransferHelper);
        
        /** add other listener - you can add any number of listeners */
        mesibo.addListener(self)
        
        /** [Optional] enable to disable secure connection */
        mesibo.setSecureConnection(true)
        
        /** Initialize web api to communicate with your own backend servers */
        //* set user access token
        mesibo.setAccessToken(mUserAccessToken)
        mesibo.setPushToken(mPushToken, voip: true)
        // mesibo.setPushToken(mUserDeviceToken, voip: true)
        print(mPushToken)
        print(mUserDeviceToken)
        mEventSink?("Device Token \(mUserDeviceToken)")
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        // set path for storing DB and messaging files
        mesibo.setPath(documentsPath)
        
        /* * [OPTIONAL] set up database to save and restore messages
         * Note: if you call this API before setting an access token, mesibo will
         * create a database exactly as you named it. However, if you call it
         * after setting Access Token like in this example, it will be uniquely
         * named for each user [Preferred].
         * */
        mesibo.setDatabase("myAppDb.db", resetTables: 0)
        
        // start mesibo
        mesibo.start();
        /** add other listener - you can add any number of listeners */
        
    }
    
    public func getUserStatus(call: FlutterMethodCall, result: FlutterResult)
    {
        print(mesibo.getProfileFrom(mParameter)?.status as Any)
        switch mesibo.getConnectionStatus() {
        case MESIBO_STATUS_ONLINE:
            print("Mesibo Connection Status : Online")
            mEventSink?("Online")
        case MESIBO_STATUS_OFFLINE:
            print("Mesibo Connection Status : Offline")
            mEventSink?("Offline")
        default:
            mEventSink?("Mesibo Connection Status : Unknown StausCode \( mesibo.getConnectionStatus())")
        }
    }
    
    
    
    public func mesibo_(onConnectionStatus status: Int32) {
        //        if status == MESIBO_STATUS_ONLINE {
        //            mEventSink?("Mesibo Connection Status : Online")
        //        }
        
        switch status {
        case MESIBO_STATUS_ONLINE:
            print("Mesibo Connection Status : Online")
            mEventSink?("Online")
        case MESIBO_STATUS_OFFLINE:
            print("Mesibo Connection Status : Offline")
            mEventSink?("Offline")
        default:
            mEventSink?("Mesibo Connection Status : Unknown StausCode \( mesibo.getConnectionStatus())")
        }
    }
    
    public func getConversation(call: FlutterMethodCall, result: FlutterResult)
    {
        var dicCredentital = NSDictionary()
        var param = NSMutableArray()
        
        dicCredentital = call.arguments as! NSDictionary
        param = dicCredentital["Param"] as! NSMutableArray;
        mPeer = param.object(at: 0) as! String // auth token
        groupPeer = param.object(at: 1) as! String // "mobile number"
        
        //start mesibo here
        // mesiboInit()
        
        // set Mesibo MessageParams
        mesiboReadSession = MesiboReadSession()
        mesiboReadSession?.shouldGroupAccessibilityChildren = true
        if groupPeer == "0" {
            mesiboReadSession?.initSession(mPeer, groupid: 0, query: nil, delegate: self)
        }
        else
        {
            mesiboReadSession?.initSession("", groupid: UInt32(groupPeer) ?? 0, query: nil, delegate: self)
        }
        mesiboReadSession?.enableReadReceipt(true)
        mesiboReadSession?.enableFifo(true)
        mesiboReadSession?.read(10000);
        print("message read completed")
    }
    
    
    public func mesibo_(on message: MesiboMessage!) {
        print(message as Any);
        let str = String(decoding: message.message, as: UTF8.self)
        //        print(message.message)
        //        print(message.getSenderName());
        print(message.getSenderAddress() as Any);
        print(str)
        print(message.getStatus())
        print(message.isDbMessage())
    }
    
    public func mesibo_(onMessage params: MesiboParams! , data: Data!) {
        var message : String = ""
        
        message = String(bytes: data, encoding: String.Encoding.utf8) ?? ""
        
        var dic : NSMutableDictionary = NSMutableDictionary()
        
        dic.setValue(message, forKey: "message")
        dic.setValue(params.value(forKey: "_peer"), forKey: "peer")
        dic.setValue(params.value(forKey: "_ts"), forKey: "timestamp")
        dic.setValue(params.value(forKey: "_status"), forKey: "status")
        
        if !message.isEmpty {
            mEventSink?(dic)
        }
    }
    
    public func mesibo_(onMessageStatus params: MesiboParams!) {
        print(params)
    }
}


class StreamHandler: NSObject, FlutterStreamHandler, MesiboDelegate {
    
    func mesibo_(onConnectionStatus status: Int32) {
        print("Connecction Status %d",status)
        if status == MESIBO_STATUS_ONLINE {
            mEventSink?("Mesibo Connection Status : Online")
        }
    }
    
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        mEventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        mEventSink = nil
        return nil
    }
    // This method is called by the speech controller as mentioned above
    
}
