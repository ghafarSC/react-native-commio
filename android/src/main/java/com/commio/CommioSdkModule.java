package com.commio;

import android.content.Context;
import android.media.AudioManager;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.twilio.voice.Call;
import com.twilio.voice.CallException;
import com.twilio.voice.CallInvite;
import com.twilio.voice.CancelledCallInvite;
import com.twilio.voice.MessageListener;
import com.twilio.voice.RegistrationException;
import com.twilio.voice.RegistrationListener;
import com.twilio.voice.UnregistrationListener;
import com.twilio.voice.Voice;
import com.twilio.voice.ConnectOptions;

import java.lang.reflect.Type;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

@ReactModule(name = CommioSdkModule.NAME)

public class CommioSdkModule extends ReactContextBaseJavaModule {
    public static final String NAME = "CommioSdkManager";
    public static final String TAG = CommioSdkModule.class.getName();

    private final ReactApplicationContext reactContext;

    private Map<String, String> incomingCallPayload = null;
    private AudioManager myAudioManager;

    public static Map<String, String> extractValues(String input) {
        Map<String, String> resultMap = new HashMap<>();

        String[] keyValuePairs = input.split("&");
        for (String pair : keyValuePairs) {
            String[] keyValue = pair.split("=");
            if (keyValue.length == 2) {
                String key = keyValue[0];
                String value = keyValue[1];
                resultMap.put(key, value);
            } else {
                // Handle invalid key-value pairs
                System.out.println("Invalid key-value pair: " + pair);
            }
        }

        return resultMap;
    }

    @NonNull
    private WritableMap getIncomingCallObject(Map<String, String> mPayload) {
        String callId = mPayload.getOrDefault("twi_call_sid", "");
        String source = mPayload.getOrDefault("twi_from", "");

        String displayName = "";
        String contactId = "";

        try {
            Map<String, String> twiParams = extractValues(mPayload.getOrDefault("twi_params", ""));
            displayName = twiParams.get("callerName").replace("+", " ");
            contactId = twiParams.get("contactId");
        } catch (Exception e) {
            e.printStackTrace();
        }


        // Create map for params
        WritableMap payload = Arguments.createMap();

        // Put data to map
        payload.putString("callId", callId);
        payload.putString("callerPhone", source);
        payload.putString("callerName", displayName);
        payload.putString("callerId", contactId);

        payload.putString("name", displayName);
        payload.putBoolean("shouldDisplayCallUI", true);
        return payload;
    }

    Call.Listener callListener = callListener();
    private Call activeCall;
    private CallInvite activeCallInvite;

    public CommioSdkModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
//        this.voiceRTC = voiceRTC.getInstance();
        myAudioManager = (AudioManager) this.reactContext.getSystemService(Context.AUDIO_SERVICE);
    }

    private void sendEvent(ReactContext reactContext,
                           String eventName,
                           @Nullable WritableMap params) {
        reactContext
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(eventName, params);
    }

    @Override
    @NonNull
    public String getName() {
        return NAME;
    }

    @ReactMethod
    public void answer() {
        if (this.activeCallInvite != null) {
            this.activeCallInvite.accept(this.reactContext, callListener);
        } else {
            Log.w(NAME, "Incoming call is not exist in incomingMap");
        }
    }

    @ReactMethod
    public void reject() {
        if (this.activeCallInvite != null) {
            this.activeCallInvite.reject(this.reactContext);
        } else {
            Log.w(NAME, "Incoming call is not exist in incomingMap");
        }
    }

    @ReactMethod
    public void mute() {
        if (this.activeCall != null) {
            try {
                this.activeCall.mute(true);
            } catch (Exception e) {
                Log.e(NAME, "mute: " + e.getMessage());
            }
        }
    }

    @ReactMethod
    public void unmute() {
        if (this.activeCall != null) {
            try {
                this.activeCall.mute(false);
            } catch (Exception e) {
                Log.e(NAME, "unmute: " + e.getMessage());
            }
        }
    }

    @ReactMethod
    public void hangup() {
        if (this.activeCall != null) {
            this.activeCall.disconnect();
        }
    }

    @ReactMethod
    public void setAudioDevice(int device) {
        switch (device) {
            case 0: // 0 - Phone
                this.myAudioManager.setMode(AudioManager.MODE_IN_COMMUNICATION);
                this.myAudioManager.stopBluetoothSco();
                this.myAudioManager.setBluetoothScoOn(false);
                this.myAudioManager.setSpeakerphoneOn(false);
                break;
            case 1: // 1 - Speaker
                this.myAudioManager.setMode(AudioManager.MODE_NORMAL);
                this.myAudioManager.stopBluetoothSco();
                this.myAudioManager.setBluetoothScoOn(false);
                this.myAudioManager.setSpeakerphoneOn(true);
                break;
            case 2: // 2 - Bluetooth
                this.myAudioManager.setMode(AudioManager.MODE_IN_COMMUNICATION);
                this.myAudioManager.startBluetoothSco();
                this.myAudioManager.setBluetoothScoOn(true);
                break;
            default:
                Log.i(NAME, "setAudioDevice unknown device ==> " + device);
        }
    }

    @ReactMethod
    public void disablePushNotification(String token) {
//         this.commioRTC.disablePushNotification(token, this.reactContext);
        Voice.unregister(token, Voice.RegistrationChannel.FCM, "", new UnregistrationListener() {
            @Override
            public void onUnregistered(String accessToken, String fcmToken) {
                Log.i(TAG, "onUnregistered: ");
            }

            @Override
            public void onError(RegistrationException registrationException, String accessToken, String fcmToken) {
                Log.e(TAG, "onError: " + registrationException);
            }
        });
    }

    @ReactMethod
    public void registerAndroidPushNotification(String fcmToken, String rtcToken, String pushConfigId) {
//         this.commioRTC.enablePushNotification(rtcToken, this.reactContext, pushConfigId);
        Log.i(TAG, "registerAndroidPushNotification: " + rtcToken);
        Voice.register(rtcToken, Voice.RegistrationChannel.FCM, fcmToken, new RegistrationListener() {
            //            @Override
//            public void onRegistered(@NonNull String accessToken, @NonNull String fcmToken) {
//                Log.i(TAG, "onRegistered: Success");
//            }
//
//            @Override
//            public void onError(@NonNull RegistrationException registrationException, @NonNull String accessToken, @NonNull String fcmToken) {
//                Log.e(TAG, "on register Error: " + registrationException.getMessage());
//            }
            @Override
            public void onRegistered(@NonNull String accessToken, @NonNull String fcmToken) {
                Log.d(TAG, "Successfully registered FCM " + fcmToken);
            }

            @Override
            public void onError(@NonNull RegistrationException error,
                                @NonNull String accessToken,
                                @NonNull String fcmToken) {
                String message = String.format(
                        Locale.US,
                        "Registration Error: %d, %s",
                        error.getErrorCode(),
                        error.getMessage());
                Log.e(TAG, message);
//                Snackbar.make(coordinatorLayout, message, Snackbar.LENGTH_LONG).show();
            }
        });
    }

    @ReactMethod
    public void call(String apiKey, String token, String environment, String identity, String contactId, String to, String caller) {
//        Log.i(TAG, "testMethod: " + token);
        HashMap<String, String> params = new HashMap<>();
        params.put("To", to);
        params.put("From", caller);
        ConnectOptions connectOptions = new ConnectOptions.Builder(token)
                .params(params)
                .build();
        try {
            Voice.connect(this.reactContext, connectOptions, callListener);
        } catch (Exception e) {
            Log.e(NAME, "call: " + e.getMessage());
        }
    }

    @NonNull
    private Call.Listener callListener() {
        return new Call.Listener() {
            @Override
            public void onRinging(@NonNull Call call) {
                activeCall = call;
                if (CommioSdkModule.this.activeCallInvite != null) {
                    sendEvent(CommioSdkModule.this.reactContext, "onIncomingCallRinging", null);
                } else {
                    sendEvent(CommioSdkModule.this.reactContext, "onOutgoingCallRinging", null);
                }
                Log.e(TAG, "onRinging: ");
            }

            @Override
            public void onConnected(@NonNull Call call) {
                Log.d(TAG, "Connected");
                activeCall = call;

                if (CommioSdkModule.this.activeCallInvite != null) {
                    CommioSdkModule.this.sendEvent(
                            CommioSdkModule.this.reactContext, "onIncomingCallAnswered", null);
                } else {
                    sendEvent(CommioSdkModule.this.reactContext, "onOutgoingCallAnswered", null);
                }
            }

            @Override
            public void onReconnecting(@NonNull Call call, @NonNull CallException callException) {

            }

            @Override
            public void onReconnected(@NonNull Call call) {

            }

            @Override
            public void onDisconnected(@NonNull Call call, @Nullable CallException callException) {
                if (callException != null) {
                    Log.e(TAG, "onDisconnected: " + callException.getLocalizedMessage());
                }
                if (CommioSdkModule.this.activeCallInvite != null) {
                    WritableMap payload = getIncomingCallObject(CommioSdkModule.this.incomingCallPayload);
                    CommioSdkModule.this.sendEvent(
                            CommioSdkModule.this.reactContext, "onIncomingCallHangup", payload);
                    CommioSdkModule.this.incomingCallPayload = null;
                } else {
                    sendEvent(CommioSdkModule.this.reactContext, "onOutgoingCallHangup", null);
                }

                CommioSdkModule.this.activeCall = null;
                CommioSdkModule.this.activeCallInvite = null;
            }

            @Override
            public void onConnectFailure(@NonNull Call call, @NonNull CallException callException) {
                Log.e(TAG, "onConnectFailure: " + callException.getLocalizedMessage());
                if (CommioSdkModule.this.activeCallInvite != null) {
                    WritableMap payload = getIncomingCallObject(CommioSdkModule.this.incomingCallPayload);
                    CommioSdkModule.this.sendEvent(
                            CommioSdkModule.this.reactContext, "onIncomingCallHangup", payload);
                    CommioSdkModule.this.incomingCallPayload = null;
                } else {
                    sendEvent(CommioSdkModule.this.reactContext, "onOutgoingCallHangup", null);
                }
                CommioSdkModule.this.activeCall = null;
                CommioSdkModule.this.activeCallInvite = null;
            }
        };
    }

    @ReactMethod
    public void handleIncomingCall(String sPayload) {
        try {
            Gson gson = new Gson();
            Type type = new TypeToken<Map<String, String>>() {
            }.getType();
            Map<String, String> payload = gson.fromJson(sPayload, type);

            this.incomingCallPayload = payload;
            Voice.handleMessage(this.reactContext, payload, new MessageListener() {
                @Override
                public void onCallInvite(@NonNull CallInvite callInvite) {
                    CommioSdkModule.this.activeCallInvite = callInvite;
                    WritableMap payload = getIncomingCallObject(CommioSdkModule.this.incomingCallPayload);
                    sendEvent(CommioSdkModule.this.reactContext, "onIncomingCall", payload);
                }

                @Override
                public void onCancelledCallInvite(@NonNull CancelledCallInvite cancelledCallInvite, @Nullable CallException callException) {
                    WritableMap payload = getIncomingCallObject(CommioSdkModule.this.incomingCallPayload);
                    CommioSdkModule.this.sendEvent(
                            CommioSdkModule.this.reactContext, "onIncomingCallHangup", payload);
                    CommioSdkModule.this.incomingCallPayload = null;
                }
            });

//            if (this.commioRTC.isIncomingApplicationCall(payload) && CommioSdkModule.this.incomingCallPayload == null) {
//                //        if (this.commioRTC.isIncomingApplicationCall(payload)) {
//                this.incomingCallPayload = payload;
//                this.commioRTC.handleIncomingApplicationCall(payload, this.reactContext, this);
//            }
        } catch (Exception e) {
            Log.d(TAG, "handleIncomingCall: " + e.getMessage());
        }
    }

}
