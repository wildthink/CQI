//
//  Database.swift
//  Database
//
//  Created by Jason Jobe on 9/3/21.
//
import Foundation
import FeistyDB

//    struct LocationSummary: Entity {
//        var id: Int64
//        var name: String
//        var region: String
//        var province: String
//        var geocode: Geocode
//    }
//
//    @Query(.Place, .region(.us)) var locations: QueryResults<LocationSummary>
//
//     View {
//     }
//     .environmentObject(DataStore(url: "memory:test")

public struct FetchRequest {
        
    var entity: EntityType = "<Any>"
    
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


public class DataStore: ObservableObject {
    var name: String = "Dave's Store"
    var id: Int64
    var datasets: [String: [Any]] = [:]
    var idGenerator = EIDGenerator(groupNumber: 1)
    
    init() {
        self.id = idGenerator.nextValue()
    }
    
    
    func fetch<EO: Entity>(request: FetchRequest) -> [EO] {
        let key = "\(type(of: EO.self))"
        return (datasets[key] as? [EO]) ?? []
    }

//    func fetch<Q: QueryFilter>(filter: Q) -> [Q.ResultType] {
//        let key = "\(type(of: Q.ResultType.self))"
//        return (datasets[key] as? [Q.ResultType]) ?? []
//    }

    @discardableResult
    func insert<A: Any>(_ elementType: A.Type = A.self, data: [A]) -> Self {
        let key = "\(type(of: elementType))"
        datasets[key] = data
        return self
    }
}

extension Query {
    private class Core: ObservableObject {
//        private(set) var results: QueryResults<T> = QueryResults()
        var results = QueryResults<EO>()
        var dataStore: DataStore?
//        var filter: T.Filter?
        var request: FetchRequest?

        /*
        func executeQuery(dataStore: DataStore, filter: T.Filter) {
//            print (#function, dataStore.name)
            fetchIfNecessary()
//            let fetchRequest = filter.fetchRequest(dataStore)
//            let context = dataStore.viewContext
            
            // you MUST leave this as an NSArray
//            let results: NSArray = (try? context.fetch(fetchRequest)) ?? NSArray()
//            let results = NSArray()
//            self.results = QueryResults(results: results)
        }
        */
        
        func fetchIfNecessary() {
            guard let ds = dataStore else {
                fatalError("Attempting to execute a @Query but the DataStore is not in the environment")
            }
            guard let f = request else {
                fatalError("Attempting to execute a @Query without a Request")
            }
            
//            print (#function, ds.name)

            let shouldFetch = true
            
//            let request = f.fetchRequest(ds)
            // if the fetchRequest is empty or has changed then shouldFetch = true

            if shouldFetch {
                let resultsArray = ds.fetch(request: f) as [EO]
//                let resultsArray = ds.fetch(filter: f)
                results = QueryResults(results: resultsArray as NSArray)
            }
        }

    }
}

#if canImport(SwiftUI)
import SwiftUI

@propertyWrapper
public struct Query<EO: Entity>: DynamicProperty {
    @EnvironmentObject private var dataStore: DataStore
    @StateObject private var core = Core()
    private let baseFilter: FetchRequest
    
    public var wrappedValue: QueryResults<EO> { core.results }
    
    public init(_ filter: FetchRequest) {
        self.baseFilter = filter
    }
    
    // Does this need to be `mutating`?
    public func update() {
        if core.dataStore == nil { core.dataStore = dataStore }
        if core.request == nil { core.request = baseFilter }
        core.fetchIfNecessary()
//        core.executeQuery(dataStore: dataStore, filter: baseFilter)
    }
    
    public var projectedValue: Self {
        self
    }

    public func mutate(_ ndx: Int, fn: (inout EO) -> Void) {
        core.objectWillChange.send()
        var nob = core.results[ndx]
        fn(&nob)
//        print (nob)
        let key = "\(type(of: nob)).Type"
        dataStore.datasets[key]?[ndx] = nob
    }
}

public extension FetchRequest {
    static var all: FetchRequest { FetchRequest() }
}

#endif
