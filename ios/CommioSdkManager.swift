import React
import AVFAudio
import PushKit
import Foundation
import TwilioVoice

typealias IncomingCompletion = ()->Void

@objc(CommioSdkManager)

final class CommioSdkManager: RCTEventEmitter{
    
    var identity: String {
        return UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    }
    static var pushCredentials: PKPushCredentials?
    static var isUserLoggedIn: Bool = false
    static var isAppKilled: Bool = false
    static var incomingPayload: PKPushPayload?
    var incomingCompletion: IncomingCompletion?
    
    let audioDeviceManager = AudioDeviceManager()
    
    override init() {
        super.init()
        audioDeviceManager.delegate = self
        CommioSdkManager.shared = self
    }
    
    private var hasListeners : Bool = false
    
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
                let connectOptions = ConnectOptions(accessToken: token) { builder in
                    builder.params = ["To": destination, "From": caller ]
                    builder.uuid = UUID(uuidString: environment)
                }
                
                print("Twillio -- call --")
                let call = TwilioVoiceSDK.connect(options: connectOptions, delegate: CommioSdkManager.shared!)
                CommioSdkManager.shared!.activeCall = call
            }else{
                print("Microphone permission not granted")
                CommioSdkManager.shared?.sendEvent(withName: "onOutgoingCallHangup", body: "")
            }
        }
    }
    
    func convertToDictionary(text: String) -> [String: String]? {
        var dictionary = [String: String]()
        let pairs = text.components(separatedBy: "&")
        for pair in pairs {
            let keyValue = pair.components(separatedBy: "=")
            if keyValue.count == 2 {
                let key = keyValue[0]
                let value = keyValue[1].replacingOccurrences(of: "+", with: " ")
                dictionary[key] = value
            }
        }
        return dictionary.isEmpty ? nil : dictionary
    }

    func convertIncomingCallToObject(_ payload: PKPushPayload!) -> [String: Any] {
        guard let objCall = payload.dictionaryPayload as? [String: Any],
//              let callId = objCall["twi_call_sid"] as? String,
              let callerPhone = objCall["twi_from"] as? String,
              let customDataString = objCall["twi_params"] as? String else {
            return [:] // Return empty dictionary if any required key is missing
        }

        let customData = convertToDictionary(text: customDataString)
        let contactId = customData?["contactId"] ?? ""
        let callerName = customData?["callerName"] ?? ""

        let body: [String: Any] = [
//            "callId": callId,
            "callId": contactId,
            "callerPhone": callerPhone,
            "callerName": callerName,
            "callerId": contactId,
            "shouldDisplayCallUI": false,
        ]

        return body
    }
    
    @objc func handleIncomingCallFromCallKeep() {
        let payload = CommioSdkManager.incomingPayload
        CommioSdkManager.shared?.incomingCompletion = nil
        if payload != nil {
            TwilioVoiceSDK.handleNotification(payload: payload!.dictionaryPayload, delegate: CommioSdkManager.shared!, delegateQueue: nil, callMessageDelegate: nil)
        }
    }
    @objc static func setPushPayload(_ payload: PKPushPayload) {
        CommioSdkManager.incomingPayload = payload
    }
    
    @objc static func handleIncomingCall(_ payload: PKPushPayload, completion: @escaping IncomingCompletion) {
        CommioSdkManager.shared?.incomingCompletion = completion
        CommioSdkManager.incomingPayload = payload
        TwilioVoiceSDK.handleNotification(payload: payload.dictionaryPayload, delegate: shared!, delegateQueue: nil, callMessageDelegate: nil)
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
        if let ongoingCall = CommioSdkManager.shared?.activeCall {
            ongoingCall.disconnect();
        }
        if let incomingCall = CommioSdkManager.shared?.activeCallInvite {
            incomingCall.reject();
        }
    }
    
    @objc func mute() {
        if let outgoingCall = CommioSdkManager.shared!.activeCall {
            outgoingCall.isMuted = true;
        }
    }
    
    @objc func unmute() {
        if let outgoingCall = CommioSdkManager.shared!.activeCall {
            outgoingCall.isMuted = false;
        }
    }
    
    @objc func hangup() {
        if let outgoingCall = CommioSdkManager.shared!.activeCall {
            outgoingCall.disconnect()
        }
    }
    
    @objc func setAudioDevice(_ device: Int) {
        CommioSdkManager.shared?.audioDeviceManager.setAudioDevice(type: device)
    }
    
    @objc func disablePushNotification(_ token: String) {
        print("Logout success! --- disablePushNotification --- ")
        CommioSdkManager.isUserLoggedIn = false;
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
//        print("callDidStartRinging \(call.sid)")
        if CommioSdkManager.shared!.activeCallInvite != nil {
//            CommioSdkManager.shared?.sendEvent(withName: "onIncomingCallRinging", body: "");
        } else {
            CommioSdkManager.shared?.audioDeviceManager.isBluetoothDeviceConnected()
            CommioSdkManager.shared?.sendEvent(withName: "onOutgoingCallRinging", body: "");
        }
    }
    func callDidConnect(call: Call) {
//        print("callDidConnect")
        if CommioSdkManager.shared!.activeCallInvite != nil {
            CommioSdkManager.shared?.sendEvent(withName: "onIncomingCallAnswered", body: "");
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                CommioSdkManager.shared?.audioDeviceManager.isBluetoothDeviceConnected()
            }
        } else {
            CommioSdkManager.shared?.sendEvent(withName: "onOutgoingCallAnswered", body: "");
        }
    }
    
    func callDidFailToConnect(call: Call, error: Error) {
//        print("callDidFailToConnect: \(error.localizedDescription)")
        
        if CommioSdkManager.shared!.activeCallInvite != nil {
            let body = CommioSdkManager.shared?.convertIncomingCallToObject(CommioSdkManager.incomingPayload)
            CommioSdkManager.shared?.sendEvent(withName: "onIncomingCallHangup", body: body)
        } else {
            CommioSdkManager.shared?.sendEvent(withName: "onOutgoingCallHangup", body: "")
        }
        CommioSdkManager.shared!.activeCallInvite = nil;
        CommioSdkManager.shared!.activeCall = nil;
    }
    
    func callDidDisconnect(call: Call, error: Error?) {
//        print("callDidDisconnect: \(error?.localizedDescription)")
        if CommioSdkManager.shared!.activeCallInvite != nil {
            let body = CommioSdkManager.shared?.convertIncomingCallToObject(CommioSdkManager.incomingPayload)
            CommioSdkManager.shared?.sendEvent(withName: "onIncomingCallHangup", body: body)
        } else {
            CommioSdkManager.shared?.sendEvent(withName: "onOutgoingCallHangup", body: "")
        }
        CommioSdkManager.shared!.activeCallInvite = nil;
        CommioSdkManager.shared!.activeCall = nil;
    }
}

extension CommioSdkManager: NotificationDelegate {
    func callInviteReceived(callInvite: CallInvite) {
        CommioSdkManager.shared!.activeCallInvite = callInvite;
        
        let body = convertIncomingCallToObject(CommioSdkManager.incomingPayload)
        CommioSdkManager.shared?.sendEvent(withName: "onIncomingCall", body: body);
        
        if let block = CommioSdkManager.shared?.incomingCompletion {
            block()
        }
    }
    
    func cancelledCallInviteReceived(cancelledCallInvite: CancelledCallInvite, error: Error) {
//        NSLog("cancelledCallInviteCanceled:error:, error: \(error.localizedDescription)")
        
        let body = convertIncomingCallToObject(CommioSdkManager.incomingPayload)
        CommioSdkManager.shared?.sendEvent(withName: "onIncomingCallHangup", body: body)
        
        CommioSdkManager.shared!.activeCallInvite = nil;
        CommioSdkManager.shared!.activeCall = nil;
    }
}

extension CommioSdkManager: AudioDeviceManagerDelegate {
    func didChangeHeadphonesState(connected: Bool) {
         sendEvent(withName: "headphonesStateChanged", body: ["connected": connected])
    }
}
