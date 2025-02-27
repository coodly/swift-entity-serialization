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
    XCTAssertNoThrow(try write.remove(record: remove))
        
    XCTAssertNil(try persistence.viewContext.existingTransaction())
  }
    
  func testRemoveWithSameRecordEntityName() throws {
    let recordName = "movie-123-to-delete"
    _ = persistence.viewContext.createTestMovie(recordName: recordName)
        
    let write = CoreDataWrite(context: persistence.viewContext, serialize: [.movie])
    let remove = RecordRemove(recordId: CKRecord.ID(recordName: recordName), recordType: "Movie")
    XCTAssertNoThrow(try write.remove(record: remove))
        
    XCTAssertNil(try persistence.viewContext.existingMovie())
  }
    
  func testRemoveNonExisting() throws {
    let write = CoreDataWrite(context: persistence.viewContext, serialize: [.movie])
    let remove = RecordRemove(recordId: CKRecord.ID(recordName: "the-movie-cake"), recordType: "Movie")
    XCTAssertFalse(try write.remove(record: remove))
  }
}
