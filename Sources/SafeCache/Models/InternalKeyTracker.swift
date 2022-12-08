//
//  InternalKeyTracker.swift
//  
//
//  Created by Martin Lukacs on 27/11/2022.
//

import Combine
import Foundation

final class InternalKeyTracker<Key: Hashable, Value>: NSObject, NSCacheDelegate {
    let entryEvicted: PassthroughSubject<SafeCacheEntry<Key, Value>, Never> = .init()
    private var keys = Set<Key>()
    
    func add(_ key: Key) {
        keys.insert(key)
    }
    
    func remove(_ key: Key) {
        keys.remove(key)
    }
    
    func removeAll() {
        keys.removeAll()
    }
    
    func getAllKeys() -> Set<Key> {
        keys
    }
    
    func cache(_ cache: NSCache<AnyObject, AnyObject>,
               willEvictObject object: Any) {
        guard let entry = object as? SafeCacheEntry<Key, Value> else {
            return
        }
        
        entryEvicted.send(entry)
        keys.remove(entry.key)
    }
}
