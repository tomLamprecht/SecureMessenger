package de.thws.securemessenger.data;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

public abstract class InMemoryStorage<K, T> {
    protected Map<K, T> storage;
    protected final AtomicInteger counter = new AtomicInteger(1);

    protected InMemoryStorage() {
        storage = new HashMap<>();
    }

    public T loadById(K key) {
        return storage.get(key);
    }

    protected K createAndReturnId(T value) {
        K key = generateKey();
        storage.put(key, value);
        return key;
    }

    protected void createWithGivenId(K key, T value) {
        storage.put(key, value);
    }

    protected void remove(K key) {
        storage.remove(key);
    }

    // Methods for testing
    public boolean containsKey(K key) {
        return storage.containsKey(key);
    }

    public boolean isEmpty() {
        return storage.isEmpty();
    }

    public int size() {
        return storage.size();
    }

    public void clear() {
        storage.clear();
    }

    protected abstract K generateKey();
}