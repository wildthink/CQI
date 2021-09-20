//
//  File.swift
//  File
//
//  Created by Jason Jobe on 9/12/21.
//

import Foundation

public protocol AnyEntity {
    static var entityType: EntityTypeKey { get }
    var id: EntityID { get set }
}

public extension AnyEntity {
    static var entityType: EntityTypeKey { EntityTypeKey(Self.self) }
}

extension AnyEntity where Self: CustomStringConvertible {
    var description: String {
        return "\(Self.entityType)[\(id)]"
    }
}

public protocol Entity: AnyEntity, Identifiable, CustomStringConvertible {
}

//public typealias Entity = (AnyEntity & Identifiable & CustomStringConvertible)


#if canImport(Tagged)
import Tagged
public enum EntityTypeTag {}
public typealias EntityID = Tagged<EntityTypeTag, Int64>
public typealias EntityTypeKey = Tagged<EntityTypeTag, String>
#else
public typealias EntityID = Int64

public struct EntityTypeKey: RawRepresentable, Equatable, ExpressibleByStringLiteral {
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

extension EntityTypeKey: CustomStringConvertible {
    public var description: String { rawValue }
}
