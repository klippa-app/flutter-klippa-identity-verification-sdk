package com.klippa.identity_verification.klippa_identity_verification_sdk

import android.app.Activity
import android.content.Intent
import android.util.Log
import androidx.annotation.NonNull
import com.klippa.identity_verification.modules.base.IdentityBuilder
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

/** KlippaIdentityVerificationSdkPlugin */
class KlippaIdentityVerificationSdkPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  private var activityPluginBinding : ActivityPluginBinding? = null

  private val SESSION_REQUEST_CODE = 9293
  private val E_ACTIVITY_DOES_NOT_EXIST = "E_ACTIVITY_DOES_NOT_EXIST"
  private val E_MISSING_SESSION_TOKEN = "E_MISSING_SESSION_TOKEN"
  private val E_FAILED_TO_SHOW_SESSION = "E_FAILED_TO_SHOW_SESSION"
  private val E_CANCELED = "E_CANCELED"
  private val E_UNKNOWN_ERROR = "E_UNKNOWN_ERROR"
  private var resultHandler : Result? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "klippa_identity_verification_sdk")
    channel.setMethodCallHandler(this)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    this.activityPluginBinding = binding
  }

  override fun onDetachedFromActivityForConfigChanges() {
    this.activityPluginBinding = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    this.activityPluginBinding = binding
  }

  override fun onDetachedFromActivity() {
    this.activityPluginBinding = null
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "startSession") {
      startSession(call, result)
    } else {
      result.notImplemented()
    }
  }

  private fun startSession(@NonNull call: MethodCall, @NonNull result: Result) {
    if (activityPluginBinding == null) {
      result.error(E_ACTIVITY_DOES_NOT_EXIST, "Activity doesn't exist", null)
      return
    }

    try {
      if (!call.hasArgument("SessionToken")) {
        result.error(E_MISSING_SESSION_TOKEN, "Missing session token", null)
        return
      }

      val builder = IdentityBuilder(null, call.argument<String>("SessionToken")!!)

      if (call.hasArgument("Language")) {
        val language = call.argument<String>("Language")!!
        if (language == "KIVLanguage.English") {
          builder.language = IdentityBuilder.KIVLanguage.English
        } else if (language == "KIVLanguage.Dutch") {
          builder.language = IdentityBuilder.KIVLanguage.Dutch
        } else if (language == "KIVLanguage.Spanish") {
          builder.language = IdentityBuilder.KIVLanguage.Spanish
        }
      }

      if (call.hasArgument("HasIntroScreen")) {
        val hasIntroScreen = call.argument<Boolean>("HasIntroScreen")!!
        builder.hasIntroScreen = hasIntroScreen
      }

      if (call.hasArgument("HasSuccessScreen")) {
        val hasSuccessScreen = call.argument<Boolean>("HasSuccessScreen")!!
        builder.hasSuccessScreen = hasSuccessScreen
      }

      if (call.hasArgument("IsDebug")) {
        val isDebug = call.argument<Boolean>("IsDebug")!!
        builder.isDebug = isDebug
      }

      if (call.hasArgument("VerifyIncludeList")) {
        val include = call.argument<List<String>>("VerifyIxcludeList")!!
        builder.kivIncludeList = include
      }

      if (call.hasArgument("VerifyExcludeList")) {
        val exclude = call.argument<List<String>>("VerifyExcludeList")!!
        builder.kivExcludeList = exclude
      }

      val intent = builder.getIntent(activityPluginBinding!!.activity)
      resultHandler = result
      activityPluginBinding!!.addActivityResultListener(this)
      activityPluginBinding!!.activity.startActivityForResult(intent, SESSION_REQUEST_CODE)
    } catch (e: Exception) {
      result.error(E_FAILED_TO_SHOW_SESSION, "Could not launch identity verification session", e.message + "\n" + Log.getStackTraceString(e))
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    if (requestCode == SESSION_REQUEST_CODE) {
      if (resultHandler != null) {
        if (resultCode == Activity.RESULT_CANCELED) {
          resultHandler!!.error(E_CANCELED, "The user canceled", null);
        } else if (resultCode == Activity.RESULT_OK) {
          val resultMap: HashMap<String, Any?> = hashMapOf()
          resultHandler!!.success(resultMap)
        } else {
          resultHandler!!.error(E_UNKNOWN_ERROR, "Unknown error", null);
        }

        resultHandler = null;
      }

      return true;
    }
    return false;
  }
}
