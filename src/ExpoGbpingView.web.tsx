import * as React from 'react';

import { ExpoGbpingViewProps } from './ExpoGbping.types';

export default function ExpoGbpingView(props: ExpoGbpingViewProps) {
  return (
    <div>
      <iframe
        style={{ flex: 1 }}
        src={props.url}
        onLoad={() => props.onLoad({ nativeEvent: { url: props.url } })}
      />
    </div>
  );
}
