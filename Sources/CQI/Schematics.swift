//
//  File.swift
//  
//
//  Created by Jason Jobe on 9/19/21.
//

import Foundation

public extension AnyEntity {
    
    static func Schema(_ key: EntityTypeKey? = nil, type: Self.Type = Self.self) -> EOFacet {
        return try! EOFacet(key, type: type)
    }
    
    static var schema: EOFacet { Schema() }
}

extension EOFacet {
    public init(_ etype: EntityTypeKey? = nil, type: AnyEntity.Type) throws {
        try self.init(name: nil, of: etype, type: type)
    }

//    func builder
}

extension EOFacet {
    typealias EOFacetComponents = Any
    
    @resultBuilder
    enum Builder: ResultBuilder {
        public typealias Expression = EOFacetComponents
        
        public static func buildFinalResult(_ component: Component) -> Any {
            []
        }
    }
}
