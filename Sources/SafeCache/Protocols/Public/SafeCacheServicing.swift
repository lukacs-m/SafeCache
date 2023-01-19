//
//  File.swift
//  
//
//  Created by Martin Lukacs on 26/11/2022.
//

import Foundation

public protocol SafeCacheServicing<Key, Value>: Actor {
    associatedtype Key: Hashable
    associatedtype Value

    func insert(_ value: Value, forKey key: Key)
    func value(forKey key: Key) -> Value?
    func removeValue(forKey key: Key)
    func removeAll()
}

public extension SafeCacheServicing {
    subscript(key: Key) -> Value? {
        get { value(forKey: key) }
    }
}
