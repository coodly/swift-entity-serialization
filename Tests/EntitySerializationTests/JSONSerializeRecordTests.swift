import CoreData
@testable import EntitySerialization
@testable import TestModel
import XCTest

final class JSONSerializeRecordTests: XCTestCase {
    private var persistence: Persistence!
    
    override func setUpWithError() throws {
        persistence = Persistence()
    }

    func testLevelToJSON() throws {
        let level = persistence.viewContext.createTestLevel()
        let encode = EncodeEntity()
        guard let data = try encode.encodeEntity(level) else {
            return
        }
        
        guard let json = String(bytes: data, encoding: .utf8) else {
            XCTFail()
            return
        }
        
        let expected =
        """
        {
          "name" : "MonsterLevel",
          "values" : [
            {
              "int64" : 4,
              "name" : "baseMovement",
              "type" : "int64"
            },
            {
              "int64" : 5,
              "name" : "baseToughness",
              "type" : "int64"
            },
            {
              "int64" : 1,
              "name" : "level",
              "type" : "int64"
            },
            {
              "int64" : 3,
              "name" : "positionMonster",
              "type" : "int64"
            },
            {
              "int64" : 2,
              "name" : "positionSurvivors",
              "type" : "int64"
            },
            {
              "int64" : 6,
              "name" : "tokenMovement",
              "type" : "int64"
            }
          ]
        }
        """
        XCTAssertEqual(expected, json)
    }
}
