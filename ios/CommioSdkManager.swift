import React
import AVFAudio
import PushKit
import Foundation
import TwilioVoice
// import InfobipRTC

typealias IncomingCompletion = ()->Void

@objc(CommioSdkManager)

//final class CommioSdkManager: RCTEventEmitter, PhoneCallEventListener, IncomingApplicationCallEventListener{
final class CommioSdkManager: RCTEventEmitter{
    var identity: String {
        return UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    }
    static var pushCredentials: PKPushCredentials?
    //    static var voipToken: String?
    static var isUserLoggedIn: Bool = false
    static var incomingPayload: PKPushPayload?
    var incomingCompletion: IncomingCompletion?
    
    //     var voiceRTC: InfobipRTC {
    //         get {
    //             return getInfobipRTCInstance()
    //         }
    //     }
    
    let audioDeviceManager = AudioDeviceManager()
    
    override init() {
        super.init()
        audioDeviceManager.delegate = self
        CommioSdkManager.shared = self
    }
    
    
    private var hasListeners : Bool = false
    //    var outgoingCall: ApplicationCall?
    //    var incomingApplicationCall: IncomingApplicationCall?
    
    var activeCallInvites: [String: CallInvite]! = [:]
    var activeCalls: [String: Call]! = [:]
    
    // activeCall represents the last connected call
    var activeCall: Call? = nil
    var activeCallInvite: CallInvite? = nil
    
    static var shared: CommioSdkManager?
    
    override func supportedEvents() -> [String] {
        return [
            "onLogin",
            "onLoginFailed",
            "onLogout",
            "onIncomingCall",
            "onIncomingCallHangup",
            "onIncomingCallRejected",
            "onIncomingCallAnswered",
            "onIncomingCallInvalid",
            "onOutgoingCall",
            "onOutgoingCallAnswered",
            "onOutgoingCallRinging",
            "onOutgoingCallRejected",
            "onOutgoingCallHangup",
            "onOutgoingCallInvalid",
            "headphonesStateChanged"
        ]
    }
    
    override func startObserving() {
        print("CommioSdk ReactNativeEventEmitter startObserving")
        
        hasListeners = true
        
        super.startObserving()
    }
    
    override func stopObserving() {
        print("CommioSdk ReactNativeEventEmitter stopObserving")
        
        hasListeners = false
        
        super.stopObserving()
    }
    
    @objc static func checkIfLoggedIn() -> Bool{
        return CommioSdkManager.isUserLoggedIn
    }
    
    @objc func call(_ apiKey: String, token: String, environment: String, identity: String, contactId: String, destination: String, caller: String) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if(granted){
                // Make call with Twillio here...
                let connectOptions = ConnectOptions(accessToken: token) { builder in
                                        builder.params = ["twimlParamTo": destination ]
//                    builder.params = ["To": destination ]
                    builder.params = ["From": caller ]
                    //                    builder.uuid = UUID(uuidString: identity)
                }
                
                print("Twillio -- call --")
                let call = TwilioVoiceSDK.connect(options: connectOptions, delegate: CommioSdkManager.shared!)
                CommioSdkManager.shared!.activeCall = call
                //                CommioSdkManager.shared!.activeCalls[call.uuid!.uuidString] = call
                
                //                 let callApplicationRequest = CallApplicationRequest(token, applicationId: environment, applicationCallEventListener: CommioSdkManager.shared!)
                //
                //                 let customData = ["contactId": contactId, "fromNumber": caller, "toNumber": destination]
                //                 let applicationCallOptions = ApplicationCallOptions(audio: true, customData: customData, entityId: identity)
                //
                //                 do {
                //                   CommioSdkManager.shared!.outgoingCall = try CommioSdkManager.shared!.infobipRTC.callApplication(callApplicationRequest, applicationCallOptions)
                //                 } catch let ex {
                //                   print("outgoingCall (error) ===> ", ex.localizedDescription);
                //                 }
            }else{
                print("Microphone permission not granted")
                CommioSdkManager.shared?.sendEvent(withName: "onOutgoingCallHangup", body: "")
            }
        }
    }
    
    // func convertToDictionary(text: String) -> [String: Any]? {
    //     if let data = text.data(using: .utf8) {
    //         do {
    //             return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
    //         } catch {
    //             print(error.localizedDescription)
    //         }
    //     }
    //     return nil
    // }
    
    // func convertIncomingCallToObject(_ payload: PKPushPayload!) -> [String: Any] {
    //     let objCall = payload.dictionaryPayload
    
    
    //     let callId = objCall["callId"] as? String;
    //     let callerName = objCall["displayName"] as? String;
    //     let callerPhone = objCall["source"] as? String;
    //     let customDataString = objCall["customData"] as? String ?? "";
    
    //     let customData = convertToDictionary(text: customDataString)
    //     let contactId = customData?["contactId"] as? String ?? ""
    
    
    //     let body: [String: Any] = [
    //         "callId": callId ?? "",
    //         "callerPhone": callerPhone ?? "",
    //         "callerName": callerName ?? "",
    //         "callerId": contactId ,
    //     ];
    
    //     return body;
    // }
    
    
    @objc func handleIncomingCallFromCallKeep() {
        // let payload = CommioSdkManager.incomingPayload
        // if CommioSdkManager.shared!.infobipRTC.isIncomingApplicationCall(payload!) {
        
        //     CommioSdkManager.incomingPayload = payload
        //     CommioSdkManager.shared?.infobipRTC.handleIncomingApplicationCall(payload!, CommioSdkManager.shared!)
        // }
    }
    @objc static func setPushPayload(_ payload: PKPushPayload) {
        CommioSdkManager.incomingPayload = payload
        
    }
    
    @objc static func handleIncomingCall(_ payload: PKPushPayload, completion: @escaping IncomingCompletion) {
        // CommioSdkManager.shared?.incomingCompletion = completion
        // if ((CommioSdkManager.shared?.infobipRTC.isIncomingApplicationCall(payload)) != nil) {
        
        //     CommioSdkManager.incomingPayload = payload
        //     shared?.infobipRTC.handleIncomingApplicationCall(payload, shared!)
        // }
    }
    
    @objc func answer() {
        if let incomingCall = CommioSdkManager.shared?.activeCallInvite {
            let acceptOptions = AcceptOptions(callInvite: incomingCall) { builder in
                builder.uuid = incomingCall.uuid
            }
            
            let call = incomingCall.accept(options: acceptOptions, delegate: self)
            CommioSdkManager.shared!.activeCall = call;
        }
    }
    
    @objc func reject() {
        if let incomingCall = CommioSdkManager.shared?.activeCallInvite {
            incomingCall.reject()
        }
    }
    
    @objc func mute() {
        if let outgoingCall = CommioSdkManager.shared!.activeCall {
            outgoingCall.isMuted = true;
        }else if let incomingCall = CommioSdkManager.shared!.activeCallInvite {
            print("Not able to mute incoming call")
            //             do {
            //                 try incomingCall.mute(true)
            //             } catch _ {
            //
            //             }
        }
    }
    
    @objc func unmute() {
        if let outgoingCall = CommioSdkManager.shared!.activeCall {
            outgoingCall.isMuted = false;
        }else if let incomingCall = CommioSdkManager.shared!.activeCallInvite {
            print("Not able to mute incoming call")
        }
    }
    
    @objc func hangup() {
        if let outgoingCall = CommioSdkManager.shared!.activeCall {
            outgoingCall.disconnect()
        } else if let incomingCall = CommioSdkManager.shared!.activeCallInvite {
            print("Not able to hangup incoming call")
        }
    }
    
    @objc func setAudioDevice(_ device: Int) {
        CommioSdkManager.shared?.audioDeviceManager.setAudioDevice(type: device)
    }
    
    @objc func disablePushNotification(_ token: String) {
        print("Logout success! --- disablePushNotification --- ")
        CommioSdkManager.isUserLoggedIn = false;
        //         CommioSdkManager.shared?.infobipRTC.disablePushNotification(token)
        TwilioVoiceSDK.unregister(accessToken: token, deviceToken: CommioSdkManager.pushCredentials!.token) { error in
            if let error = error {
                print("An error occurred while unregistering: \(error.localizedDescription)")
            } else {
                print("Successfully unregistered from VoIP push notifications.")
            }
        }
    }
    
    @objc func registerPushNotification(_ token: String, pushConfigId: String) {
        if let credentials = CommioSdkManager.pushCredentials{
            CommioSdkManager.isUserLoggedIn = true;
            //             CommioSdkManager.shared?.infobipRTC.enablePushNotification(token, pushCredentials: credentials, debug: isDebug(), pushConfigId: pushConfigId) { result in
            //                 print("enablePushNotification result : \(result.status)")
            //                 print("enablePushNotification result : \(result.message)")
            //
            //             }
            /*
             * Perform registration if a new device token is detected.
             */
            TwilioVoiceSDK.register(accessToken: token, deviceToken: credentials.token) { error in
                if let error = error {
                    print("An error occurred while registering: \(error.localizedDescription)")
                } else {
                    print("Successfully registered for VoIP push notifications.")
                }
            }
        }else{
            print("pushCredentials are null")
        }
    }
    
    @objc static func registerPushCredentials(_ credentials: PKPushCredentials) {
        CommioSdkManager.pushCredentials = credentials
    }
    
    //    func onIncomingApplicationCall(_ incomingApplicationCallEvent: IncomingApplicationCallEvent) {
    // let body = convertIncomingCallToObject(CommioSdkManager.incomingPayload)
    // CommioSdkManager.shared?.sendEvent(withName: "onIncomingCall", body: body);
    
    // CommioSdkManager.shared?.incomingApplicationCall = incomingApplicationCallEvent.incomingApplicationCall
    // if let block = CommioSdkManager.shared?.incomingCompletion {
    //     block()
    // }
    // CommioSdkManager.shared?.incomingApplicationCall!.applicationCallEventListener = WebrtcCallListener(CommioSdkManager.shared!.incomingApplicationCall!)
    //    }
    
    @objc func isDebug() -> Bool {
#if DEBUG
        return true
        //        return false
#else
        return false
#endif
    }
}

extension CommioSdkManager: CallDelegate {
    
    func callDidStartRinging(call: Call) {
        print("callDidStartRinging \(call.sid)")
        CommioSdkManager.shared?.audioDeviceManager.isBluetoothDeviceConnected()
        CommioSdkManager.shared?.sendEvent(withName: "onOutgoingCallRinging", body: "");
    }
    func callDidConnect(call: Call) {
        print("callDidConnect")
    }
    
    func callDidFailToConnect(call: Call, error: Error) {
        print("callDidFailToConnect: \(error.localizedDescription)")
        CommioSdkManager.shared?.sendEvent(withName: "onOutgoingCallHangup", body: "")
    }
    
    func callDidDisconnect(call: Call, error: Error?) {
        print("callDidDisconnect: \(error?.localizedDescription)")
        CommioSdkManager.shared?.sendEvent(withName: "onOutgoingCallHangup", body: "")
    }
}



// extension CommioSdkManager: WebrtcCallEventListener, ApplicationCallEventListener {
//     func onEarlyMedia(_ callEarlyMediaEvent: CallEarlyMediaEvent) {
//         print("callEarlyMediaEvent triggered ==> ", callEarlyMediaEvent)
//         CommioSdkManager.shared?.audioDeviceManager.isBluetoothDeviceConnected()
//         CommioSdkManager.shared?.sendEvent(withName: "onOutgoingCallRinging", body: "");
//     }

//     func onEstablished(_ callEstablishedEvent: CallEstablishedEvent) {
//         CommioSdkManager.shared?.sendEvent(withName: "onOutgoingCallAnswered", body: "");
//     }

//     func onHangup(_ callHangupEvent: CallHangupEvent) {
//         CommioSdkManager.shared?.sendEvent(withName: "onOutgoingCallHangup", body: "")
//     }

//     func onError(_ errorEvent: ErrorEvent) {
//         CommioSdkManager.shared?.sendEvent(withName: "onIncomingCallInvalid", body: "");
//     }
// }

// extension CommioSdkManager: IncomingCallEventListener {

//     func onIncomingWebrtcCall(_ incomingWebrtcCallEvent: IncomingWebrtcCallEvent) {
//         //        self.incomingWebrtcCall = incomingWebrtcCallEvent.incomingWebrtcCall
//         //        self.incomingWebrtcCall!.webrtcCallEventListener = WebrtcCallListener(self.incomingWebrtcCall!)
//     }

// }

extension CommioSdkManager: AudioDeviceManagerDelegate {
    func didChangeHeadphonesState(connected: Bool) {
        // sendEvent(withName: "headphonesStateChanged", body: ["connected": connected])
    }
}

// @objc(WebrtcCallListener)

// class WebrtcCallListener: RCTEventEmitter, ApplicationCallEventListener{
//     func onRinging(_ callRingingEvent: CallRingingEvent) {
//         print("incoming call on ringing")
//     }

//     func onEstablished(_ callEstablishedEvent: CallEstablishedEvent) {
//         print("on call established...")
//         CommioSdkManager.shared?.sendEvent(withName: "onIncomingCallAnswered", body: "");
//         DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//             CommioSdkManager.shared?.audioDeviceManager.isBluetoothDeviceConnected()
//         }
//     }

//     func onHangup(_ callHangupEvent: CallHangupEvent) {
//         print("incoming call hang up")
//         let body = CommioSdkManager.shared?.convertIncomingCallToObject(CommioSdkManager.incomingPayload)
//         //        sendEvent(withName: "onIncomingCallHangup", body: "")
//         //        WebrtcCallListener.shared?.sendEvent(withName: "onIncomingCallHangup", body: "")
//         CommioSdkManager.shared?.sendEvent(withName: "onIncomingCallHangup", body: body)
//     }

//     let webrtcCall: IncomingApplicationCall

//     static var shared: WebrtcCallListener?

//     init(_ webrtcCall: IncomingApplicationCall) {
//         self.webrtcCall = webrtcCall
//         super.init()
//         WebrtcCallListener.shared = self
//     }


//     override func supportedEvents() -> [String] {
//         return [
//             "onLogin",
//             "onLoginFailed",
//             "onLogout",
//             "onIncomingCall",
//             "onIncomingCallHangup",
//             "onIncomingCallRejected",
//             "onIncomingCallAnswered",
//             "onIncomingCallInvalid",
//             "onOutgoingCall",
//             "onOutgoingCallAnswered",
//             "onOutgoingCallRinging",
//             "onOutgoingCallRejected",
//             "onOutgoingCallHangup",
//             "onOutgoingCallInvalid",
//             "headphonesStateChanged"
//         ]
//     }

//     private var hasListeners : Bool = false

//     override func startObserving() {
//         print("CommioSdk ReactNativeEventEmitter startObserving")

//         hasListeners = true

//         super.startObserving()
//     }

//     override func stopObserving() {
//         print("CommioSdk ReactNativeEventEmitter stopObserving")

//         hasListeners = false

//         super.stopObserving()
//     }
// }
