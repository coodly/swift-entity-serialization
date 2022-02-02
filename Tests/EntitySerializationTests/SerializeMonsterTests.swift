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
        
        let asset = try XCTUnwrap(records[0]["levels"] as? CKAsset)
        
        let assetURL = asset.fileURL
        XCTAssertNotNil(assetURL)
        let assetData = try Data(contentsOf: assetURL!)
        let decoder = JSONDecoder()
        let loaded = try decoder.decode([EntityDescription].self, from: assetData)
        XCTAssertEqual(3, loaded.count)
        XCTAssertEqual("MonsterLevel", loaded[0].name)
        XCTAssertEqual(6, loaded[0].values.count)
    }
    
    func testWriteMonsterWithExpansion() throws {
        let expansion = persistence.viewContext.createExpansion(named: "Gorm")
        
        let monster = CKRecord(recordType: "Monster", recordID: CKRecord.ID(recordName: "monster-screaming-antelope", zoneID: .default))
        monster["name"] = "Screaming Antelope"
        monster["expansion"] = CKRecord.Reference(recordID: CKRecord.ID(recordName: expansion.recordName!, zoneID: .default), action: .none)
        let write = CoreDataWrite(context: persistence.viewContext, serialize: [.monster])
        try write.write(record: monster)
        
        let loaded = try persistence.viewContext.existingMonster()
        XCTAssertNotNil(loaded)
        XCTAssertEqual("Screaming Antelope", loaded?.name)
        XCTAssertNotNil(loaded?.expansion, "Expansion not marked")
    }
    
    func testWriteMonsterWithLevels() throws {
        let levels: [EntityDescription] = [
            EntityDescription(
                name: "MonsterLevel",
                values: [
                    FieldValue(name: "level", number: NSNumber(value: 8)),
                    FieldValue(name: "positionMonster", number: NSNumber(value: 9)),
                    FieldValue(name: "positionSurvivors", number: NSNumber(value: 10)),
                    
                    FieldValue(name: "baseMovement", number: NSNumber(value: 11)),
                    FieldValue(name: "baseToughness", number: NSNumber(value: 12)),
                    
                    FieldValue(name: "tokenMovement", number: NSNumber(value: 13))
                ]
            ),
            EntityDescription(
                name: "MonsterLevel",
                values: [
                    FieldValue(name: "level", number: NSNumber(value: 4)),
                    FieldValue(name: "positionMonster", number: NSNumber(value: 5)),
                    FieldValue(name: "positionSurvivors", number: NSNumber(value: 6)),
                    
                    FieldValue(name: "baseMovement", number: NSNumber(value: 7)),
                    FieldValue(name: "baseToughness", number: NSNumber(value: 8)),
                    
                    FieldValue(name: "tokenMovement", number: NSNumber(value: 9))
                ]
            )
        ]
        
        let data = try EncodeEntity().encoder.encode(levels)
        let monster = CKRecord(recordType: "Monster", recordID: CKRecord.ID(recordName: "monster-gorm", zoneID: .default))
        monster["name"] = "Gorm"
        monster["levels"] = CKAsset(fileURL: URL(fileURLWithPath: NSTemporaryDirectory()))
        
        let dummyExtract = AssetDataExtract(onDataForAsset: { _, _ in return data})
        
        let write = CoreDataWrite(context: persistence.viewContext, serialize: [.monster])
        
        try write.write(record: monster, assetExtract: dummyExtract)
        
        let loaded = try persistence.viewContext.existingMonster()
        persistence.save()
        XCTAssertNotNil(loaded)
        XCTAssertNotNil(loaded?.levels)
        XCTAssertEqual(2, loaded?.levels?.count)
        
        let checked = try XCTUnwrap(loaded?.levels?.first(where: { $0.level == NSNumber(value: 4) }))
        XCTAssertEqual(NSNumber(value: 4), checked.level)
        XCTAssertEqual(NSNumber(value: 5), checked.positionMonster)
        XCTAssertEqual(NSNumber(value: 6), checked.positionSurvivors)
        XCTAssertEqual(NSNumber(value: 7), checked.baseMovement)
        XCTAssertEqual(NSNumber(value: 8), checked.baseToughness)
        XCTAssertEqual(NSNumber(value: 9), checked.tokenMovement)
    }
    
    func testOnUpdateExistingLevelsRemoved() throws {
        let monster = persistence.viewContext.createMonster(named: "Flower Knight")
        monster.recordName = "monster-flower-knight"
        monster.name = "Flower Knight"
        persistence.viewContext.createTestLevel().monster = monster
        persistence.viewContext.createTestLevel(modify: 1).monster = monster
        persistence.save()
        
        let level = EntityDescription(
            name: "MonsterLevel",
            values: [
                FieldValue(name: "level", number: NSNumber(value: 8)),
                FieldValue(name: "positionMonster", number: NSNumber(value: 9)),
                FieldValue(name: "positionSurvivors", number: NSNumber(value: 10)),
                
                FieldValue(name: "baseMovement", number: NSNumber(value: 11)),
                FieldValue(name: "baseToughness", number: NSNumber(value: 12)),
                
                FieldValue(name: "tokenMovement", number: NSNumber(value: 13))
            ]
        )
        let data = try EncodeEntity().encoder.encode([level])
        
        let record = CKRecord(recordType: "Monster", recordID: CKRecord.ID(recordName: "monster-flower-knight", zoneID: .default))
        record["name"] = "Changed Flower Knight"
        record["levels"] = CKAsset(fileURL: URL(fileURLWithPath: NSTemporaryDirectory()))
        
        let dummyExtract = AssetDataExtract(onDataForAsset: { _, _ in return data})
        
        let write = CoreDataWrite(context: persistence.viewContext, serialize: [.monster])
        
        try write.write(record: record, assetExtract: dummyExtract)

        persistence.save()
        persistence.viewContext.refresh(monster, mergeChanges: true)
        XCTAssertEqual("Changed Flower Knight", monster.name)
        XCTAssertEqual(1, monster.levels?.count)
        XCTAssertEqual(8, monster.levels?.first?.level.intValue)
        XCTAssertEqual(1, try persistence.viewContext.numberOfLevels())
    }
    
    func testWriteUnmappedRecordType() {
        let record = CKRecord(recordType: "Cake", recordID: CKRecord.ID(recordName: "fake-cake"))
        let write = CoreDataWrite(context: persistence.viewContext, serialize: [.monster])
        XCTAssertThrowsError(try write.write(record: record)) {
            XCTAssertEqual(SerializationError.unmappedRecordType("Cake"), $0 as? SerializationError)
        }
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
