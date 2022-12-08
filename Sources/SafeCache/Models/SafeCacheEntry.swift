//
//  SafeCacheEntry.swift
//  
//
//  Created by Martin Lukacs on 26/11/2022.
//

import Foundation

final class SafeCacheEntry<Key: Hashable, Value> {
    let key: Key
    let value: Value
    let expirationDate: Date
    
    init(key: Key, value: Value, expirationDate: Date) {
        self.key = key
        self.value = value
        self.expirationDate =  expirationDate
    }
    
    func isStale(after date: Date = .now) -> Bool {
        date > expirationDate
    }
}

extension SafeCacheEntry: Codable where Key: Codable, Value: Codable {}
