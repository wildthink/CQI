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
//    var etypes: [AnyEntity.Type]
    var facets: [EOFacet]
    var model: MomModel
}

public extension EOModel {
    
    init(_ etypes: [AnyEntity.Type]) throws {
        model = MomModel()
//        facets = try etypes.map { try EOFacet(type: $0) }
        facets = etypes.map { $0.schema }
        try model.merge(facets: facets)
     }
}

public extension EOModel {
    func createTablesSQL() -> String {
        model.createTablesSQL()
    }
}

//public extension MomEntity {
//    
//    init(name: String? = nil, for etype: AnyEntity.Type, codeGenerationType: String = "class") {
//        let cn = String(describing: etype)
//        self.init(name: name ?? cn, representedClassName: cn, codeGenerationType: codeGenerationType)
//    }
//}
