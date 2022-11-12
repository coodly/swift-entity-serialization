import CloudKit
import EntitySerialization
@testable import TestModel
import XCTest

final class RecordDeleteTests: XCTestCase {
    private var persistence: Persistence!
    
    override func setUpWithError() throws {
        persistence = Persistence()
        persistence.viewContext.createTestTags()
    }
    
    func testRecordRemoveMappedToLocalName() throws {
        let recordName = "transaction-to-remove"
        let transaction: CDTransaction = try persistence.viewContext.createTestTransaction(recordName: recordName)
        
        let write = CoreDataWrite(context: persistence.viewContext, serialize: [.transaction])
        let remove = RecordRemove(recordId: CKRecord.ID(recordName: recordName), recordType: "Transaction")
        XCTAssertNoThrow(try write.process(removes: [remove]))
        
        XCTAssertNil(try persistence.viewContext.existingTransaction())
    }
}
