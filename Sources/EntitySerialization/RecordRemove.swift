import CloudKit

public struct RecordRemove {
    public let recordId: CKRecord.ID
    public let recordType: CKRecord.RecordType
    
    public init(recordId: CKRecord.ID, recordType: CKRecord.RecordType) {
        self.recordId = recordId
        self.recordType = recordType
    }
}
