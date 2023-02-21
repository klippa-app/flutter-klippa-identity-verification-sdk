package com.klippa.identity_verification.klippa_identity_verification_sdk

import android.util.Log
import androidx.annotation.NonNull
import com.klippa.identity_verification.model.KlippaError
import com.klippa.identity_verification.modules.base.IdentityBuilder
import com.klippa.identity_verification.modules.base.IdentityBuilder.IdentityBuilderListener
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** KlippaIdentityVerificationSdkPlugin */
class KlippaIdentityVerificationSdkPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, IdentityBuilderListener {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  private var activityPluginBinding : ActivityPluginBinding? = null

  companion object {
    private const val E_ACTIVITY_DOES_NOT_EXIST = "E_ACTIVITY_DOES_NOT_EXIST"
    private const val E_MISSING_SESSION_TOKEN = "E_MISSING_SESSION_TOKEN"
    private const val E_FAILED_TO_SHOW_SESSION = "E_FAILED_TO_SHOW_SESSION"
    private const val E_CANCELED = "E_CANCELED"
    private const val E_SUPPORT_PRESSED = "E_CONTACT_SUPPORT_PRESSED"
    private const val SESSION_REQUEST_CODE = 9293
  }



  private var resultHandler : Result? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
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

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "startSession") {
      startSession(call, result)
    } else {
      result.notImplemented()
    }
  }

  private fun startSession(call: MethodCall, result: Result) {
    if (activityPluginBinding == null) {
      result.error(E_ACTIVITY_DOES_NOT_EXIST, "Activity doesn't exist", null)
      return
    }

    try {
      if (!call.hasArgument("SessionToken")) {
        result.error(E_MISSING_SESSION_TOKEN, "Missing session token", null)
        return
      }

      val builder = IdentityBuilder(this, call.argument<String>("SessionToken")!!)

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
        val include = call.argument<List<String>>("VerifyIncludeList")!!
        builder.kivIncludeList = include
      }

      if (call.hasArgument("VerifyExcludeList")) {
        val exclude = call.argument<List<String>>("VerifyExcludeList")!!
        builder.kivExcludeList = exclude
      }

      val intent = builder.getIntent(activityPluginBinding!!.activity)
      resultHandler = result
      activityPluginBinding?.activity?.startActivity(intent)
    } catch (e: Exception) {
      result.error(E_FAILED_TO_SHOW_SESSION, "Could not launch identity verification session", e.message + "\n" + Log.getStackTraceString(e))
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun identityVerificationFinished() {
    resultHandler?.success(null)
  }

  override fun identityVerificationCanceled(error: KlippaError) {
    val err = when (error) {
      KlippaError.InsufficientPermissions -> "Insufficient permissions"
      KlippaError.InvalidSessionToken -> "Invalid session token"
      KlippaError.UserCanceled -> "User canceled session"
      KlippaError.NoInternetConnection -> "No internet connection"
    }

    resultHandler?.error(E_CANCELED, err, null)
  }

  override fun identityVerificationContactSupportPressed() {
    resultHandler?.error(E_SUPPORT_PRESSED, "Contact support pressed", null)
  }
}
