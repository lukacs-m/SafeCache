//
//  PersistantCaching.swift
//  
//
//  Created by Martin Lukacs on 26/11/2022.
//

import Foundation

public protocol SafePersistantCaching: Actor {
    func saveToDisk(
        withName name: String,
        using fileManager: FileManager) throws
    
    func loadFromDisk(
        withName name: String,
        using fileManager: FileManager) throws
}
