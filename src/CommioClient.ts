import { Platform } from 'react-native';
import { CommioNativeSdk } from './CommioNativeSdk';
import { emitter } from './events';

enum CallState {
  DIALING = 0,
  RINGING = 1,
  ONGOING = 2,
  TERMINATED = 3,
}

interface CommioLoginEvent {}
interface CommioLogoutEvent {}

interface CommioOutgoingEvent {
  callId: string;
  state: CallState;
  isOnHold: boolean;
  muted: boolean;
}

interface CommioIncomingEvent {
  callId: string;
  state: CallState;
  isOnHold: boolean;
  muted: boolean;
}

type Handler<T> = (data: T) => void;

const createListener = <T>(event: string, handler: Handler<T>) => {
  // const listener = emitter.addListener(`Commio-${event}`, handler);
  const listener = emitter.addListener(`${event}`, handler);
  return () => listener.remove();
};

export class CommioClient {
  private _isLoggedIn = false;

  login(
    username: string,
    password: string,
    fcmToken: string,
    certificateId: string
  ) {
    return CommioNativeSdk.login(username, password, fcmToken, certificateId);
  }
  registerPushNotification(token: string, pushConfigId: string) {
    return CommioNativeSdk.registerPushNotification(token, pushConfigId);
  }
  registerAndroidPushNotification(
    fcmToken: string,
    token: string,
    pushConfigId: string
  ) {
    return CommioNativeSdk.registerAndroidPushNotification(
      fcmToken,
      token,
      pushConfigId
    );
  }
  call(
    apiKey: string,
    webRTCToken: string,
    environment: string,
    identity: string,
    contactId: string,
    destination: string,
    caller: string
  ) {
    return CommioNativeSdk.call(
      apiKey,
      webRTCToken,
      environment,
      identity,
      contactId,
      destination,
      caller
    );
  }

  reconnect() {
    CommioNativeSdk.reconnect();
  }

  logout(token: string) {
    CommioNativeSdk.disablePushNotification(token);
    this._isLoggedIn = false;
  }

  setAudioDevice(device: number) {
    CommioNativeSdk.setAudioDevice(device);
  }

  mute() {
    CommioNativeSdk.mute();
  }

  unmute() {
    CommioNativeSdk.unmute();
  }

  answer() {
    CommioNativeSdk.answer();
  }

  handleIncomingCall(payload: any) {
    if (Platform.OS === 'android') {
      CommioNativeSdk.handleIncomingCall(payload);
    } else {
      CommioNativeSdk.handleIncomingCallFromCallKeep();
    }
  }

  hangup() {
    CommioNativeSdk.hangup();
  }

  reject() {
    CommioNativeSdk.reject();
  }

  isLoggedIn() {
    return this._isLoggedIn;
  }

  onLogin(handler: Handler<CommioLoginEvent>) {
    return createListener('onLogin', (event: CommioLoginEvent) => {
      this._isLoggedIn = true;

      handler(event);
    });
  }

  onLogout(handler: Handler<CommioLogoutEvent>) {
    return createListener('onLogout', (event: CommioLogoutEvent) => {
      this._isLoggedIn = false;

      handler(event);
    });
  }

  onLoginFailed(handler: Handler<CommioLoginEvent>) {
    return createListener('onLoginFailed', handler);
  }

  onIncomingCall(handler: Handler<CommioIncomingEvent>) {
    return createListener('onIncomingCall', handler);
  }

  onIncomingCallHangup(handler: Handler<CommioIncomingEvent>) {
    return createListener('onIncomingCallHangup', handler);
  }

  onIncomingCallRejected(handler: Handler<CommioIncomingEvent>) {
    return createListener('onIncomingCallRejected', handler);
  }

  onIncomingCallInvalid(handler: Handler<CommioIncomingEvent>) {
    return createListener('onIncomingCallInvalid', handler);
  }

  onIncomingCallAnswered(handler: Handler<CommioIncomingEvent>) {
    return createListener('onIncomingCallAnswered', handler);
  }

  onOutgoingCall(handler: Handler<CommioOutgoingEvent>) {
    return createListener('onOutgoingCall', handler);
  }

  onOutgoingCallRinging(handler: Handler<CommioOutgoingEvent>) {
    return createListener('onOutgoingCallRinging', handler);
  }

  onOutgoingCallAnswered(handler: Handler<CommioOutgoingEvent>) {
    return createListener('onOutgoingCallAnswered', handler);
  }

  onOutgoingCallRejected(handler: Handler<CommioOutgoingEvent>) {
    return createListener('onOutgoingCallRejected', handler);
  }

  onOutgoingCallHangup(handler: Handler<CommioOutgoingEvent>) {
    return createListener('onOutgoingCallHangup', handler);
  }

  onOutgoingCallInvalid(handler: Handler<CommioOutgoingEvent>) {
    return createListener('onOutgoingCallInvalid', handler);
  }

  onHeadphonesStateChanged(handler: Handler<{ connected: boolean }>) {
    return createListener('headphonesStateChanged', handler);
  }
}
