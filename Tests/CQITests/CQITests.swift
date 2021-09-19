import XCTest
@testable import CQI
import MomXML
//import SnapshotTesting

final class CQITests: XCTestCase {
    
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
    
    func testSchema() throws {
        let schema = try EOModel([Topic.self])
//        print (schema.model.entities.count, schema.model)
        let sql = schema.createTablesSQL()
        print (sql)
    }
    
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
}


struct Topic: Entity {
    static let entityType: EntityTypeKey = "Topic"
    var id: Int64 = 0
    var name: String = "Jose"
}

