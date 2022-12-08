//
//  SafeCache+Extensions.swift
//  
//
//  Created by Martin Lukacs on 04/12/2022.
//

import Foundation

public extension SafeCache {
    
    subscript(key: Key) -> Value? {
        get { value(forKey: key) }
    }
}
