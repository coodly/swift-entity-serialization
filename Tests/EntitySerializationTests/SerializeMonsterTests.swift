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
    
    func testMonsterWithExpansionToRecord() {
        let monster = persistence.viewContext.createMonster(named: "White Lion")
        monster.recordName = "monster-white-lion"
        monster.expansion = persistence.viewContext.createExpansion(named: "Slenderman")
        monster.expansion?.recordName = "expansion-slenderman"
        
        let serialize = CloudKitSerialize(serlialize: [.monster])
        let records = serialize.serialize(entities: [monster], in: CKRecordZone.default())
        XCTAssertEqual(1, records.count)
        let checked = records[0]
        dump(checked)
        XCTAssertEqual("White Lion", checked["name"])
        XCTAssertEqual("Monster", checked.recordType)
        XCTAssertEqual("monster-white-lion", checked.recordID.recordName)
        XCTAssertEqual("expansion-slenderman", (checked["expansion"] as? CKRecord.Reference)?.recordID.recordName)
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
