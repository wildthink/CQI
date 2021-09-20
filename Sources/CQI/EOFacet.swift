//
//  File.swift
//  
//
//  Created by Jason Jobe on 9/18/21.
//
import Foundation
import MomXML
import Runtime

public struct EOFacet {
    
    public typealias FacetType = Entity.Type

    public var name: String
    public var entityType: EntityTypeKey
    public var facetInfo: TypeInfo
    public var userInfo = MomUserInfo()

    
    public init(name: String? = nil, of etype: EntityTypeKey? = nil, type: AnyEntity.Type) throws {
        let info = try typeInfo(of: type)
        self.name = name ?? info.name
        self.entityType = etype ?? EntityTypeKey(self.name)
        self.facetInfo = info
        attributes = info.properties.map { MomAttribute($0) }
    }
    
    public var attributes: [MomAttribute] = []
    public var relationships: [MomRelationship] = []
}

//=======================================
public struct EOError: Error {
    var name: String
    
    init (_ name: String) {
        self.name = name
    }
}

//=======================================
extension MomAttribute {
    
    init(_ pinfo: PropertyInfo) {
        self.init(name: pinfo.name,
                  attributeType: pinfo.attributeType,
                  isOptional: pinfo.isOptional,
                  isTransient: pinfo.name.hasPrefix("_"))
    }
    
//    var propertyInfo: PropertyInfo? {
//        get { userInfo.entries[#function] as? PropertyInfo }
//        set { userInfo.add(key: #function, value: <#T##String#>) [#function] = newValue }
//    }
}

extension MomModel {
    
    mutating func merge(facet: EOFacet) throws {
        var ent = self[facet.name] ?? MomEntity(name: facet.name)
        try ent.merge(facet: facet)
    }
   
    mutating func merge(facets: [EOFacet]) throws {
        for facet in facets {
            var ent: MomEntity
            if var moe = self[facet.name] {
                try moe.merge(facet: facet)
                self[facet.name] = moe
            } else {
                ent = MomEntity(name: facet.name)
                try ent.merge(facet: facet)
                entities.append(ent)
            }
        }
    }

    subscript(_ key: String) -> MomEntity? {
        get { entities.first(where: { $0.name == key }) }
        set {
            guard let newValue = newValue else { return }
            for (ndx, e) in entities.enumerated() {
                if e.name == key {
                    entities[ndx] = newValue
                    return
                }
            }
        }
    }
}

extension MomEntity {

    mutating func merge(facet: EOFacet) throws {
        guard self.name == facet.entityType.rawValue
        else { throw EOError("Mismatching Entities for Facet") }
        
        let delta = facet.attributes.difference(from: attributes)
        for ndx in delta.insertions.indices {
            attributes.append(facet.attributes[ndx])
        }
    }
}

public extension PropertyInfo {
    var attributeType: MomAttribute.AttributeType {
        let ptype = isOptional ? self.elementType : self.type
        switch ptype {
//            case _ where db_value.isNull:
            case is Bool.Type:      return .string
            case is String.Type:    return .string
            case is Date.Type:      return .date
            case is Float.Type:     return .float
            case is Decimal.Type:   return .decimal
            case is Data.Type:      return .binary
            case is Int16.Type:     return .integer16
            case is Int32.Type:     return .integer32
            case is Int64.Type:     return .integer64
            case is Int.Type:       return .integer64
            case is URL.Type:       return .uri
            case is UUID.Type:      return .uuid
            case is AnyEntity.Type: return .objectID
            case is EntityID.Type:  return .objectID
            default:
                return .undefined
        }
    }
}
