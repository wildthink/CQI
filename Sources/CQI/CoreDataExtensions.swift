//
//  File.swift
//  
//
//  Created by Jason Jobe on 2/7/21.
//

import CoreData

public extension NSManagedObjectModel {
    
    convenience init? (model: String) {
        guard let file_name = NSManagedObjectModel.modelFileName(name: model)
        else { return nil }
        let url = URL(fileURLWithPath: file_name)
        self.init (contentsOf: url)
    }
    
    convenience init? (model: URL) {
        guard let url = NSManagedObjectModel.modelFileURL(model)
        else { return nil }
        self.init (contentsOf: url)
    }

    convenience init? (model: String, in bundle: Bundle) {
        guard let file_name = NSManagedObjectModel.modelFileName(name: model, in: bundle)
        else { return nil }
        let url = URL(fileURLWithPath: file_name)
        self.init (contentsOf: url)
    }

    convenience init? (model: String, for cl: AnyClass) {
        guard let file_name = NSManagedObjectModel.modelFileName(name: model, for: cl)
        else { return nil }
        let url = URL(fileURLWithPath: file_name)
        self.init (contentsOf: url)
    }

    static func modelFileName(name: String, for cob: AnyClass) -> String? {
        modelFileName(name: name, in: Bundle(for: cob))
    }
    
    static func modelFileName(name: String, in bundle: Bundle) -> String? {
        guard let rpath = bundle.resourcePath else { return nil }
        return modelFileName(name: (rpath as NSString).appendingPathComponent(name))
    }

    static func modelFileName(name: String) -> String? {
        let fm = FileManager()
        let extensions = ["", "xcdatamodel", "xcdatamodeld"]
        
        for ext in extensions {
            let path = "\(name).\(ext)"
            if fm.isReadableFile(atPath: path) { return path }
        }
        // else
        return nil
    }
    
    static func modelFileURL(_ url: URL) -> URL? {
        let fm = FileManager()
        let extensions = ["", "xcdatamodel", "xcdatamodeld"]
        
        for ext in extensions {
            let path = url.appendingPathExtension(ext)
            if fm.isReadableFile(atPath: path.path) { return path }
        }
        // else
        return nil
    }

}

//extension String: Error {
//}


public extension NSAttributeType {
    var sql_type: String {
        switch self {
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

public extension NSAttributeDescription {
    @objc func sql_create() -> String {
        "\(name) \(attributeType.sql_type)"
    }
}

public extension NSDerivedAttributeDescription {
    @objc override func sql_create() -> String {
        guard let dexp = derivationExpression
        else { return name }
        
        return
            "\(name) \(attributeType.sql_type) GENERATED AS (\(dexp.sql)) VIRTUAL"
    }
}

public extension NSExpression {
    var sql: String {
        self.description
    }
}
