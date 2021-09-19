//
//  File.swift
//  File
//
//  Created by Jason Jobe on 9/12/21.
//
import Foundation
import MomXML

public extension MomModel {
    
    init? (contentsOf url: URL) throws {
        let ext = url.pathExtension
        guard ext == "xcdatamodel" else { return nil }
        let xml = try XMLDocument(contentsOf: url.appendingPathComponent("contents"), options: [])
        self.init(xml: xml.rootDocument?.rootElement())
    }
}

public extension MomEntity {
    
    init(name: String? = nil, for etype: AnyEntity.Type, codeGenerationType: String = "class") {
        let cn = String(describing: etype)
        self.init(name: name ?? cn, representedClassName: cn, codeGenerationType: codeGenerationType)
    }
}

