//
//  Database.swift
//  Database
//
//  Created by Jason Jobe on 9/3/21.
//
import Foundation
import FeistyDB


public struct FetchRequest {
        
    var entity: EntityTypeKey = "<Any>"
    
    var predicate: NSPredicate?
    var sorts: NSSortDescriptor?
    
    var fetchLimit: Int = 0
    var batchSize: Int = 0
    var fetchOffset: Int = 0
}

public struct QueryResults<EO: Entity>: RandomAccessCollection {
    // Use of the explicit NSArray provides a compatability for
    // CoreData (or other framework) to provide a lazy NSArray
    private let results: NSArray
    
    internal init(results: NSArray = NSArray()) {
        self.results = results
    }
    
    public var count: Int { results.count }
    public var startIndex: Int { 0 }
    public var endIndex: Int { count }
    
    public subscript(position: Int) -> EO {
        results.object(at: position) as! EO
    }
}

public extension QueryResults {
    static var empty: QueryResults {
        QueryResults()
    }
}

public class DataStore: ObservableObject {
    var name: String = "<datastore>"
    var id: Int64
    var schema: EOModel
//    var datasets: [String: [AnyEntity]] = [:]
    var idGenerator = EIDGenerator(groupNumber: 1)
    
    init(schema: EOModel) {
        self.id = idGenerator.nextValue()
        self.schema = schema
    }
    
    
    func fetch<EO: Entity>(request: FetchRequest = .all) -> [EO] {
//        let key = "\(type(of: EO.self))"
        return []
//        return (datasets[key] as? [EO]) ?? []
    }

    func first<EO: Entity>(request: FetchRequest = .all) -> EO? {
        //        let key = "\(type(of: EO.self))"
        return nil
        //        return (datasets[key] as? [EO]) ?? []
    }

//    func fetch<Q: QueryFilter>(filter: Q) -> [Q.ResultType] {
//        let key = "\(type(of: Q.ResultType.self))"
//        return (datasets[key] as? [Q.ResultType]) ?? []
//    }
}

// Mutating Operations
import Combine

extension DataStore {
    @discardableResult
    func insert<A: Entity>(items: [A]) -> Self {
//        let key = "\(type(of: elementType))"
//        datasets[key] = data
        return self
    }
    
    @discardableResult
    func insert<A: Entity>(_ nob: A) -> Self {
//        let key = "\(type(of: elementType))"
//        datasets[key]?.append(nob)
        return self
    }

    func delete<A: Entity>(_ nob: A) -> Bool {
        //        let key = "\(type(of: elementType))"
        //        datasets[key]?.append(nob)
        return false
    }
    
    func delete(id: EntityID) -> Bool {
        //        let key = "\(type(of: elementType))"
        //        datasets[key]?.append(nob)
        return false
    }
    
    // TODO: Add operation queue parameters to step() and request()
    
    func step<E: Entity>(_ eo: E, fn: @escaping (inout E) -> Void) {
        var nob = eo
        fn(&nob)
        print (nob, eo)
    }
    
    func request<E: Entity>(_ eo: E, fn: @escaping (Self, inout E) -> Void) {
        var nob = eo
        fn(self as! Self, &nob)
        print (nob, eo)
    }
}


class SQLiteAdaptor: ObservableObject {
    var schema: EOModel
    var dataStore: DataStore?
    var request: FetchRequest?

    init(schema: EOModel) {
        self.schema = schema
    }

    func fetchIfNecessary() {
        guard let ds = dataStore else {
            fatalError("Attempting to execute a @Query but the DataStore is not in the environment")
        }
        guard let f = request else {
            fatalError("Attempting to execute a @Query without a Request")
        }
        
        print (#function, ds.name, f)

//        let shouldFetch = true
        
//            let request = f.fetchRequest(ds)
        // if the fetchRequest is empty or has changed then shouldFetch = true

//        if shouldFetch {
//            let resultsArray = ds.fetch(request: f) as [Entity]
//                let resultsArray = ds.fetch(filter: f)
//            results = QueryResults(results: resultsArray as NSArray)
//        }
    }

}

#if canImport(SwiftUI)
import SwiftUI

@available(macOS 11.0, *)
@propertyWrapper
public struct Query<EO: Entity>: DynamicProperty {
    @EnvironmentObject private var dataStore: DataStore
//    @StateObject private var core: SQLiteAdaptor
    @State private var results: QueryResults<EO> = .empty
    
    private let baseFilter: FetchRequest
    
    public var wrappedValue: QueryResults<EO> { results }
    
    public init(_ filter: FetchRequest) {
        self.baseFilter = filter
    }
    
    // Does this need to be `mutating`?
    public mutating func update() {
//        if core.dataStore == nil { core.dataStore = dataStore }
//        if core.request == nil { core.request = baseFilter }
//        core.fetchIfNecessary()
//        core.executeQuery(dataStore: dataStore, filter: baseFilter)
    }
    
    public var projectedValue: Self {
        self
    }

    public func edit(_ ndx: Int, fn: (inout EO) -> Void) {
//        results.objectWillChange.send()
        var nob = results[ndx]
        fn(&nob)
//        print (nob)
//        let key = "\(type(of: nob)).Type"
//        dataStore.datasets[key]?[ndx] = nob
    }
}

public extension FetchRequest {
    static var all: FetchRequest { FetchRequest() }
    static func id(_ eid: EntityID) -> FetchRequest { FetchRequest() }
}

#endif
