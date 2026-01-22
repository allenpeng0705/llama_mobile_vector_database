package com.llamamobile.vd;

public class SearchResult {
    private final long id;
    private final float distance;

    public SearchResult(long id, float distance) {
        this.id = id;
        this.distance = distance;
    }

    public long getId() {
        return id;
    }

    public float getDistance() {
        return distance;
    }
}
