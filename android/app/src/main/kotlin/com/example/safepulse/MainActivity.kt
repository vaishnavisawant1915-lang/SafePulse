package com.example.safepulse

import android.Manifest
import android.content.pm.PackageManager
import android.telephony.SmsManager
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "safepulse/sms"
    private val SMS_PERMISSION_REQUEST = 1001

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "sendSms" -> {

                    val phoneNumber = call.argument<String>("phone")
                    val message = call.argument<String>("message")

                    if (phoneNumber == null || message == null) {
                        result.error(
                            "INVALID_ARGUMENT",
                            "Phone number or message is missing",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    if (
                        checkSelfPermission(
                            Manifest.permission.SEND_SMS
                        ) != PackageManager.PERMISSION_GRANTED
                    ) {
                        ActivityCompat.requestPermissions(
                            this,
                            arrayOf(Manifest.permission.SEND_SMS),
                            SMS_PERMISSION_REQUEST
                        )

                        result.error(
                            "PERMISSION_DENIED",
                            "SMS permission is required.",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    try {
                        val smsManager = SmsManager.getDefault()

                        smsManager.sendTextMessage(
                            phoneNumber,
                            null,
                            message,
                            null,
                            null
                        )

                        result.success(true)

                    } catch (e: Exception) {
                        result.error(
                            "SMS_FAILED",
                            e.message,
                            null
                        )
                    }
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}