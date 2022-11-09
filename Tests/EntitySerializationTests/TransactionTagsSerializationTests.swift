import CloudKit
import EntitySerialization
@testable import TestModel
import XCTest

final class TransactionTagsSerializationTests: XCTestCase {
    private var persistence: Persistence!
    
    override func setUpWithError() throws {
        persistence = Persistence()
        persistence.viewContext.createTestTags()
    }

    func testTransactionWithTagsWrite() throws {
        let monster = CKRecord(
            recordType: "Transaction",
            recordID: CKRecord.ID(
                recordName: "monster-screaming-antelope",
                zoneID: .default
            )
        )
        monster["comment"] = "Transaction with tags"
        let tags = ["one", "two", "three", "four"].sorted()
        monster["tags"] = tags
        
        XCTAssertEqual(2, persistence.viewContext.numberOfTags)
        
        let write = CoreDataWrite(context: persistence.viewContext, serialize: [.transaction])
        try write.write(record: monster)
        
        let loaded = try persistence.viewContext.existingTransaction()
        XCTAssertNotNil(loaded)
        XCTAssertEqual("Transaction with tags", loaded?.comment)
        XCTAssertNotNil(loaded?.tags)
        XCTAssertEqual(tags, loaded?.tags?.map(\.tag).sorted())
        XCTAssertEqual(4, persistence.viewContext.numberOfTags)
    }
    
    func testTransactionWithTagsEncode() throws {
        let transaction = try persistence.viewContext.createTestTransaction()

        let serialize = CloudKitSerialize(serlialize: [.transaction])
        let records = try serialize.serialize(entities: [transaction], in: CKRecordZone.default())
        
        let tags = try XCTUnwrap(records[0]["tags"] as? [String])
        XCTAssertEqual(["cake", "bake", "shake", "take"].sorted(), tags.sorted())
    }
}

extension RecordSerialize {
    internal static let transaction = RecordSerialize(
        recordName: RecordName(
            entityName: "CDTransaction",
            recordType: "Transaction"
        ),
        fields: [
            RecordField("account", valueType: .reference),
            RecordField("comment", valueType: .string),
            RecordField(
                attribute: FieldDefinition(
                    name: "tags",
                    valueType: .singleValueUniqueEntity
                ),
                field: FieldDefinition(
                    name: "tags",
                    valueType: .stringList
                )
            )
        ]
    )
}
