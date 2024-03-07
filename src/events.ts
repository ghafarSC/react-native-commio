import { NativeEventEmitter } from 'react-native';

import { CommioNativeSdk } from './CommioNativeSdk';

export const emitter = new NativeEventEmitter(CommioNativeSdk);
