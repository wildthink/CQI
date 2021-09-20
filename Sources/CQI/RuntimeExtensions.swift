//
//  File.swift
//  
//
//  Created by Jason Jobe on 9/19/21.
//

import Foundation
import Runtime

public extension PropertyInfo {
    var typeInfo: TypeInfo? {
        try? Runtime.typeInfo(of: self.type)
    }
    
    var elementType: Any.Type? {
        typeInfo?.elementType
    }
}
