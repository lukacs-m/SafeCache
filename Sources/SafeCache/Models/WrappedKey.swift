//
//  WrappedKey.swift
//  
//
//  Created by Martin Lukacs on 27/11/2022.
//

import Foundation

final class WrappedKey<Key: Hashable>: NSObject {
    let key: Key
    
    init(_ key: Key) {
        self.key = key
        
    }
    
    override var hash: Int {
        key.hashValue
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let value = object as? WrappedKey else {
            return false
        }
        
        return value.key == key
    }
}
