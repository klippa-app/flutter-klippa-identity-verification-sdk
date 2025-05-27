package com.klippa.identity_verification.klippa_identity_verification_sdk

import android.content.Intent
import com.klippa.identity_verification.modules.base.IdentitySession
import com.klippa.identity_verification.modules.base.IdentitySessionResultCode
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

/** KlippaIdentityVerificationSdkPlugin */
class KlippaIdentityVerificationSdkPlugin : FlutterPlugin, MethodCallHandler, ActivityAware,
    PluginRegistry.ActivityResultListener {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    private var activityPluginBinding: ActivityPluginBinding? = null

    companion object {
        private const val E_ACTIVITY_DOES_NOT_EXIST = "E_ACTIVITY_DOES_NOT_EXIST"
        private const val E_MISSING_SESSION_TOKEN = "E_MISSING_SESSION_TOKEN"
        private const val E_FAILED_TO_SHOW_SESSION = "E_FAILED_TO_SHOW_SESSION"
        private const val E_CANCELED = "E_CANCELED"
        private const val E_SUPPORT_PRESSED = "E_CONTACT_SUPPORT_PRESSED"

        private const val REQUEST_CODE = 99991801
    }

    private var resultHandler: Result? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel =
            MethodChannel(flutterPluginBinding.binaryMessenger, "klippa_identity_verification_sdk")
        channel.setMethodCallHandler(this)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.activityPluginBinding = binding
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        this.activityPluginBinding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        this.activityPluginBinding = binding
        binding.addActivityResultListener(this)
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
        val activity = activityPluginBinding?.activity ?: kotlin.run {
            result.error(E_ACTIVITY_DOES_NOT_EXIST, "Activity doesn't exist", null)
            return
        }

        try {
            if (!call.hasArgument("SessionToken")) {
                result.error(E_MISSING_SESSION_TOKEN, "Missing session token", null)
                return
            }

            val token = call.argument<String>("SessionToken")!!

            val identitySession = IdentitySession(
                token
            )

            call.argument<String>("Language")?.let { language ->
                when (language) {
                    "KIVLanguage.English" -> {
                        identitySession.language = IdentitySession.KIVLanguage.English
                    }
                    "KIVLanguage.Dutch" -> {
                        identitySession.language = IdentitySession.KIVLanguage.Dutch
                    }
                    "KIVLanguage.Spanish" -> {
                        identitySession.language = IdentitySession.KIVLanguage.Spanish
                    }
                    "KIVLanguage.German" -> {
                        identitySession.language = IdentitySession.KIVLanguage.German
                    }
                    "KIVLanguage.French" -> {
                        identitySession.language = IdentitySession.KIVLanguage.French
                    }
                }
            }

            call.argument<Boolean>("HasIntroScreen")?.let { hasIntroScreen ->
                identitySession.hasIntroScreen = hasIntroScreen
            }

            call.argument<Boolean>("HasSuccessScreen")?.let { hasSuccessScreen ->
                identitySession.hasSuccessScreen = hasSuccessScreen
            }

            call.argument<Boolean>("IsDebug")?.let { isDebug ->
                identitySession.isDebug = isDebug
            }

            call.argument<Boolean>("EnableAutoCapture")?.let { enableAutoCapture ->
                identitySession.enableAutoCapture = enableAutoCapture
            }

            call.argument<List<String>>("VerifyIncludeList")?.let { include ->
                identitySession.kivIncludeList = include
            }

            call.argument<List<String>>("VerifyExcludeList")?.let { exclude ->
                identitySession.kivExcludeList = exclude
            }

            call.argument<List<String>>("ValidationIncludeList")?.let { include ->
                identitySession.kivValidationIncludeList = include
            }

            call.argument<List<String>>("ValidationExcludeList")?.let { exclude ->
                identitySession.kivValidationExcludeList = exclude
            }

            call.argument<Int>("RetryThreshold")?.let { retryThreshold ->
                identitySession.retryThreshold = retryThreshold
            }

            call.argument<Double>("NfcTimeoutThreshold")?.let { nfcTimeoutThreshold ->
                identitySession.nfcTimeoutThreshold = nfcTimeoutThreshold
            }

            call.argument<Boolean>("AllowCameraOnNFCTask")?.let { allowCameraOnNFCTask ->
                identitySession.allowCameraOnNFCTask = allowCameraOnNFCTask
            }

            call.argument<Boolean>("ExitOnRetryThresholdReached")?.let { exitOnRetryThresholdReached ->
                identitySession.exitOnRetryThresholdReached = exitOnRetryThresholdReached
            }

            val intent = identitySession.getIntent(activity)
            resultHandler = result
            activity.startActivityForResult(intent, REQUEST_CODE)
        } catch (e: Exception) {
            result.error(
                E_FAILED_TO_SHOW_SESSION,
                "Could not launch identity verification session",
                e.message + "\n" + e.stackTrace
            )
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQUEST_CODE) {
            return false
        }

        val mappedResultCode = IdentitySessionResultCode.mapResultCode(resultCode)
        when (mappedResultCode) {
            IdentitySessionResultCode.FINISHED -> identityVerificationFinished()
            IdentitySessionResultCode.CONTACT_SUPPORT_PRESSED -> identityVerificationContactSupportPressed(
                mappedResultCode.message()
            )

            IdentitySessionResultCode.INSUFFICIENT_PERMISSIONS,
            IdentitySessionResultCode.INVALID_SESSION_TOKEN,
            IdentitySessionResultCode.USER_CANCELED,
            IdentitySessionResultCode.NO_INTERNET_CONNECTION,
            IdentitySessionResultCode.DEVICE_DOES_NOT_SUPPORT_NFC,
            IdentitySessionResultCode.DEVICE_NFC_DISABLED,
            IdentitySessionResultCode.TAKING_PHOTO_FAILED,
            IdentitySessionResultCode.UNKNOWN_ERROR,
            IdentitySessionResultCode.INCORRECT_SESSION_SETUP,
            IdentitySessionResultCode.ALLOW_PICTURE_FALLBACK_DISABLED,
            IdentitySessionResultCode.RETRY_LIMIT_REACHED -> identityVerificationCanceled(mappedResultCode.message())
        }

        return true
    }


    private fun identityVerificationFinished() {
        val resultMap = HashMap<String, Any>()
        resultHandler?.success(resultMap)
    }


    private fun identityVerificationCanceled(message: String) {
        resultHandler?.error(E_CANCELED, message, null)
    }

    private fun identityVerificationContactSupportPressed(message: String) {
        resultHandler?.error(E_SUPPORT_PRESSED, message, null)
    }


}
