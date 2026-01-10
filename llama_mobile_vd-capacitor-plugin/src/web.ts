/**
 * Web implementation of the LlamaMobileVD Capacitor Plugin
 * Since LlamaMobileVD is only available on mobile platforms, this implementation throws appropriate errors
 */

import { WebPlugin } from '@capacitor/core';

import type { LlamaMobileVDPlugin } from './definitions';

export class LlamaMobileVDWeb extends WebPlugin implements LlamaMobileVDPlugin {
  private readonly UNSUPPORTED_ERROR = 'LlamaMobileVD is not supported on web platform. Please use this plugin on iOS or Android.';

  async createVectorStore(): Promise<{ id: string }> {
    throw new Error(this.UNSUPPORTED_ERROR);
  }

  async createHNSWIndex(): Promise<{ id: string }> {
    throw new Error(this.UNSUPPORTED_ERROR);
  }

  async addVectorToStore(): Promise<void> {
    throw new Error(this.UNSUPPORTED_ERROR);
  }

  async addVectorToIndex(): Promise<void> {
    throw new Error(this.UNSUPPORTED_ERROR);
  }

  async searchVectorStore(): Promise<{ results: { id: number; distance: number }[] }> {
    throw new Error(this.UNSUPPORTED_ERROR);
  }

  async searchHNSWIndex(): Promise<{ results: { id: number; distance: number }[] }> {
    throw new Error(this.UNSUPPORTED_ERROR);
  }

  async getVectorStoreCount(): Promise<{ count: number }> {
    throw new Error(this.UNSUPPORTED_ERROR);
  }

  async getHNSWIndexCount(): Promise<{ count: number }> {
    throw new Error(this.UNSUPPORTED_ERROR);
  }

  async clearVectorStore(): Promise<void> {
    throw new Error(this.UNSUPPORTED_ERROR);
  }

  async clearHNSWIndex(): Promise<void> {
    throw new Error(this.UNSUPPORTED_ERROR);
  }

  async releaseVectorStore(): Promise<void> {
    throw new Error(this.UNSUPPORTED_ERROR);
  }

  async releaseHNSWIndex(): Promise<void> {
    throw new Error(this.UNSUPPORTED_ERROR);
  }
}