import CloudKit
import EntitySerialization
@testable import TestModel
import XCTest

final class TransactionAccountSerializationTests: XCTestCase {
    private var persistence: Persistence!
    
    override func setUpWithError() throws {
        persistence = Persistence()
    }

    func testTransactionAccountMissing() {
        let write = CoreDataWrite(context: persistence.viewContext, serialize: [.transaction])
        XCTAssertThrowsError(try write.write(record: transactionRecord))
    }
    
    func testTransactionAccountLinked() throws {
        persistence.viewContext.createTestAccount()
        let write = CoreDataWrite(context: persistence.viewContext, serialize: [.transaction])
        try write.write(record: transactionRecord)
        
        let loaded = try XCTUnwrap(persistence.viewContext.existingTransaction())
        
        XCTAssertNotNil(loaded.account)
    }
    
    private var transactionRecord: CKRecord {
        let monster = CKRecord(
            recordType: "Transaction",
            recordID: CKRecord.ID(
                recordName: "monster-screaming-antelope",
                zoneID: .default
            )
        )
        monster["account"] = CKRecord.Reference(recordID: CKRecord.ID(recordName: "account-123"), action: .none)
        monster["comment"] = "Transaction with tags"
        let tags = ["one", "two", "three", "four"].sorted()
        monster["tags"] = tags

        return monster
    }
}
