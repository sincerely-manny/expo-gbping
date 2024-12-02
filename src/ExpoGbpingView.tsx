import { requireNativeView } from 'expo';
import * as React from 'react';

import { ExpoGbpingViewProps } from './ExpoGbping.types';

const NativeView: React.ComponentType<ExpoGbpingViewProps> =
  requireNativeView('ExpoGbping');

export default function ExpoGbpingView(props: ExpoGbpingViewProps) {
  return <NativeView {...props} />;
}
