import CloudKit
import CoreData

public class CloudKitSerialize {
    private let serialize: [RecordSerialize]
    public init(serlialize: [RecordSerialize]) {
        self.serialize = serlialize
    }
    
    public func serialize(entities: [NSManagedObject], in zone: CKRecordZone) -> [CKRecord] {
        var records = [CKRecord]()
        for entity in entities {
            let definition = entity.entity
            guard let transform = serialize.first(where: { $0.recordName.entityName == definition.name }) else {
                fatalError()
            }
            
            guard let recordName = entity.value(forKey: SystemField.recordName) as? String else {
                fatalError()
            }
            
            let record: CKRecord
            if let data = entity.value(forKey: SystemField.recordData) as? Data {
                let decoder = try! NSKeyedUnarchiver(forReadingFrom: data)
                record = CKRecord(coder: decoder)!
            } else {
                record = CKRecord(recordType: transform.recordName.recordType, recordID: CKRecord.ID(recordName: recordName, zoneID: zone.zoneID))
            }
            
            for field in transform.fields {
                guard let value = entity.value(forKey: field.attribute.name) else {
                    continue
                }
                
                if field.field.valueType == field.attribute.valueType {
                    record.setValue(value, forKey: field.field.name)
                    continue
                }
                
                switch (field.field.valueType, field.attribute.valueType) {
                case (.int64List, .string):
                    let string = value as! String
                    let numbers = string.components(separatedBy: SystemValue.numberSeparator).compactMap(Int.init).map(NSNumber.init)
                    record.setValue(numbers, forKey: field.field.name)
                default:
                    fatalError()
                }
            }
            
            records.append(record)
        }
        
        return records
    }
}
