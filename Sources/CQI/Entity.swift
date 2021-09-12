//
//  File.swift
//  File
//
//  Created by Jason Jobe on 9/12/21.
//

import Foundation

public protocol TypedEntity {
    static var entityType: EntityType { get }
    var id: EntityID { get }
}

public extension TypedEntity {
    static var entityType: EntityType { EntityType(Self.self) }
}

extension TypedEntity where Self: CustomStringConvertible {
    var description: String {
        return "\(Self.entityType)[\(id)]"
    }
}

public typealias Entity = (TypedEntity & Identifiable & CustomStringConvertible)


#if canImport(Tagged)
import Tagged
public enum EntityTypeTag {}
public typealias EntityType = Tagged<EntityTypeTag, String>
#else
public typealias EntityID = Int64

public struct EntityType: RawRepresentable, Equatable, ExpressibleByStringLiteral {
    public var rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init(stringLiteral value: String) {
        self.rawValue = value
    }
    public init(_ value: String) {
        self.rawValue = value
    }
    public init(_ etype: Any.Type) {
        self.rawValue = String(describing: etype)
    }
}

#endif
