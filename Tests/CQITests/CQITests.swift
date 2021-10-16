import XCTest
@testable import CQI
import MomXML
import SnapshotTesting
import Runtime

extension EIDGenerator {
    func callAsFunction() -> EntityID {
        let ndx = self.nextValue(group: nil)
        return EntityID(ndx)
    }
}

final class CQITests: XCTestCase {
    
    var egen = EIDGenerator(groupNumber: 0)
    
    func testModel() throws {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("Resources")
            .appendingPathComponent("Contacts.xcdatamodel")
        
        let model = try MomModel(contentsOf: url)!
        XCTAssertNotNil(model)
//        let cdm = model.coreData
//        print (cdm)
    }
    
    func testRuntime() throws {
        var t = Topic(id: egen())
        let info = try typeInfo(of: Topic.self)
        let pinfo = try info.property(named: "const")
        print (t.name, t.const)
        let first = t.const
        try pinfo.set(value: 78.0, on: &t)
        let second = t.const
        print (t.name, t.const)
        XCTAssert(first != second)
    }
    
    func testSchema() throws {
        let schema = try EOModel([Topic.self])
        let sql = schema.createTablesSQL()
        assertSnapshot(matching: sql, as: .lines)
    }
    
    func testSelectSQL() throws {
        let schema = try EOModel([Topic.self])
        let sql = schema.facets.first!.selectSQL()
        assertSnapshot(matching: sql, as: .lines)
    }

    /*
    func testDatabase() throws {
        let schema = try EOModel([Topic.self])
        let db = DataStore(schema: schema)

        let rec = Topic()
         db.insert(rec)
        
        db.step(rec) {
            $0.name = "Fred"
        }

//        db.insert(rec, onq: Scheduler)
        
        let recs: [Topic] = db.fetch()
        let r1: Topic? = db.first()
        
        XCTAssert (rec.id == r1?.id)
        XCTAssert (rec.id == recs.first?.id)
    }
     */
}


struct Topic: Entity {
    static let entityType: EntityTypeKey = "Topic"
    var id: EntityID
    var name: String = "Jose"
    var dob: Date?
    let const: Double = 23
}

