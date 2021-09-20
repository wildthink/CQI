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
        let builder = StringBuilder () {
        "SELECT "
        for c in attributes where !c.isTransient {
            if c != attributes.last {
                c.name + ","
            } else {
                c.name
            }
        }
        " FROM " + entityType.description
        }
        return builder.build(separator: " ")
    }
}

extension MomModel {
    
    @StringBuilder
    func createTablesSQL() -> String {
        for e in entities {
            e.createTableSQL()
        }
//        return entities.map { $0.createTableSQL() }.joined(separator: "\n")
    }
}

extension String {
    static var tab: String { "\t" }
    static var nl: String { "\n" }
}
extension MomEntity {
    
    @StringBuilder
    func createTableSQL() -> String {
        
        "CREATE TABLE \(self.name) ("
        for col in attributes {
            if col == attributes.last {
                .tab + col.createColumnSQL()
            } else {
                .tab + col.createColumnSQL() + ","
            }
        }
        ");"
    }


//    func createTableSQL() -> String {
//        let columns = self.attributes.map { $0.createColumnSQL() }
//
//        return """
//            CREATE TABLE \(self.name) (
//                \(columns.joined(separator: ",\n\t"))
//            );
//        """
//    }
}

extension MomAttribute {
    
    @StringBuilder
    func createColumnSQL() -> String {
        if isDerived {
          "\(name) \(sqliteType) GENERATED AS (\(derivationExpression ?? name)) VIRTUAL"
        } else {
            if name == "id" {
                "\(name) \(sqliteType) PRIMARY KEY"
            } else {
                "\(name) \(sqliteType)"
            }
        }
    }

//    func createColumnSQL() -> String {
//        isDerived
//        ? "\(name) \(sqliteType) GENERATED AS (\(derivationExpression ?? name)) VIRTUAL"
//        : (name == "id"
//           ? "\(name) \(sqliteType) PRIMARY KEY"
//           : "\(name) \(sqliteType)")
//    }
    
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

//public extension NSDerivedAttributeDescription {
//    @objc override func sql_create() -> String {
//        guard let dexp = derivationExpression
//        else { return name }
//
//        return
//        "\(name) \(attributeType.sql_type) GENERATED AS (\(dexp.sql)) VIRTUAL"
//    }
//}

public extension NSExpression {
    var sql: String {
        self.description
    }
}
