//
//  File.swift
//  
//
//  Created by Jason Jobe on 9/18/21.
//

import Foundation
import MomXML

extension EOFacet {

    func selectSQL() -> String {
        StringBuilder {
        "SELECT "
        for c in attributes where !c.isTransient {
            c.name
            if c != attributes.last { "," }
        }
        " FROM " + entityType.description
        }
        .build(separator: .empty)
    }
}

extension MomModel {
    
    func createTablesSQL() -> String {
        StringBuilder  {
            for e in entities {
                e.createTableSQL()
            }
        }
        .build(separator: .newline)
    }
}

extension String {
    static var tab: String { "\t" }
    static var newline: String { "\n" }
    static var space: String { " " }
    static var empty: String { "" }
}

extension MomEntity {
    
    func createTableSQL() -> String {
        StringBuilder {
        "CREATE TABLE \(self.name) ("
        for col in attributes {
            if col == attributes.last {
                .tab + col.createColumnSQL()
            } else {
                .tab + col.createColumnSQL() + ","
            }
        }
        ");"
        }.build(separator: .newline)
    }
}

extension MomAttribute {
    
    func createColumnSQL() -> String {
        StringBuilder {
            "\(name) \(sqliteType)"
            if isDerived {
                "GENERATED AS (\(derivationExpression ?? name)) VIRTUAL" }
            else if name == "id" {
                " PRIMARY KEY"
            }
        }.build(separator: .empty)
    }
    
}

extension MomAttribute {
    public var sqliteType: String {
        attributeType.sqliteType
    }
}

extension MomAttribute.AttributeType {
    
    public var sqliteType: String {
        switch self.coreData {
            case .integer16AttributeType,
                    .integer32AttributeType,
                    .integer64AttributeType:
                return "INTEGER"
            case .floatAttributeType,
                    .doubleAttributeType:
                return "REAL"
            case .binaryDataAttributeType:
                return "BLOB"
            case .stringAttributeType:
                return "TEXT"
            case .dateAttributeType:
                return "TEXT DATE"
            default:
                return ""
        }
    }
}

public extension NSExpression {
    var sql: String {
        self.description
    }
}
