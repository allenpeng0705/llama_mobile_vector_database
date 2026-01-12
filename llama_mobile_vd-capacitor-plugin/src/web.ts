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

  // MARK: New VectorStore Methods
  async removeVectorFromStore(): Promise<{ result: boolean }> {
    throw new Error(this.UNSUPPORTED_ERROR);
  }

  async getVectorFromStore(): Promise<{ vector: number[] } | null> {
    throw new Error(this.UNSUPPORTED_ERROR);
  }

  async updateVectorInStore(): Promise<{ result: boolean }> {
    throw new Error(this.UNSUPPORTED_ERROR);
  }

  async containsVectorInStore(): Promise<{ result: boolean }> {
    throw new Error(this.UNSUPPORTED_ERROR);
  }

  async reserveVectorStore(): Promise<void> {
    throw new Error(this.UNSUPPORTED_ERROR);
  }

  async getVectorStoreDimension(): Promise<{ dimension: number }> {
    throw new Error(this.UNSUPPORTED_ERROR);
  }

  async getVectorStoreMetric(): Promise<{ metric: string }> {
    throw new Error(this.UNSUPPORTED_ERROR);
  }

  // MARK: New HNSWIndex Methods
  async setHNSWEfSearch(): Promise<void> {
    throw new Error(this.UNSUPPORTED_ERROR);
  }

  async getHNSWEfSearch(): Promise<{ efSearch: number }> {
    throw new Error(this.UNSUPPORTED_ERROR);
  }

  async containsVectorInHNSW(): Promise<{ result: boolean }> {
    throw new Error(this.UNSUPPORTED_ERROR);
  }

  async getVectorFromHNSW(): Promise<{ vector: number[] } | null> {
    throw new Error(this.UNSUPPORTED_ERROR);
  }

  async getHNSWDimension(): Promise<{ dimension: number }> {
    throw new Error(this.UNSUPPORTED_ERROR);
  }

  async getHNSWCapacity(): Promise<{ capacity: number }> {
    throw new Error(this.UNSUPPORTED_ERROR);
  }

  async saveHNSWIndex(): Promise<{ result: boolean }> {
    throw new Error(this.UNSUPPORTED_ERROR);
  }

  async loadHNSWIndex(): Promise<{ id: string }> {
    throw new Error(this.UNSUPPORTED_ERROR);
  }

  // MARK: Version Methods
  async getVersion(): Promise<{ version: string }> {
    throw new Error(this.UNSUPPORTED_ERROR);
  }

  async getVersionMajor(): Promise<{ value: number }> {
    throw new Error(this.UNSUPPORTED_ERROR);
  }

  async getVersionMinor(): Promise<{ value: number }> {
    throw new Error(this.UNSUPPORTED_ERROR);
  }

  async getVersionPatch(): Promise<{ value: number }> {
    throw new Error(this.UNSUPPORTED_ERROR);
  }

  // MARK: MMapVectorStore Methods
  async openMMapVectorStore(): Promise<{ id: string }> {
    throw new Error(this.UNSUPPORTED_ERROR);
  }

  async searchMMapVectorStore(): Promise<{ results: { id: number; distance: number }[] }> {
    throw new Error(this.UNSUPPORTED_ERROR);
  }

  async getMMapVectorStoreCount(): Promise<{ count: number }> {
    throw new Error(this.UNSUPPORTED_ERROR);
  }

  async getMMapVectorStoreDimension(): Promise<{ dimension: number }> {
    throw new Error(this.UNSUPPORTED_ERROR);
  }

  async getMMapVectorStoreMetric(): Promise<{ metric: string }> {
    throw new Error(this.UNSUPPORTED_ERROR);
  }

  async releaseMMapVectorStore(): Promise<void> {
    throw new Error(this.UNSUPPORTED_ERROR);
  }
}