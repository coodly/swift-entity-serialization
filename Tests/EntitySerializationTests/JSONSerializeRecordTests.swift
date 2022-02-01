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
        
        
        XCTAssertEqual(testJSON, json)
    }
    
    func testJSONToLevel() throws {
        guard let data = testJSON.data(using: .utf8) else {
            XCTFail()
            return
        }
        
        let decode = DecodeEntity()
        guard let entities = try decode.decode(data: data, into: persistence.viewContext) else {
            return
        }
        XCTAssertEqual(1, entities.count)
        guard let loaded = try persistence.viewContext.existingLevel() else {
            return
        }
        XCTAssertEqual(NSNumber(value: 1), loaded.level)
        XCTAssertEqual(NSNumber(value: 2), loaded.positionSurvivors)
        XCTAssertEqual(NSNumber(value: 3), loaded.positionMonster)
        XCTAssertEqual(NSNumber(value: 4), loaded.baseMovement)
        XCTAssertEqual(NSNumber(value: 5), loaded.baseToughness)
        XCTAssertEqual(NSNumber(value: 6), loaded.tokenMovement)
    }
    
    private let testJSON =
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
}
