//
//  PersistantCaching.swift
//  
//
//  Created by Martin Lukacs on 26/11/2022.
//

import Foundation

public protocol SafePersistantCaching<Key, Value>: Actor where Self: SafeCacheServicing<Key, Value> {
    func saveToDisk(
        withName name: String,
        using fileManager: FileManager) throws
    
    func loadFromDisk(
        withName name: String,
        using fileManager: FileManager) throws
}


public extension SafePersistantCaching {
    func saveToDisk(
        withName name: String,
        using fileManager: FileManager = .default) throws {
            try saveToDisk(withName: name, using: fileManager)
        }
    
    func loadFromDisk(
        withName name: String,
        using fileManager: FileManager = .default) throws {
            try loadFromDisk(withName: name, using: fileManager)
        }
}
