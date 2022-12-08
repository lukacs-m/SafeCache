//
//  File.swift
//  
//
//  Created by Martin Lukacs on 26/11/2022.
//

import Foundation

public protocol SafeCacheServicing: Actor {
    associatedtype Key: Hashable
    associatedtype Value

    func insert(_ value: Value, forKey key: Key)
    func value(forKey key: Key) -> Value?
    func removeValue(forKey key: Key)
    func removeAll()
}
