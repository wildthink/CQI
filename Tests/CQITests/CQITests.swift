    import XCTest
    @testable import CQI

    final class CQITests: XCTestCase {
        func testExpression() {
//            let ex = NSExpression(forKeyPath: \Topic.name)
//            print (ex)
        }
        
        func testModel() {
            let url = URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent()
                .appendingPathComponent("Resources")
                .appendingPathComponent("Contacts")
            let model = NSManagedObjectModel(model: url)
            XCTAssertNotNil(model)
//            print (model!)
        }
    }


struct Topic {
    var id: Int64 = 0
    var name: String = "Jose"
}

