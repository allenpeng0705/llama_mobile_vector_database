/**
 * Web implementation of the LlamaMobileVD Capacitor Plugin
 * Since LlamaMobileVD is only available on mobile platforms, this implementation throws appropriate errors
 */
import { WebPlugin } from '@capacitor/core';
import type { LlamaMobileVDPlugin } from './definitions';
export declare class LlamaMobileVDWeb extends WebPlugin implements LlamaMobileVDPlugin {
    private readonly UNSUPPORTED_ERROR;
    createVectorStore(): Promise<{
        id: string;
    }>;
    createHNSWIndex(): Promise<{
        id: string;
    }>;
    addVectorToStore(): Promise<void>;
    addVectorToIndex(): Promise<void>;
    searchVectorStore(): Promise<{
        results: {
            id: number;
            distance: number;
        }[];
    }>;
    searchHNSWIndex(): Promise<{
        results: {
            id: number;
            distance: number;
        }[];
    }>;
    getVectorStoreCount(): Promise<{
        count: number;
    }>;
    getHNSWIndexCount(): Promise<{
        count: number;
    }>;
    clearVectorStore(): Promise<void>;
    clearHNSWIndex(): Promise<void>;
    releaseVectorStore(): Promise<void>;
    releaseHNSWIndex(): Promise<void>;
}
