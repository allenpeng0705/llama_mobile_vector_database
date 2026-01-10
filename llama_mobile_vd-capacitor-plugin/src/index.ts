/**
 * Main entry point for the LlamaMobileVD Capacitor Plugin
 */

import { registerPlugin } from '@capacitor/core';

import { LlamaMobileVDPlugin } from './definitions';
import { LlamaMobileVDWeb } from './web';

export * from './definitions';

/**
 * The LlamaMobileVD plugin instance
 * Use this to access all the vector database functionality
 */
export const LlamaMobileVD = registerPlugin<LlamaMobileVDPlugin>('LlamaMobileVD', {
  /**
   * Web implementation of the plugin
   */
  web: () => new LlamaMobileVDWeb(),
});

export default LlamaMobileVD;