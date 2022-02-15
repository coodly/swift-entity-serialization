import CloudKit
import CoreData
@testable import EntitySerialization
@testable import TestModel
import XCTest

final class ModificationTimeSerialization: XCTestCase {
    private var persistence: Persistence!
    
    override func setUpWithError() throws {
        persistence = Persistence()
    }

    func testEntityModificationDateNotMarkedOnRecord() throws {
        let video: PrimeVideo = persistence.viewContext.createPrimeVideo()
        video.recordName = "prime-tmdb-123"
        video.tag = "cake-123"
        video.title = "Cake"
        video.modifiedAt = Date()
        video.tmdbID = NSNumber(value: 123)
        
        let cloud = CloudKitSerialize(serlialize: [.primeVideo])
        let records = try cloud.serialize(entities: [video], in: .default())
        let record = try XCTUnwrap(records.first)
        XCTAssertNil(record["modifiedAt"])
    }
}

extension RecordSerialize {
    fileprivate static let primeVideo = RecordSerialize(
        recordName: RecordName(name: "PrimeVideo"),
        fields: [
            RecordField("status", valueType: .string),
            RecordField("tag", valueType: .string),
            RecordField("title", valueType: .string),
            RecordField("tmdbID", valueType: .int64),
            RecordField(
                attribute: FieldDefinition(name: "modifiedAt", valueType: .date),
                field: FieldDefinition(name: "modificationDate", valueType: .date)
            )
        ]
    )
}
