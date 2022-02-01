import CloudKit
import CoreData
@testable import EntitySerialization
@testable import TestModel
import XCTest

final class SerializeMonsterTests: XCTestCase {
    private var persistence: Persistence!
    
    override func setUpWithError() throws {
        persistence = Persistence()
    }
    
    func testMonsterWithExpansionToRecord() throws {
        let monster = persistence.viewContext.createMonster(named: "White Lion")
        monster.recordName = "monster-white-lion"
        monster.expansion = persistence.viewContext.createExpansion(named: "Slenderman")
        monster.expansion?.recordName = "expansion-slenderman"
        
        let serialize = CloudKitSerialize(serlialize: [.monster])
        let records = try serialize.serialize(entities: [monster], in: CKRecordZone.default())
        XCTAssertEqual(1, records.count)
        let checked = records[0]
        dump(checked)
        XCTAssertEqual("White Lion", checked["name"])
        XCTAssertEqual("Monster", checked.recordType)
        XCTAssertEqual("monster-white-lion", checked.recordID.recordName)
        XCTAssertEqual("expansion-slenderman", (checked["expansion"] as? CKRecord.Reference)?.recordID.recordName)
    }
    
    func testMonsterWithLevelsToRecord() throws {
        let monster = persistence.viewContext.createMonster(named: "White Lion")
        monster.recordName = "monster-white-lion"
        let levels: [MonsterLevel] = [
            persistence.viewContext.createTestLevel(),
            persistence.viewContext.createTestLevel(modify: 1),
            persistence.viewContext.createTestLevel(modify: 2),
        ]
        monster.levels = Set(levels)
        
        let serialize = CloudKitSerialize(serlialize: [.monster])
        let records = try serialize.serialize(entities: [monster], in: CKRecordZone.default())
        guard let asset = records[0]["levels"] as? CKAsset else {
            XCTFail()
            return
        }
        
        let assetURL = asset.fileURL
        XCTAssertNotNil(assetURL)
        let assetData = try Data(contentsOf: assetURL!)
        let decoder = JSONDecoder()
        let loaded = try decoder.decode([EntityDescription].self, from: assetData)
        XCTAssertEqual(3, loaded.count)
        XCTAssertEqual("MonsterLevel", loaded[0].name)
        XCTAssertEqual(6, loaded[0].values.count)
    }
}

extension RecordSerialize {
    fileprivate static let monster = RecordSerialize(
        recordName: RecordName(name: "Monster"),
        fields: [
            RecordField("name", valueType: .string),
            RecordField("expansion", valueType: .reference),
            RecordField(
                attribute: FieldDefinition(name: "levels", valueType: .entitiesList),
                field: FieldDefinition(name: "levels", valueType: .jsonData)
            )
        ]
    )
}
