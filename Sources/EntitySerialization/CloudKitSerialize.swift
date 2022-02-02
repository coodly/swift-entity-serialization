import CloudKit
import CoreData

public class CloudKitSerialize {
    private let serialize: [RecordSerialize]
    public init(serlialize: [RecordSerialize]) {
        self.serialize = serlialize
    }
    
    public func serialize(entities: [NSManagedObject], in zone: CKRecordZone) throws -> [CKRecord] {
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
                
                if field.field.valueType == field.attribute.valueType, field.field.valueType == .reference {
                    guard let entity = value as? NSManagedObject else {
                        throw SerializationError.referenceWrongType(field.attribute.name)
                    }
                    
                    guard let reference =  CKRecord.Reference(entity: entity, in: zone) else {
                        throw SerializationError.couldNotCreateReference(field.attribute.name)
                    }

                    record.setValue(reference, forKey: field.field.name)
                    continue
                }
                
                if field.field.valueType == field.attribute.valueType {
                    record.setValue(value, forKey: field.field.name)
                    continue
                }
                
                switch (field.attribute.valueType, field.field.valueType) {
                case (.string, .int64List):
                    let string = value as! String
                    let numbers = string.components(separatedBy: SystemValue.numberSeparator).compactMap(Int.init).map(NSNumber.init)
                    record.setValue(numbers, forKey: field.field.name)
                case (.entitiesList, .jsonData) where (value as? NSSet)?.count == 0:
                    break
                case (.entitiesList, .jsonData):
                    guard let entities = value as? Set<NSManagedObject> else {
                        throw SerializationError.entitiesListNotList(field.attribute.name)
                    }
                    
                    let encode = EncodeEntity()
                    guard let data = try encode.encodeEntities(Array(entities)) else {
                        continue
                    }
                    
                    let assetURL = try createTempFile(with: data)
                    record.setValue(CKAsset(fileURL: assetURL), forKey: field.field.name)
                default:
                    throw SerializationError.unhandledTransformation(field.attribute.valueType, field.field.valueType)
                }
            }
            
            records.append(record)
        }
        
        return records
    }
    
    private func createTempFile(with data: Data) throws -> URL {
        let tmpDir = URL(fileURLWithPath: NSTemporaryDirectory())
        try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
        
        let file = tmpDir.appendingPathComponent(ProcessInfo().globallyUniqueString)
        try data.write(to: file, options: .atomic)
        return file
    }
}

extension CKRecord.Reference {
    fileprivate convenience init?(entity: NSManagedObject, in zone: CKRecordZone) {
        guard let recordName = entity.value(forKey: SystemField.recordName) as? String else {
            return nil
        }
        
        self.init(recordID: CKRecord.ID(recordName: recordName, zoneID: zone.zoneID), action: .none)
    }
}
