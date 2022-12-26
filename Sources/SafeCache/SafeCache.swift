//
//  SafeCache.swift
//  
//
//  Created by Martin Lukacs on 03/12/2022.
//

import Combine
import Foundation

public actor SafeCache<Key: Hashable, Value> {
    private let cache = NSCache<WrappedKey<Key>, SafeCacheEntry<Key, Value>>()
    private let entryLifetime: TimeInterval
    private let keysTracker = InternalKeyTracker<Key, Value>()
    private var cancelBag = Set<AnyCancellable>()
    public nonisolated let valueEvicted: PassthroughSubject<Value?, Never> = .init()
    
    public init(entryLifetime: TimeInterval =  24 * 60 * 60,
                maximumEntryCount: Int = 100) {
        self.entryLifetime = entryLifetime
        cache.countLimit = maximumEntryCount
        cache.delegate = keysTracker
        Task {
            await setUpPublishers()
        }
    }
}

extension SafeCache: SafeCacheServicing {
    /// Add element to the cache
    /// - Parameters:
    ///   - value: The value to add to the cache
    ///   - key: The key linked to the value in cache
    public func insert(_ value: Value, forKey key: Key) {
        let date = Date.now.addingTimeInterval(entryLifetime)
        let entry = SafeCacheEntry(key: key, value: value, expirationDate: date)
        cache.setObject(entry, forKey: WrappedKey(key))
        keysTracker.add(key)
    }
    
    /// Return an optional element based on a specific key
    /// - Parameter key: The key link to value to fetch in cache
    /// - Returns: A value if it exists in cache and if it is not stale. Otherwise it returns nil
    public func value(forKey key: Key) -> Value? {
        guard let entry = cache.object(forKey: WrappedKey(key)) else {
            return nil
        }
        
        guard !entry.isStale(after: Date.now) else {
            removeValue(forKey: key)
            return nil
        }
        
        return entry.value
    }
    
    /// Remove a specific value of the cache link to a the key passed as parameter to the function
    /// - Parameter key: The key 
    public func removeValue(forKey key: Key) {
        keysTracker.remove(key)
        cache.removeObject(forKey: WrappedKey(key))
    }
    
    /// Remove all values of stored in the current cache
    public func removeAll() {
        keysTracker.removeAll()
        cache.removeAllObjects()
    }
}

extension SafeCache: SafePersistantCaching where Key: Codable, Value: Codable {
    /// Enables the persisting of the current cache state to disk in the cache directory
    /// - Parameters:
    ///   - name: The name of the file in wich to save the current cache state.
    ///   - fileManager: A filemanager to enable persistents of cache state on disk
    public func saveToDisk(
        withName name: String,
        using fileManager: FileManager = .default
    ) throws {
        let folderURLs = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )
        
        let fileURL = folderURLs[0].appendingPathComponent(name + ".cache")
        
        let cacheEntries = keysTracker.getAllKeys().compactMap(safeCacheEntry)
        let data = try JSONEncoder().encode(cacheEntries)
        try data.write(to: fileURL)
    }
    
    /// Enable fetching of a cache state from disk
    /// - Parameters:
    ///   - name: The name of the file to fetch from
    ///   - fileManager: The filemanager to load data in memory
    public func loadFromDisk(
        withName name: String,
        using fileManager: FileManager = .default
    ) throws {
        let folderURLs = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )
        
        let fileURL = folderURLs[0].appendingPathComponent(name + ".cache")
        let data = try Data(contentsOf: fileURL)
        let entries = try JSONDecoder().decode([SafeCacheEntry<Key, Value>].self, from: data)
        entries.forEach { insert($0) }
    }
}

private extension SafeCache {
    func setUpPublishers() {
        keysTracker.entryEvicted
            .sink { [weak self] entry in
                self?.valueEvicted.send(entry.value)
            }
            .store(in: &cancelBag)
    }
    
    func insert(_ entry: SafeCacheEntry<Key, Value>) {
        keysTracker.add(entry.key)
        cache.setObject(entry, forKey: WrappedKey(entry.key))
    }
    
    func safeCacheEntry(forKey key: Key) -> SafeCacheEntry<Key, Value>? {
        guard let entry = cache.object(forKey: WrappedKey(key)) else {
            return nil
        }
        
        guard !entry.isStale(after: Date.now) else {
            removeValue(forKey: key)
            return nil
        }
        
        return entry
    }
}
