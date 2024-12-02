// Reexport the native module. On web, it will be resolved to ExpoGbpingModule.web.ts
// and on native platforms to ExpoGbpingModule.ts
export { default } from './ExpoGbpingModule';
export { default as ExpoGbpingView } from './ExpoGbpingView';
export * from  './ExpoGbping.types';
