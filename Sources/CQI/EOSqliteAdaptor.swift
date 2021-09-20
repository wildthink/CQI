//
//  CQIAdaptor.swift
//  Common Query Interface
//  Adaptor
//
//  Copyright © 2020 Jason Jobe. All rights reserved.
//  Created by Jason Jobe on 9/5/20.
//
import Foundation
import FeistyDB
import FeistyExtensions
import Runtime
import MomXML

/**
 @DomainObject(id: 2) var nob: NobStruct
 @DomainList(where: "age < 10") var nobs: [NobStruct]
 
 adaptor(select: S.Type, id: x) throws -> S?
 adaptor(select: S.Type,  sort_by: [pkey], where: predicate) throws -> [S]
 
 */

extension EOFacet {
    var table: String {
        entityType.rawValue
    }
    
    var columns: [String] {
        attributes.filter({ !$0.isTransient }).map({$0.name})
    }
}

public typealias CQIConfig = EOFacet

open class EOSqliteAdaptor {
    public enum Ordering { case asc(String), desc(String) }
//    public typealias Ordering = Database.Ordering
        
    public static var shared: EOSqliteAdaptor?
    
    public var db: Database
    public var name: String?
    
    public var transformers: [String:NSValueTransformerName] = [:]
    
    public init(name: String?, rawSQLiteDatabase dbc: SQLiteDatabaseConnection) throws {
        db = Database(rawSQLiteDatabase: dbc)
        self.name = name
        try addExtensions()
    }
    
    public init(database: Database) throws {
        db = database
        try addExtensions()
    }
    
    public init(inMemory: Bool = true) throws {
        try db = Database(inMemory: inMemory)
        try addExtensions()
    }
    
    public init(url: URL, create: Bool = true) throws {
        try db = Database(url: url, create: create)
        try addExtensions()
    }
    
    public init(file: String, create: Bool = true) throws {
        try db = Database(url: URL(fileURLWithPath: file), create: create)
        try addExtensions()
    }
    
    deinit {
        self.close()
    }
    
    public func close() {
        //        db.close()
    }
    
    public var logErrors: Bool = true
    
    func log (_ error: Swift.Error, from caller: String = #function) {
        guard logErrors else { return }
        Report.print(error)
    }
    
    // MARK: exec methos
    // =====================================
    public func exec(sql: String) throws {
        do {
            try db.batch(sql: sql)
        } catch {
            log(error)
            throw error
        }
    }
    
    public func exec (contentsOfFile file: String) throws {
        let str = try String(contentsOfFile: file)
        try exec(sql: str)
    }
    
    open func addExtensions() throws {
    }
    
}

public struct CQIError: Swift.Error {
    public var message: String
    public init (_ msg: String = "") {
        message = msg
    }
    
    static func notImplemented(_ f: String = #function) -> CQIError {
        CQIError("NOT IMPLEMENTED: \(f)")
    }
    static func illegalOperation(_ f: String = #function) -> CQIError {
        CQIError("ILLEGAL OPERATION: \(f)")
    }
    static func nothingFound(_ f: String = #function) -> CQIError {
        CQIError("UNEXPECTLY NO DATA WAS FOUND: \(f)")
    }
}

extension EOFacet {
    
    func createInstance() throws -> AnyEntity? {
        try Runtime.createInstance(of: facetInfo.type) as? AnyEntity
    }
    
    func create(from row: Row) throws -> Any {
        
        var nob = try createInstance()
        
//        for slot in attributes where !slot.isTransient {
        for property in facetInfo.properties {
            // skip if isTransient
//            let slot = attributes.first // BAD
            var valueType: Any.Type = property.type
            
            if property.isOptional,
               let pinfo = try? typeInfo(of: property.type),
               let elementType = pinfo.elementType {
                valueType = elementType
            }
            
            // FIXME: Add the ability to use a ValueTransformer here
            // Actually will need to create a Swifty TypeTransformer
            // Using the slot.column (a String) is more convenient
            // programatically but not as performant as ndx could be(?)
            
            let db_value = try row.value(named: property.name)
            let value: Any?
            
            switch valueType {
                    
                case _ where db_value.isNull:
                    value = nil
                    
                case is String.Type:
                    value = db_value.stringValue
                    
                case is Data.Type:
                    value = db_value.dataValue
                    
//                case let f as AnyEntity.Type:
//                    value = try create(from: row)
                    
                case let f as DatabaseSerializable.Type where !db_value.isNull:
                    value = try f.deserialize(from: db_value)
                    
                case let f as Decodable.Type where !property.sealed:
                    
                    switch db_value {
                        case .null:
                            value = nil
                        case let DatabaseValue.blob(data):
                            value = try f.decodeFromJSON(data: data)
                        case let DatabaseValue.text(str):
                            value = try f.decodeFromJSON(text: str)
                        default:
                            // Primative DB types are Decodable
                            // But should we throw?
                            value = db_value.anyValue
                    }
                    
                default:
                    value = db_value.anyValue
            }
            try property.set(value: value as Any, on: &nob)
        }
        return nob as Any
    }
}

extension DatabaseValue {
    var isNull: Bool {
        switch self {
            case .null: return true
            default: return false
        }
    }
}

public extension Encodable {
    
    func encodeToJSONData() throws -> Data {
        try JSONEncoder().encode(self)
    }
    
    func encodeToJSONText() throws -> String {
        let data = try JSONEncoder().encode(self)
        guard let str = String(data: data, encoding: .utf8)
        else {
            throw DatabaseError("\(Self.self) cannot be coverted to JSON")
        }
        return str
    }
}

public extension Decodable {
    
    static func decodeFromJSON(data: Data) throws -> Self {
        return try JSONDecoder().decode(Self.self, from: data)
    }
    
    static func decodeFromJSON(text: String, encoding: String.Encoding = .utf8) throws -> Self {
        let data = text.data(using: encoding)!
        return try JSONDecoder().decode(Self.self, from: data)
    }
}

extension NSPredicate {
    var sql: String {
        description.replacingOccurrences(of: "\"", with: "'")
    }
}

// MARK: CQI Tuples by SELECT
extension NSPredicate {
    
    convenience init?(format: String?, argv: [Any]) {
        guard let format = format else { return nil }
        self.init(format: format, argumentArray: argv)
    }
}

/*
public extension EOSqliteAdaptor {
    typealias DS = DatabaseSerializable
    
    func first(_ type: AnyEntity.Type,
               from table: String? = nil,
               where format: String? = nil, _ argv: Any...,
               order_by: [Ordering]? = nil
    )
    -> AnyEntity? {
        if let format = format {
            let pred = NSPredicate(format: format, argumentArray: argv)
            return try? first(type.schema, from: table, where: pred, order_by: order_by)
            as? AnyEntity
        } else {
            return try? first(type.schema, from: table, order_by: order_by) as? AnyEntity
        }
    }
    
    func select(_ type: AnyEntity.Type,
                from table: String? = nil,
                where format: String? = nil, _ argv: Any...,
                order_by: [Ordering]? = nil,
                limit: Int = 0) -> [AnyEntity] {
        
        do {
            if let format = format {
                let pred = NSPredicate(format: format, argumentArray: argv)
                return try (select(type.schema, from: table,
                                   where: pred, order_by: order_by, limit: limit)
                            as? [AnyEntity]) ?? []
            } else {
                return try (select(type.schema, from: table,
                                   order_by: order_by, limit: limit)
                            as? [AnyEntity]) ?? []
            }
        } catch {
            //            log(error)
            return []
        }
    }
    
    // jmj

    func select<A: DS>(_ col: String, from table: String,
                       where format: String? = nil, _ argv: Any...,
                       order_by: [Ordering]? = nil) -> [A] {
        var records: [A] = []
        do {
            try db.select([col], from: table,
                          where: NSPredicate(format: format, argv: argv)?.sql,
                          order_by: order_by, limit: 1) { row in
                let rec = try A.deserialize(from: row[0])
                records.append(rec)
            }
        } catch {
            log(error)
        }
        return records
    }
    
    func first<A: DS>(_ col: String, from table: String,
                      where format: String? = nil, _ argv: Any...,
                      order_by: [Ordering]? = nil) -> A? {
        var record: A?
        do {
            try db.select([col], from: table,
                          where: NSPredicate(format: format, argv: argv)?.sql,
                          order_by: order_by, limit: 1) { row in
                record = try A.deserialize(from: row[0])
            }
        } catch {
            log(error)
        }
        return record
    }
    
    func first<A:DS, B:DS>(_ cols: [String], from table: String,
                           where format: String? = nil, _ argv: Any...,
                           order_by: [Ordering]? = nil) -> (A?, B?)? {
        var record: (A?, B?)?
        do {
            try db.select(cols, from: table,
                          where: NSPredicate(format: format, argv: argv)?.sql,
                          order_by: order_by, limit: 1) { row in
                record = (
                    try A.deserialize(from: row[0]),
                    try B.deserialize(from: row[1])
                )
            }
        } catch {
            log(error)
        }
        return record
    }
    
    func first<A:DS, B:DS, C:DS>
    (_ cols: [String], from table: String,
     where format: String? = nil, _ argv: Any...,
     order_by: [Ordering]? = nil) -> (A?, B?, C?)?
    {
        var record: (A?, B?, C?)?
        do {
            try db.select(cols, from: table,
                          where: NSPredicate(format: format, argv: argv)?.sql,
                          order_by: order_by, limit: 1) { row in
                record = (
                    try A.deserialize(from: row[0]),
                    try B.deserialize(from: row[1]),
                    try C.deserialize(from: row[2])
                )
            }
        } catch {
            log(error)
        }
        return record
    }
}

// MARK: CQI Config SELECT

public extension EOSqliteAdaptor {
    
    // Primary entry method
    func first<C: AnyEntity>(_ type: C.Type = C.self,
                             from table: String? = nil,
                             where format: String? = nil, _ argv: Any...,
                             order_by: [Ordering]? = nil
    )
    -> C? {
        if let format = format {
            let pred = NSPredicate(format: format, argumentArray: argv)
            return try? first(type.schema, from: table, where: pred, order_by: order_by) as? C
        } else {
            return try? first(type.schema, from: table, order_by: order_by) as? C
        }
    }
    
    /*
    func first(_ cfg: CQIConfig,
               from table: String? = nil,
               where predicate: NSPredicate? = nil,
               order_by: [Ordering]? = nil
    ) throws -> Any? {
        
        let table = table ?? cfg.table
        let cols = cfg.columns()// cfg.slots.map { $0.column }
        
        var record: Any?
        do {
            try db.select(cols, from: table,
                          where: predicate?.sql,
                          order_by: order_by, limit: 1) { row in
                record = try create(cfg, from: row)
            }
        } catch {
            log(error)
            throw error
        }
        return record
    }
    
    // Primary entry method for Collections
    func select<C: AnyEntity>(_ type: C.Type = C.self,
                              from table: String? = nil,
                              where format: String? = nil, _ argv: Any...,
                              order_by: [Ordering]? = nil,
                              limit: Int = 0) -> [C] {
        
        do {
            if let format = format {
                let pred = NSPredicate(format: format, argumentArray: argv)
                return try (select(type.schema, from: table,
                                   where: pred, order_by: order_by, limit: limit)
                            as? [C]) ?? []
            } else {
                return try (select(type.schema, from: table,
                                   order_by: order_by, limit: limit)
                            as? [C]) ?? []
            }
        } catch {
            log(error)
            return []
        }
    }
    
    func select(_ cfg: CQIConfig,
                from table: String? = nil,
                where predicate: NSPredicate? = nil,
                order_by: [Ordering]? = nil,
                limit: Int = 0) throws -> [Any] {
        
        let table = table ?? cfg.table
        let cols = cfg.columns()
        
        var recs: [Any] = []
        do {
            try db.select(cols, from: table, where: predicate?.sql,
                          order_by: order_by, limit: limit) { row in
                let nob = try create(cfg, from: row)
                recs.append(nob)
            }
        } catch {
            log(error)
            throw error
        }
        return recs
    }
    
    func create(_ cfg: CQIConfig, from row: Row) throws -> Any {
        
        //        guard var nob = try createInstance(of: cfg.type) as? AnyEntity
        //        else { throw CQIError("Unable to createInstance of \(cfg.type)") }
        
        var nob = try cfg.createInstance()
        
        for slot in cfg.slots where !slot.isExcluded {
            
            let property = slot.info
            var valueType: Any.Type = property.type
            
            if property.isOptional,
               let pinfo = try? typeInfo(of: property.type),
               let elementType = pinfo.elementType {
                valueType = elementType
            }
            
            // FIXME: Add the ability to use a ValueTransformer here
            // Actually will need to create a Swifty TypeTransformer
            // Using the slot.column (a String) is more convenient
            // programatically but not as performant as ndx could be(?)
            
            let db_value = try row.value(named: slot.columns[0])
            let value: Any?
            
            switch valueType {
                    
                case _ where db_value.isNull:
                    value = nil
                    
                case is String.Type:
                    value = db_value.stringValue
                    
                case is Data.Type:
                    value = db_value.dataValue
                    
                case let f as AnyEntity.Type:
                    value = try create(f.schema, from: row)
                    
                case let f as DatabaseSerializable.Type where !db_value.isNull:
                    value = try f.deserialize(from: db_value)
                    
                case let f as Decodable.Type where !property.sealed:
                    
                    switch db_value {
                        case .null:
                            value = nil
                        case let DatabaseValue.blob(data):
                            value = try f.decodeFromJSON(data: data)
                        case let DatabaseValue.text(str):
                            value = try f.decodeFromJSON(text: str)
                        default:
                            // Primative DB types are Decodable
                            // But should we throw?
                            value = db_value.anyValue
                    }
                    
                default:
                    value = db_value.anyValue
            }
            try property.set(value: value as Any, on: &nob)
        }
        nob.postload()
        return nob
    }
}

public extension EOSqliteAdaptor {
    
    @discardableResult
    func delete<E: AnyEntity>(_ nob: E) throws -> Int {
        try db.delete(from: E.schema.table, where: "id = \(nob.id)")
        return db.changes
    }
    
    func delete(all type: AnyEntity.Type)
    throws -> Int
    {
        try db.delete(from: type.schema.table, where: "", confirmAll: true)
        return db.changes
    }
    
    func delete(any type: AnyEntity.Type, where format: String, _ argv: Any...)
    throws -> Int
    {
        let pred = NSPredicate(format: format, argumentArray: argv)
        try db.delete(from: type.schema.table, where: pred.sql)
        return db.changes
    }
    
    func columnsAndValues<E: AnyEntity>(_ nob: E,
                                        alter: [String:ParameterBindable] = [:])
    throws -> ([String], [ParameterBindable?]) {
        let cfg = E.schema
        var cols: [String] = []
        var values: [ParameterBindable?] = []
        
        // FIXME: New design allows for nested structs to hold multiple
        // column values
        for slot in cfg.slots where slot.hasColumnValue {
            let property = try cfg.info.property(named: slot.name)
            cols.append(slot.columns[0])
            if let altv = alter[property.name] {
                values.append(altv is NSNull ? nil : altv)
            } else {
                try values.append(property.get(from: nob) as? ParameterBindable)
            }
        }
        return (cols, values)
    }
    
    @discardableResult
    func insert<E: AnyEntity>(_ nob: E) throws -> Int64 {
        // guard nob.id == nil else { throw }
        let (cols, values) = try columnsAndValues(nob)
        try db.insert(E.schema.table, cols: cols, to: values)
        return db.lastInsertRowid ?? nob.id
    }
    
    @discardableResult
    func update<E: AnyEntity>(_ nob: E) throws -> Int {
        // guard nob.id != nil else { throw }
        let (cols, values) = try columnsAndValues(nob)
        try db.update(E.schema.table, cols: cols, to: values)
        return db.changes
    }
    
    @discardableResult
    func duplicate<E: AnyEntity>(_ nob: E) throws -> Int {
        
        let cfg = E.schema
        var clone = nob // .clone() if Clonable
        clone.id = EntityID()
        let (cols, values) = try columnsAndValues(clone)
        try db.insert(cfg.table, cols: cols, to: values)
        return Int(db.lastInsertRowid ?? 0)
    }
    
    func upsert<E: AnyEntity>(_ nob: inout E) throws {
        
        let cfg = E.schema
        let (cols, values) = try columnsAndValues(nob)
        if nob.id == 0 {
            try db.insert(cfg.table, cols: cols, to: values)
            if let rowid = db.lastInsertRowid {
                nob.id = EntityID(rowid)
            }
        } else {
            try db.update(cfg.table, cols: cols, to: values)
        }
    }
}
*/
    
*/

