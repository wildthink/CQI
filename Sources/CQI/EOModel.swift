//
//  File.swift
//  
//
//  Created by Jason Jobe on 9/18/21.
//

import Foundation
import MomXML
import Runtime

public struct EOModel {
    var facets: [EOFacet]
    var model: MomModel
}

public extension EOModel {
    
    init(_ etypes: [AnyEntity.Type]) throws {
        model = MomModel()
        facets = etypes.map { $0.schema }
        try model.merge(facets: facets)
     }
}

public extension EOModel {
    func createTablesSQL() -> String {
        model.createTablesSQL()
    }
}
