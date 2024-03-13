package com.commio;

import android.content.Context;
import android.media.AudioManager;
import android.net.Uri;
import android.telecom.PhoneAccount;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

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
import com.twilio.voice.RegistrationException;
import com.twilio.voice.RegistrationListener;
import com.twilio.voice.UnregistrationListener;
import com.twilio.voice.Voice;
import com.twilio.voice.ConnectOptions;

//import com.commio.webrtc.sdk.api.CommioRTC;
//import com.commio.webrtc.sdk.api.call.ApplicationCall;
//import com.commio.webrtc.sdk.api.call.IncomingApplicationCall;
//import com.commio.webrtc.sdk.api.event.call.CallEarlyMediaEvent;
//import com.commio.webrtc.sdk.api.event.call.CallEstablishedEvent;
//import com.commio.webrtc.sdk.api.event.call.CallHangupEvent;
//import com.commio.webrtc.sdk.api.event.call.CallRingingEvent;
//import com.commio.webrtc.sdk.api.event.call.CameraVideoAddedEvent;
//import com.commio.webrtc.sdk.api.event.call.CameraVideoUpdatedEvent;
//import com.commio.webrtc.sdk.api.event.call.ConferenceJoinedEvent;
//import com.commio.webrtc.sdk.api.event.call.ConferenceLeftEvent;
//import com.commio.webrtc.sdk.api.event.call.DialogJoinedEvent;
//import com.commio.webrtc.sdk.api.event.call.DialogLeftEvent;
//import com.commio.webrtc.sdk.api.event.call.ErrorEvent;
//import com.commio.webrtc.sdk.api.event.call.ParticipantCameraVideoAddedEvent;
//import com.commio.webrtc.sdk.api.event.call.ParticipantCameraVideoRemovedEvent;
//import com.commio.webrtc.sdk.api.event.call.ParticipantDeafEvent;
//import com.commio.webrtc.sdk.api.event.call.ParticipantJoinedEvent;
//import com.commio.webrtc.sdk.api.event.call.ParticipantJoiningEvent;
//import com.commio.webrtc.sdk.api.event.call.ParticipantLeftEvent;
//import com.commio.webrtc.sdk.api.event.call.ParticipantMutedEvent;
//import com.commio.webrtc.sdk.api.event.call.ParticipantScreenShareAddedEvent;
//import com.commio.webrtc.sdk.api.event.call.ParticipantScreenShareRemovedEvent;
//import com.commio.webrtc.sdk.api.event.call.ParticipantStartedTalkingEvent;
//import com.commio.webrtc.sdk.api.event.call.ParticipantStoppedTalkingEvent;
//import com.commio.webrtc.sdk.api.event.call.ParticipantUndeafEvent;
//import com.commio.webrtc.sdk.api.event.call.ParticipantUnmutedEvent;
//import com.commio.webrtc.sdk.api.event.call.ReconnectedEvent;
//import com.commio.webrtc.sdk.api.event.call.ReconnectingEvent;
//import com.commio.webrtc.sdk.api.event.call.ScreenShareAddedEvent;
//import com.commio.webrtc.sdk.api.event.call.ScreenShareRemovedEvent;
//import com.commio.webrtc.sdk.api.event.listener.ApplicationCallEventListener;
//import com.commio.webrtc.sdk.api.event.listener.EventListener;
//import com.commio.webrtc.sdk.api.event.listener.IncomingApplicationCallEventListener;
//import com.commio.webrtc.sdk.api.event.rtc.IncomingApplicationCallEvent;
//import com.commio.webrtc.sdk.api.exception.ActionFailedException;
//import com.commio.webrtc.sdk.api.exception.IllegalStatusException;
//import com.commio.webrtc.sdk.api.exception.MissingPermissionsException;
//import com.commio.webrtc.sdk.api.model.push.EnablePushNotificationResult;
//import com.commio.webrtc.sdk.api.options.ApplicationCallOptions;
//import com.commio.webrtc.sdk.api.options.DeclineOptions;
//import com.commio.webrtc.sdk.api.request.CallApplicationRequest;

import java.lang.reflect.Type;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

@ReactModule(name = CommioSdkModule.NAME)
//public class CommioSdkModule extends ReactContextBaseJavaModule implements ApplicationCallEventListener, IncomingApplicationCallEventListener {
public class CommioSdkModule extends ReactContextBaseJavaModule {
    public static final String NAME = "CommioSdkManager";
    public static final String TAG = CommioSdkModule.class.getName();

    private final ReactApplicationContext reactContext;
    //    private final Voice voiceRTC;
//    private ApplicationCall outgoingCall;
//    private IncomingApplicationCall incomingCall;
    private Map<String, String> incomingCallPayload = null;
    private AudioManager myAudioManager;

    Call.Listener callListener = callListener();
    private Call activeCall;

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

    // @ReactMethod
    // public void answer() {
    //     if (this.incomingCall != null) {
    //         this.incomingCall.accept();
    //     } else {
    //         Log.w(NAME, "Incoming call is not exist in incomingMap");
    //     }
    // }

     @ReactMethod
     public void reject() {
         if (this.activeCall != null) {
             this.activeCall.disconnect();
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
            return;
        }

//         if (this.outgoingCall != null) {
//             try {
//                 this.outgoingCall.mute(true);
//             } catch (Exception e) {
//                 Log.e(NAME, "mute: " + e.getMessage());
//             }
//         }
    }

    @ReactMethod
    public void unmute() {
        if (this.activeCall != null) {
            try {
                this.activeCall.mute(false);
            } catch (Exception e) {
                Log.e(NAME, "unmute: " + e.getMessage());
            }
            return;
        }

//         if (this.outgoingCall != null) {
//             try {
//                 this.outgoingCall.mute(false);
//             } catch (Exception e) {
//                 Log.e(NAME, "unmute: " + e.getMessage());
//             }
//         }
    }

    @ReactMethod
    public void hangup() {
        if (this.activeCall != null) {
            this.activeCall.disconnect();
            return;
        }

//         if (this.outgoingCall != null) {
//             try {
//                 this.outgoingCall.hangup();
//             } catch (Exception e) {
//                 Log.e(NAME, "hangup: " + e.getMessage());
//             }
//         }
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

//  @ReactMethod
//     public void call(String apiKey, String token, String environment, String identity, String contactId, String destination, String caller) {
//    Log.i(TAG, "testMethod: ");
//     }

    @ReactMethod
    public void call(String apiKey, String token, String environment, String identity, String contactId, String to, String caller) {
        Log.i(TAG, "testMethod: " + token);
        HashMap<String, String> params = new HashMap<>();
//        final Uri recipient = Uri.fromParts(PhoneAccount.SCHEME_TEL, to, null);
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

//        CallApplicationRequest callApplicationRequest = new CallApplicationRequest(token, this.reactContext, environment, this);
//
//        String[] customDataKeys = {"contactId", "fromNumber", "toNumber"};
//        String[] customDataValues = {contactId, caller, destination};
//
//        Map<String, String> customData = new HashMap<>();
//
//        for (int i = 0; i < customDataKeys.length; i++) {
//            customData.put(customDataKeys[i], customDataValues[i]);
//        }
//
//        ApplicationCallOptions applicationCallOptions = ApplicationCallOptions.builder().audio(true).entityId(identity).customData(customData).build();
//
//        try {
//            this.outgoingCall = this.commioRTC.callApplication(callApplicationRequest, applicationCallOptions);
//        } catch (Exception e) {
//            Log.e(NAME, "call: " + e.getMessage());
//        }
    }

    @NonNull
    private Call.Listener callListener() {
        return new Call.Listener() {
            @Override
            public void onConnectFailure(@NonNull Call call, @NonNull CallException callException) {
                Log.e(TAG, "onConnectFailure: " + callException.getLocalizedMessage());
                sendEvent(CommioSdkModule.this.reactContext, "onOutgoingCallHangup", null);
            }

            @Override
            public void onRinging(@NonNull Call call) {
                activeCall = call;
                sendEvent(CommioSdkModule.this.reactContext, "onOutgoingCallRinging", null);
                Log.e(TAG, "onRinging: " );
            }

            @Override
            public void onConnected(@NonNull Call call) {

                Log.d(TAG, "Connected");
                activeCall = call;
                sendEvent(CommioSdkModule.this.reactContext, "onOutgoingCallAnswered", null);


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
                sendEvent(CommioSdkModule.this.reactContext, "onOutgoingCallHangup", null);

            }
        };
    }

//     @ReactMethod
//     public void handleIncomingCall(String sPayload) {
//
//
//         try {
//             Gson gson = new Gson();
//             Type type = new TypeToken<Map<String, String>>() {
//             }.getType();
//             Map<String, String> payload = gson.fromJson(sPayload, type);
// //            WritableMap mPayload = getIncomingCallObject(payload);
// //        sendEvent(this.reactContext, "onIncomingCall", mPayload);
//
//             if (this.commioRTC.isIncomingApplicationCall(payload) && CommioSdkModule.this.incomingCallPayload == null) {
// //        if (this.commioRTC.isIncomingApplicationCall(payload)) {
//                 this.incomingCallPayload = payload;
//                 this.commioRTC.handleIncomingApplicationCall(payload, this.reactContext, this);
//             }
//         } catch (Exception e) {
//             Log.d(TAG, "handleIncomingCall: " + e.getMessage());
//         }
//     }

//     @Override
//     public void onIncomingApplicationCall(@NonNull IncomingApplicationCallEvent incomingApplicationCallEvent) {
//         this.incomingCall = incomingApplicationCallEvent.getIncomingApplicationCall();

//         WritableMap payload = getIncomingCallObject(this.incomingCallPayload);

//         this.incomingCall.setEventListener(new ApplicationCallEventListener() {
//             @Override
//             public void onRinging(CallRingingEvent callRingingEvent) {

//             }

//             @Override
//             public void onEarlyMedia(CallEarlyMediaEvent callEarlyMediaEvent) {

//             }

//             @Override
//             public void onEstablished(CallEstablishedEvent callEstablishedEvent) {
//                 CommioSdkModule.this.sendEvent(
//                         CommioSdkModule.this.reactContext, "onIncomingCallAnswered", null);
//             }

//             @Override
//             public void onHangup(CallHangupEvent callHangupEvent) {
//                 WritableMap payload = getIncomingCallObject(CommioSdkModule.this.incomingCallPayload);
//                 CommioSdkModule.this.sendEvent(
//                         CommioSdkModule.this.reactContext, "onIncomingCallHangup", payload);
//                 CommioSdkModule.this.incomingCallPayload = null;
//             }

//         });

//         sendEvent(this.reactContext, "onIncomingCall", payload);
//     }

//     @NonNull
//     private WritableMap getIncomingCallObject(Map<String, String> mPayload) {
//         String callId = mPayload.getOrDefault("callId", "");
//         String source = mPayload.getOrDefault("source", "");
//         String displayName = mPayload.getOrDefault("displayName", "");
//         String contactId = mPayload.getOrDefault("contactId", "");

//         // Create map for params
//         WritableMap payload = Arguments.createMap();

//         // Put data to map
//         payload.putString("callId", callId);
//         payload.putString("callerPhone", source);
//         payload.putString("callerName", displayName);
//         payload.putString("callerId", contactId);

//         payload.putString("name", displayName);
//         payload.putBoolean("shouldDisplayCallUI", true);
//         return payload;
//     }



//     @Override
//     public void onEstablished(CallEstablishedEvent callEstablishedEvent) {
//         sendEvent(this.reactContext, "onOutgoingCallAnswered", null);
//     }

//     @Override
//     public void onHangup(CallHangupEvent callHangupEvent) {
//         sendEvent(this.reactContext, "onOutgoingCallHangup", null);
//     }

}
