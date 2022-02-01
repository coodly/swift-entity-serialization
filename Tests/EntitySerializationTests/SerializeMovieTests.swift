import CloudKit
@testable import EntitySerialization
@testable import TestModel
import XCTest

final class SerializeMovieTests: XCTestCase {
    private var persistence: Persistence!
    
    override func setUpWithError() throws {
        persistence = Persistence()
    }
    
    func testMovieEntityToRecord() throws {
        let movie = persistence.viewContext.createTestMovie()
        let serialize = CloudKitSerialize(serlialize: [.movie])
        let records = serialize.serialize(entities: [movie], in: CKRecordZone.default())
        XCTAssertEqual(1, records.count)
        guard let record = records.first else {
            return
        }
        
        XCTAssertEqual("Movie", record.recordType)
        XCTAssertEqual("move-1234", record.recordID.recordName)
        XCTAssertEqual([1, 2, 3, 4], record["genres"] as? [Int])
        XCTAssertEqual("Test movie one", record["name"] as? String)
        XCTAssertEqual(NSNumber(value: 7), record["rating"] as? NSNumber)
        XCTAssertEqual(NSNumber(value: 8), record["runtime"] as? NSNumber)
        XCTAssertEqual(NSNumber(value: 1234), record["tmdbID"] as? NSNumber)
        XCTAssertEqual(NSNumber(value: 2022), record["year"] as? NSNumber)
    }
}

extension RecordSerialize {
    fileprivate static let movie = RecordSerialize(
        recordName: RecordName(name: "Movie"),
        fields: [
            RecordField(
                attribute: FieldDefinition(name: "internalGenres", valueType: .string),
                field: FieldDefinition(name: "genres", valueType: .int64List)
            ),
            RecordField("name", valueType: .string),
            RecordField("rating", valueType: .double),
            RecordField("runtime", valueType: .int64),
            RecordField("tmdbID", valueType: .int64),
            RecordField("year", valueType: .int64),
        ]
    )
}
