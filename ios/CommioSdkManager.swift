import React
import AVFAudio
import PushKit
import Foundation
// import InfobipRTC

typealias IncomingCompletion = ()->Void

@objc(CommioSdkManager)

final class CommioSdkManager: RCTEventEmitter, PhoneCallEventListener, IncomingApplicationCallEventListener{
    
    
    var identity: String {
        return UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    }
    static var pushCredentials: PKPushCredentials?
    //    static var voipToken: String?
    static var isUserLoggedIn: Bool = false
    static var incomingPayload: PKPushPayload?
    var incomingCompletion: IncomingCompletion?
    
    // var infobipRTC: InfobipRTC {
    //     get {
    //         return getInfobipRTCInstance()
    //     }
    // }
    
    let audioDeviceManager = AudioDeviceManager()
    
    override init() {
        super.init()
        audioDeviceManager.delegate = self
        CommioSdkManager.shared = self
    }
    
    
    private var hasListeners : Bool = false
    var outgoingCall: ApplicationCall?
    var incomingApplicationCall: IncomingApplicationCall?
    
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
        // Make call with Twillio here...

        print("Twillio -- call --")


        // AVAudioSession.sharedInstance().requestRecordPermission { granted in
        //     if(granted){
        //         let callApplicationRequest = CallApplicationRequest(token, applicationId: environment, applicationCallEventListener: CommioSdkManager.shared!)
                
        //         let customData = ["contactId": contactId, "fromNumber": caller, "toNumber": destination]
        //         let applicationCallOptions = ApplicationCallOptions(audio: true, customData: customData, entityId: identity)
                
        //         do {
        //             CommioSdkManager.shared!.outgoingCall = try CommioSdkManager.shared!.infobipRTC.callApplication(callApplicationRequest, applicationCallOptions)
        //         } catch let ex {
        //             print("outgoingCall (error) ===> ", ex.localizedDescription);
        //         }
        //     }else{
        //         print("Microphone permission not granted")
        //         CommioSdkManager.shared?.sendEvent(withName: "onOutgoingCallHangup", body: "")
        //     }
        // }
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
        // if let incomingCall = CommioSdkManager.shared?.incomingApplicationCall {
        //     incomingCall.accept()
        // }
    }
    
    @objc func reject() {
        // if let incomingCall = CommioSdkManager.shared?.incomingApplicationCall {
        //     incomingCall.decline(DeclineOptions(true))
        // }
    }
    
    @objc func mute() {
        // if let incomingCall = CommioSdkManager.shared?.incomingApplicationCall {
        //     do {
        //         try incomingCall.mute(true)
        //     } catch _ {
                
        //     }
        // } else if let outgoingCall = CommioSdkManager.shared?.outgoingCall {
        //     do {
        //         try outgoingCall.mute(true)
        //     } catch _ {
                
        //     }
        // }
    }
    
    @objc func unmute() {
        // if let incomingCall = CommioSdkManager.shared?.incomingApplicationCall {
        //     do {
        //         try incomingCall.mute(false)
        //     } catch _ {
                
        //     }
        // } else if let outgoingCall = CommioSdkManager.shared?.outgoingCall {
        //     do {
        //         try outgoingCall.mute(false)
        //     } catch _ {
                
        //     }
        // }
    }
    
    @objc func hangup() {
        // print("hangup called...")
        // if let incomingCall = CommioSdkManager.shared?.incomingApplicationCall {
        //     incomingCall.hangup()
        // } else if let outgoingCall = CommioSdkManager.shared?.outgoingCall {
        //     outgoingCall.hangup()
        // }
    }
    
    @objc func setAudioDevice(_ device: Int) {
        CommioSdkManager.shared?.audioDeviceManager.setAudioDevice(type: device)
    }
    
    @objc func disablePushNotification(_ token: String) {
        print("Logout success! --- disablePushNotification --- ")
        CommioSdkManager.isUserLoggedIn = false;
        // CommioSdkManager.shared?.infobipRTC.disablePushNotification(token)
    }
    
    @objc func registerPushNotification(_ token: String, pushConfigId: String) {
        // if let credentials = CommioSdkManager.pushCredentials{
        //     CommioSdkManager.isUserLoggedIn = true;
        //     CommioSdkManager.shared?.infobipRTC.enablePushNotification(token, pushCredentials: credentials, debug: isDebug(), pushConfigId: pushConfigId) { result in
        //         print("enablePushNotification result : \(result.status)")
        //         print("enablePushNotification result : \(result.message)")
                
        //     }
        // }else{
        //     print("pushCredentials are null")
        // }
    }
    @objc static func registerPushCredentials(_ credentials: PKPushCredentials) {
        // CommioSdkManager.pushCredentials = credentials
    }
    
    func onIncomingApplicationCall(_ incomingApplicationCallEvent: IncomingApplicationCallEvent) {
        // let body = convertIncomingCallToObject(CommioSdkManager.incomingPayload)
        // CommioSdkManager.shared?.sendEvent(withName: "onIncomingCall", body: body);
        
        // CommioSdkManager.shared?.incomingApplicationCall = incomingApplicationCallEvent.incomingApplicationCall
        // if let block = CommioSdkManager.shared?.incomingCompletion {
        //     block()
        // }
        // CommioSdkManager.shared?.incomingApplicationCall!.applicationCallEventListener = WebrtcCallListener(CommioSdkManager.shared!.incomingApplicationCall!)
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



// extension CommioSdkManager: WebrtcCallEventListener, ApplicationCallEventListener {
//     func onScreenShareRemoved(_ screenShareRemovedEvent: ScreenShareRemovedEvent) {
        
//     }
//     func onConferenceJoined(_ conferenceJoinedEvent: ConferenceJoinedEvent) {
//         print("event triggered: ", conferenceJoinedEvent)
//     }
    
//     func onConferenceLeft(_ conferenceLeftEvent: ConferenceLeftEvent) {
//         print("conferenceLeftEvent triggered: ", conferenceLeftEvent)
//     }
    
//     func onParticipantJoining(_ participantJoiningEvent: ParticipantJoiningEvent) {
//         print("participantJoiningEvent triggered: ", participantJoiningEvent)
//     }
    
//     func onParticipantJoined(_ participantJoinedEvent: ParticipantJoinedEvent) {
//         print("participantJoinedEvent triggered: ", participantJoinedEvent)
//     }
    
//     func onParticipantLeft(_ participantLeftEvent: ParticipantLeftEvent) {
//         print("participantLeftEvent triggered: ", participantLeftEvent)
//     }
    
//     func onParticipantCameraVideoAdded(_ participantCameraVideoAddedEvent: ParticipantCameraVideoAddedEvent) {
//         print("participantCameraVideoAddedEvent triggered: ", participantCameraVideoAddedEvent)
//     }
    
//     func onParticipantCameraVideoRemoved(_ participantCameraVideoRemovedEvent: ParticipantCameraVideoRemovedEvent) {
//         print("participantCameraVideoRemovedEvent triggered: ", participantCameraVideoRemovedEvent)
//     }
    
//     func onParticipantScreenShareAdded(_ participantScreenShareAddedEvent: ParticipantScreenShareAddedEvent) {
//         print("participantScreenShareAddedEvent triggered: ", participantScreenShareAddedEvent)
//     }
    
//     func onParticipantScreenShareRemoved(_ participantScreenShareRemovedEvent: ParticipantScreenShareRemovedEvent) {
//         print("participantScreenShareRemovedEvent triggered: ", participantScreenShareRemovedEvent)
//     }
    
//     func onParticipantMuted(_ participantMutedEvent: ParticipantMutedEvent) {
//         print("participantMutedEvent triggered: ", participantMutedEvent)
//     }
    
//     func onParticipantUnmuted(_ participantUnmutedEvent: ParticipantUnmutedEvent) {
//         print("participantUnmutedEvent triggered: ", participantUnmutedEvent)
//     }
    
//     func onParticipantDeaf(_ participantDeafEvent: ParticipantDeafEvent) {
//         print("participantDeafEvent triggered: ", participantDeafEvent)
//     }
    
//     func onParticipantUndeaf(_ participantUndeafEvent: ParticipantUndeafEvent) {
//         print("participantUndeafEvent triggered: ", participantUndeafEvent)
//     }
    
//     func onParticipantStartedTalking(_ participantStartedTalkingEvent: ParticipantStartedTalkingEvent) {
//         print("participantStartedTalkingEvent triggered: ", participantStartedTalkingEvent)
//     }
    
//     func onParticipantStoppedTalking(_ participantStoppedTalkingEvent: ParticipantStoppedTalkingEvent) {
//         print("participantStoppedTalkingEvent triggered: ", participantStoppedTalkingEvent)
//     }
    
//     func onDialogJoined(_ dialogJoinedEvent: DialogJoinedEvent) {
//         print("dialogJoinedEvent triggered: ", dialogJoinedEvent)
//     }
    
//     func onDialogLeft(_ dialogLeftEvent: DialogLeftEvent) {
//         print("dialogLeftEvent triggered: ", dialogLeftEvent)
//     }
    
//     func onReconnecting(_ callReconnectingEvent: CallReconnectingEvent) {
//         print("callReconnectingEvent triggered: ", callReconnectingEvent)
//     }
    
//     func onReconnected(_ callReconnectedEvent: CallReconnectedEvent) {
//         print("callReconnectedEvent triggered: ", callReconnectedEvent)
//     }
    
//     func onRinging(_ callRingingEvent: CallRingingEvent) {
//         print("on ringing outgoing")
//     }
    
//     func onEarlyMedia(_ callEarlyMediaEvent: CallEarlyMediaEvent) {
//         print("callEarlyMediaEvent triggered ==> ", callEarlyMediaEvent)
//         CommioSdkManager.shared?.audioDeviceManager.isBluetoothDeviceConnected()
//         CommioSdkManager.shared?.sendEvent(withName: "onOutgoingCallRinging", body: "");
//     }
    
//     func onEstablished(_ callEstablishedEvent: CallEstablishedEvent) {
//         CommioSdkManager.shared?.sendEvent(withName: "onOutgoingCallAnswered", body: "");
//     }
    
//     func onCameraVideoAdded(_ cameraVideoAddedEvent: CameraVideoAddedEvent) {
        
//     }
    
//     func onCameraVideoUpdated(_ cameraVideoUpdatedEvent: CameraVideoUpdatedEvent) {
        
//     }
    
//     func onCameraVideoRemoved() {
        
//     }
    
//     func onScreenShareAdded(_ screenShareAddedEvent: ScreenShareAddedEvent) {
        
//     }
    
//     func onScreenShareRemoved() {
        
//     }
    
//     func onRemoteCameraVideoAdded(_ cameraVideoAddedEvent: CameraVideoAddedEvent) {
        
//     }
    
//     func onRemoteCameraVideoRemoved() {
        
//     }
    
//     func onRemoteScreenShareAdded(_ screenShareAddedEvent: ScreenShareAddedEvent) {
        
//     }
    
//     func onRemoteScreenShareRemoved() {
        
//     }
    
//     func onRemoteMuted() {
        
//     }
    
//     func onRemoteUnmuted() {
        
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
    
//     func onError(_ errorEvent: ErrorEvent) {
//         print("on error (incoming...)");
//     }
    
//     func onConferenceJoined(_ conferenceJoinedEvent: ConferenceJoinedEvent) {
//         print("on joined (incoming...)");
//     }
    
//     func onEarlyMedia(_ callEarlyMediaEvent: CallEarlyMediaEvent) {
//         print("on EarlyMedia (incoming...)");
//     }
    
//     func onCameraVideoAdded(_ cameraVideoAddedEvent: CameraVideoAddedEvent) {
        
//     }
    
//     func onCameraVideoUpdated(_ cameraVideoUpdatedEvent: CameraVideoUpdatedEvent) {
        
//     }
    
//     func onCameraVideoRemoved() {
        
//     }
    
//     func onScreenShareAdded(_ screenShareAddedEvent: ScreenShareAddedEvent) {
        
//     }
    
//     func onScreenShareRemoved(_ screenShareRemovedEvent: ScreenShareRemovedEvent) {
        
//     }
    
//     func onConferenceLeft(_ conferenceLeftEvent: ConferenceLeftEvent) {
        
//     }
    
//     func onParticipantJoining(_ participantJoiningEvent: ParticipantJoiningEvent) {
        
//     }
    
//     func onParticipantJoined(_ participantJoinedEvent: ParticipantJoinedEvent) {
        
//     }
    
//     func onParticipantLeft(_ participantLeftEvent: ParticipantLeftEvent) {
        
//     }
    
//     func onParticipantCameraVideoAdded(_ participantCameraVideoAddedEvent: ParticipantCameraVideoAddedEvent) {
        
//     }
    
//     func onParticipantCameraVideoRemoved(_ participantCameraVideoRemovedEvent: ParticipantCameraVideoRemovedEvent) {
        
//     }
    
//     func onParticipantScreenShareAdded(_ participantScreenShareAddedEvent: ParticipantScreenShareAddedEvent) {
        
//     }
    
//     func onParticipantScreenShareRemoved(_ participantScreenShareRemovedEvent: ParticipantScreenShareRemovedEvent) {
        
//     }
    
//     func onParticipantMuted(_ participantMutedEvent: ParticipantMutedEvent) {
        
//     }
    
//     func onParticipantUnmuted(_ participantUnmutedEvent: ParticipantUnmutedEvent) {
        
//     }
    
//     func onParticipantDeaf(_ participantDeafEvent: ParticipantDeafEvent) {
        
//     }
    
//     func onParticipantUndeaf(_ participantUndeafEvent: ParticipantUndeafEvent) {
        
//     }
    
//     func onParticipantStartedTalking(_ participantStartedTalkingEvent: ParticipantStartedTalkingEvent) {
        
//     }
    
//     func onParticipantStoppedTalking(_ participantStoppedTalkingEvent: ParticipantStoppedTalkingEvent) {
        
//     }
    
//     func onDialogJoined(_ dialogJoinedEvent: DialogJoinedEvent) {
        
//     }
    
//     func onDialogLeft(_ dialogLeftEvent: DialogLeftEvent) {
        
//     }
    
//     func onReconnecting(_ callReconnectingEvent: CallReconnectingEvent) {
        
//     }
    
//     func onReconnected(_ callReconnectedEvent: CallReconnectedEvent) {
        
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
