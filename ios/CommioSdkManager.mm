#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(CommioSdkManager, RCTEventEmitter)

RCT_EXTERN_METHOD(login:(nonnull NSString *)userName
                  password:(nonnull NSString *)password
                  token:(nonnull NSString *)token
                  certificateId:(nonnull NSString *)certificateId
                  )
RCT_EXTERN_METHOD(reconnect)
RCT_EXTERN_METHOD(disablePushNotification:(nonnull NSString *)token)

RCT_EXTERN_METHOD(call:(nonnull NSString *)apiKey
                  token:(nonnull NSString *)token
                  environment:(nonnull NSString *)environment
                  identity:(nonnull NSString *)identity
                  contactId:(nonnull NSString *)contactId
                  destination:(nonnull NSString *)destination
                  caller:(nonnull NSString *)caller
                  )

RCT_EXTERN_METHOD(registerPushNotification:(nonnull NSString *)token
                  pushConfigId:(nonnull NSString *)pushConfigId
                  )

RCT_EXTERN_METHOD(handleIncomingCallFromCallKeep)

RCT_EXTERN_METHOD(mute)
RCT_EXTERN_METHOD(unmute)
RCT_EXTERN_METHOD(hangup)
RCT_EXTERN_METHOD(reject)
RCT_EXTERN_METHOD(answer)

RCT_EXTERN_METHOD(setAudioDevice:(NSInteger *)device)


// TODO: Copied from TelnyxSdkManager
RCT_EXTERN_METHOD(configureAudioSession)
RCT_EXTERN_METHOD(startAudioDevice)
RCT_EXTERN_METHOD(stopAudioDevice)

+ (BOOL)requiresMainQueueSetup
{
    return NO;
}

@end
