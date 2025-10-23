// Main entry point for Vite bundling
import './mobileUtils';
import MobileUtils from './mobileUtils';

export * from './types';
export { default as MobileUtils } from './mobileUtils';


new MobileUtils().test();

