package com.example.mesibo_plugin

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.mesibo.api.Mesibo
import com.mesibo.api.Mesibo.ReadDbSession
import io.flutter.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.nio.charset.Charset
import kotlin.random.Random
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import kotlin.math.log


/** MesiboPlugin */
public class MesiboPlugin: FlutterPlugin, MethodCallHandler,Mesibo.MessageListener,ActivityAware {

  private lateinit var channel : MethodChannel
  private lateinit var statusEventChannel : EventChannel
  private lateinit var context: Context
  private lateinit var activity: Activity
  private val MESIBO_MESSAGING_CHANNEL = "mesibo_plugin"
    private val MESIBO_ACTIVITY_CHANNEL = "mesibo_plugin/mesiboEvents"
    private var MesiboErrorMessage = "Mesibo has not started yet, Check Credentials"
    private var mUserAccessToken:String = ""
    private var mPeer : String = ""
    private var groupPeer : String = ""
    private var mesibo:Mesibo = Mesibo.getInstance()
    private var mParameter : Mesibo.MessageParams = Mesibo.MessageParams("" , 0 , Mesibo.FLAG_DEFAULT , 0 )
    private var mesiboEventsHandler : MesiboEventsHandler = MesiboEventsHandler()
  lateinit var myplugin: MesiboPlugin
  override fun onDetachedFromActivity() {
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    myplugin.activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    myplugin = MesiboPlugin()
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, MESIBO_MESSAGING_CHANNEL)
    statusEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, MESIBO_ACTIVITY_CHANNEL)
    statusEventChannel.setStreamHandler(MesiboEventsHandler())
    channel.setMethodCallHandler(this)
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(),"mesibo_plugin")
      channel.setMethodCallHandler(MesiboPlugin())
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when ( call.method ){
      "setAccessToken" -> setAccessToken( call , result )
      "setToUserParam" -> setToUserParam( call , result )
      "setToGroupParam"-> setToGroupParam(call , result)
      "getRead" -> getConversation(call,result)
      "sendMessage" -> callSendMessage(call,result)
      "getUserStatus" -> getUserStatus( call , result )
      "setUserOffline" -> setUserOffline( call , result )
      "setUserOnline" -> setUserOnline( call , result )
      else -> { result.notImplemented() }
    }
//    if (call.method == "getPlatformVersion") {
//      result.success("Android ${android.os.Build.VERSION.RELEASE}")
//    } else {
//      result.notImplemented()
//    }
  }

  private fun getConversation(call: MethodCall, result: MethodChannel.Result) {
    var param = call.argument<List<String>>("Param");
    if( param != null ){
      var mPeer : String = param[0];
      groupPeer = param[1];

      var mReadSession : ReadDbSession
      Mesibo.setAppInForeground(context, 0, true)
      if ( groupPeer == "0" ) {
        mReadSession = ReadDbSession(mPeer,this);
      }else{
        mReadSession = ReadDbSession(groupPeer.toLong(), this);
      }

      mReadSession?.enableReadReceipt(true)
      mReadSession.enableFifo(true)
      mReadSession?.read(10000)
    }
  }

  private fun callSendMessage(call: MethodCall, result: MethodChannel.Result) {
    if ( !mPeer.isEmpty() ){
      var message = call.argument<String>("message")
      if( message != null ){
        mParameter?.expiry = (3600*24*7).toInt()
        mParameter?.setFlag( ( Mesibo.FLAG_DELIVERYRECEIPT or Mesibo.FLAG_READRECEIPT ).toInt() )
        var s = mParameter;

        val msgId: Long = Random.nextLong()
        Mesibo.sendReadReceipt( 0, mPeer,0 ,msgId);
        Mesibo.sendMessage(mParameter, msgId , message);
        mesiboEventsHandler.mEventSink?.success("Message Sent to "+mPeer)
      }
    }else if( !groupPeer.isEmpty() ){
      var message = call.argument<String>("message")
      if( message != null ){
        mParameter?.expiry = (3600*24*7).toInt()
        mParameter?.flag = ( Mesibo.FLAG_DELIVERYRECEIPT or Mesibo.FLAG_READRECEIPT ).toInt()

        val msgId: Long = Random.nextLong()

        Mesibo.sendMessage(mParameter, msgId , message);
        mesiboEventsHandler.mEventSink?.success("Message Sent to "+groupPeer)
      }
    } else{
      mEventSink?.success(MesiboErrorMessage);
    }
  }


  private fun setUserOnline(call: MethodCall, result: MethodChannel.Result) {
    Mesibo.start();
  }

  private fun setUserOffline(call: MethodCall, result: MethodChannel.Result) {
    Mesibo.stop(true);
  }

  private fun getUserStatus(call: MethodCall, result: MethodChannel.Result) {
    when( Mesibo.getConnectionStatus() ) {
      Mesibo.STATUS_ONLINE -> {
        print("Mesibo Connection Status : Online")
        mesiboEventsHandler.mEventSink?.success("Online")
      }
      Mesibo.STATUS_OFFLINE -> {
        print("Mesibo Connection Status : Offline")
        mesiboEventsHandler.mEventSink?.success("Offline")
      }
      else ->
        mesiboEventsHandler.mEventSink?.success("Mesibo Connection Status : Unknown StausCode mesibo.getConnectionStatus())")
    }
  }

  private fun setToUserParam(call: MethodCall, result: MethodChannel.Result) {
    //get credentials from flutter
    var param = call.argument<List<String>>( "Param" )
    if ( param != null ) {
      mPeer = param[0] as String // "mobile number"
      mParameter = Mesibo.MessageParams(mPeer,  0, Mesibo.FLAG_DEFAULT, 0)
    }
  }

  private fun setToGroupParam(call: MethodCall, result: MethodChannel.Result) {
    var param = call.argument<List<String>>( "Param" )
    if ( param != null ) {
      groupPeer = param[0] // "Group ID"
      mParameter?.setGroup(groupPeer.toLong())
      mesiboEventsHandler.mEventSink?.success("param set")
    }
  }

  private fun setAccessToken(call: MethodCall , result : MethodChannel.Result) {
    //get credentials from flutter
    val credentials = call.argument<List<String>> ("Credentials")
    if (credentials != null)
    {
      mUserAccessToken = credentials[0].toString()
      mPeer = credentials[1].toString()

      //start mesibo here
      mesiboInit()

      // set Mesibo MessageParams
      mParameter = Mesibo.MessageParams( mPeer, 0, Mesibo.FLAG_DEFAULT, 0)
    }
  }

  private fun mesiboInit() {
//    mesibo = Mesibo.getInstance();
    mesibo.init(context);
    /** add other listener - you can add any number of listeners */
    Mesibo.addListener(this);

    /** [Optional] enable to disable secure connection */
    Mesibo.setSecureConnection(true);

    /** Initialize web api to communicate with your own backend servers */
    //* set user access token
    Mesibo.setAccessToken(mUserAccessToken);

    checkAndRequestPermissions()

    var dbPath  = context.filesDir.path
//            activity?.applicationContext?.getFilesDir()?.getPath();

    // set path for storing DB and messaging files

    Mesibo.setPath(dbPath);
    Mesibo.setDatabase("myAppDb.db",0)
//    Mesibo.setDatabase("myAppDb.db", 0);

    // start mesibo
    var i: Int = Mesibo.start();
    Log.d("mesibo is start", i.toString())
  }

  private fun checkAndRequestPermissions(): Boolean {
    val writepermission = ContextCompat.checkSelfPermission(context, Manifest.permission.WRITE_EXTERNAL_STORAGE)

    val listPermissionsNeeded: MutableList<String> = ArrayList()

    if (writepermission != PackageManager.PERMISSION_GRANTED) {
      listPermissionsNeeded.add(Manifest.permission.WRITE_EXTERNAL_STORAGE)
    }

    if (!listPermissionsNeeded.isEmpty()) {
        if (myplugin.activity != null) {
            ActivityCompat.requestPermissions(myplugin.activity, listPermissionsNeeded.toTypedArray(), 1)
        }
      return false
    }
    return true
  }

  override fun Mesibo_onMessageStatus(p0: Mesibo.MessageParams?) {
    print(p0);
  }

  override fun Mesibo_onActivity(p0: Mesibo.MessageParams?, p1: Int) {
    print(p0);
  }

  override fun Mesibo_onLocation(p0: Mesibo.MessageParams?, p1: Mesibo.Location?) {
    print(p0);
  }

  override fun Mesibo_onMessage(params: Mesibo.MessageParams?, data: ByteArray?): Boolean {
    var message = ""
    try {
      message = data?.let { String(it, Charset.defaultCharset()) }.toString()
      if (!message.isEmpty()){
        var res : HashMap<String, Any> = HashMap<String, Any> () ;

        res.put( "message" ,  message.toString());
        res.put("peer" , params?.peer.toString());
        params?.ts?.let { res.put("timestamp" , it) };
        params?.status?.let { res.put("flag" , it) };

        mesiboEventsHandler.mEventSink?.success(res)
      }
      //Toast.makeText(this, ""+message, Toast.LENGTH_SHORT).show();
    } catch (e: Exception) {
      mesiboEventsHandler.mEventSink?.success(e)
      // return false;
    }
    return false
  }

  override fun Mesibo_onFile(p0: Mesibo.MessageParams?, p1: Mesibo.FileInfo?) {
    print(p0);
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }


}

var mEventSink: EventChannel.EventSink? = null

class MesiboEventsHandler(): EventChannel.StreamHandler , Mesibo.ConnectionListener  {
  var mEventSink: EventChannel.EventSink? = null

  override fun Mesibo_onConnectionStatus(status: Int) {
    Log.d("Connecction Status %d",  status.toString())
    if ( status == Mesibo.STATUS_ONLINE ) {
      Log.d("Connecction Status", "Mesibo Connection Status : Online" );
    }
  }

  override fun onListen(p0: Any?, p1: EventChannel.EventSink?) {
    this.mEventSink = p1
  }

  override fun onCancel(p0: Any?) {
    this.mEventSink = null
  }
}
