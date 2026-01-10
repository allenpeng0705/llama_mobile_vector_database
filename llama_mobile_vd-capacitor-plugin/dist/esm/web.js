/**
 * Web implementation of the LlamaMobileVD Capacitor Plugin
 * Since LlamaMobileVD is only available on mobile platforms, this implementation throws appropriate errors
 */
import { WebPlugin } from '@capacitor/core';
export class LlamaMobileVDWeb extends WebPlugin {
    constructor() {
        super(...arguments);
        this.UNSUPPORTED_ERROR = 'LlamaMobileVD is not supported on web platform. Please use this plugin on iOS or Android.';
    }
    async createVectorStore() {
        throw new Error(this.UNSUPPORTED_ERROR);
    }
    async createHNSWIndex() {
        throw new Error(this.UNSUPPORTED_ERROR);
    }
    async addVectorToStore() {
        throw new Error(this.UNSUPPORTED_ERROR);
    }
    async addVectorToIndex() {
        throw new Error(this.UNSUPPORTED_ERROR);
    }
    async searchVectorStore() {
        throw new Error(this.UNSUPPORTED_ERROR);
    }
    async searchHNSWIndex() {
        throw new Error(this.UNSUPPORTED_ERROR);
    }
    async getVectorStoreCount() {
        throw new Error(this.UNSUPPORTED_ERROR);
    }
    async getHNSWIndexCount() {
        throw new Error(this.UNSUPPORTED_ERROR);
    }
    async clearVectorStore() {
        throw new Error(this.UNSUPPORTED_ERROR);
    }
    async clearHNSWIndex() {
        throw new Error(this.UNSUPPORTED_ERROR);
    }
    async releaseVectorStore() {
        throw new Error(this.UNSUPPORTED_ERROR);
    }
    async releaseHNSWIndex() {
        throw new Error(this.UNSUPPORTED_ERROR);
    }
}
//# sourceMappingURL=web.js.map