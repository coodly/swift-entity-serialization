import CloudKit
import CoreData

public struct AssetDataExtract {
  private let onDataForAsset: ((CKAsset, String) throws -> Data?)
    
  public init(onDataForAsset: @escaping ((CKAsset, String) throws -> Data?)) {
    self.onDataForAsset = onDataForAsset
  }
    
  internal func data(for asset: CKAsset, named: String) throws -> Data? {
    try onDataForAsset(asset, named)
  }
}

extension AssetDataExtract {
  public static let system = AssetDataExtract(
    onDataForAsset: {
      asset, _ in
            
      guard let url = asset.fileURL else {
        return nil
      }
            
      return try Data(contentsOf: url)
    }
  )
}

public class CoreDataWrite {
  private let context: NSManagedObjectContext
  private let serialize: [RecordSerialize]
  public init(context: NSManagedObjectContext, serialize: [RecordSerialize]) {
    self.context = context
    self.serialize = serialize
  }
    
  public func write(record: CKRecord, assetExtract: AssetDataExtract = .system) throws {
    guard let serialization = serialize.first(where: { $0.recordName.recordType == record.recordType }) else {
      throw SerializationError.unmappedRecordType(record.recordType)
    }
        
    let saved: NSManagedObject
    if let existing = context.entity(named: serialization.recordName.entityName, recordName: record.recordID.recordName) {
      saved = existing
    } else {
      saved = NSEntityDescription.insertNewObject(
        forEntityName: serialization.recordName.entityName,
        into: context
      )
    }
        
    saved.setValue(record.recordID.recordName, forKey: SystemField.recordName)
    saved.setValue(record.archived, forKey: SystemField.recordData)
        
    for field in serialization.fields {
      if field.field.name == SystemField.modificationDate {
        saved.setValue(record.modificationDate, forKey: field.attribute.name)
        continue
      }
            
      guard let value = record.value(forKey: field.field.name) else {
        continue
      }
            
      if field.field.valueType == field.attribute.valueType, field.field.valueType == .reference {
        guard let reference = value as? CKRecord.Reference else {
          throw SerializationError.couldNotGetReference(field.field.name)
        }
        try saved.mark(reference: reference, on: field)
        continue
      }
            
      try saved.mark(value: value, on: field, assetExtract: assetExtract)
    }
        
    serialization.loaded(entity: saved, in: context)
  }
    
  public func remove(record remove: RecordRemove) throws -> Bool {
    guard let serialization = serialize.first(where: { $0.recordName.recordType == remove.recordType }) else {
      throw SerializationError.unmappedRecordType(remove.recordType)
    }
        
    let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: serialization.recordName.entityName)
    request.predicate = NSPredicate(format: "recordName = %@", remove.recordId.recordName)
    if let removed = try? context.fetch(request).first {
      context.delete(removed)
      return true
    }
        
    return false
  }
}

extension NSManagedObject {
  fileprivate func mark(value: Any, on field: RecordField, assetExtract: AssetDataExtract) throws {
    if field.field.valueType == field.attribute.valueType, field.field.valueType != .jsonData {
      setValue(value, forKey: field.attribute.name)
      return
    }
        
    switch (field.field.valueType, field.attribute.valueType) {
    case (.referenceList, .entitiesList):
      guard let references = value as? [CKRecord.Reference], !references.isEmpty else {
        return
      }
            
      guard let relationship = entity.relationshipsByName[field.attribute.name], let destination = relationship.destinationEntity else {
        throw SerializationError.noReferenceRelationship(field.attribute.name)
      }
            
      let fetch: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: destination.name ?? "-")
      fetch.predicate = NSPredicate(format: "%K IN %@", "recordName", references.map(\.recordID.recordName))
      let existing = self.value(forKey: field.attribute.name) as? Set<NSManagedObject> ?? []
      let fetched: [NSManagedObject] = try managedObjectContext!.fetch(fetch)
      let updated = existing.union(Set(fetched))
      setValue(updated, forKey: field.attribute.name)
    case (.jsonData, .jsonData):
      guard let asset = value as? CKAsset else {
        throw SerializationError.didNotGetAsset(field.attribute.name)
      }
      guard let data = try assetExtract.data(for: asset, named: field.field.name) else {
        return
      }
      setValue(data, forKey: field.attribute.name)
    case (.int64List, .string):
      let numbers = value as! [NSNumber]
      let transformed = numbers.map(\.int64Value).map(String.init).joined(separator: SystemValue.numberSeparator)
      setValue(transformed, forKey: field.attribute.name)
    case (.jsonData, .entitiesList):
      guard let asset = value as? CKAsset else {
        throw SerializationError.didNotGetAsset(field.attribute.name)
      }
      guard let data = try assetExtract.data(for: asset, named: field.field.name), let context = managedObjectContext else {
        return
      }
      let decode = DecodeEntity()
      guard let loaded = try decode.decode(data: data, into: context) else {
        return
      }
            
      if let existing = self.value(forKey: field.attribute.name) as? Set<NSManagedObject> {
        existing.forEach({ context.delete($0) })
      }
      setValue(NSSet(array: loaded), forKey: field.attribute.name)
    case (.stringList, .singleValueUniqueEntity):
      guard let strings = value as? [String], !strings.isEmpty else {
        return
      }
            
      guard let relationship = entity.relationshipsByName[field.attribute.name], let destination = relationship.destinationEntity else {
        throw SerializationError.noReferenceRelationship(field.attribute.name)
      }
            
      guard let (name, attibute) = destination.attributesByName.first, attibute.isString else {
        throw SerializationError.uniqueValueEntity
      }
            
      let context = managedObjectContext!
            
      let fetch: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: destination.name ?? "-")
      fetch.predicate = NSPredicate(format: "%K IN %@", name, strings)
      let existing: [NSManagedObject] = try context.fetch(fetch)
            
      var mark = [NSManagedObject]()
      for string in strings {
        if let found = existing.first(where: { ($0.value(forKey: name) as? String) == string }) {
          mark.append(found)
        } else {
          let saved: NSManagedObject = NSEntityDescription.insertNewObject(
            forEntityName: destination.name!,
            into: context
          )
                    
          saved.setValue(string, forKey: name)
          mark.append(saved)
        }
      }
            
      setValue(NSSet(array: mark), forKey: field.attribute.name)
    default:
      throw SerializationError.unhandledTransformation(field.field.valueType, field.attribute.valueType)
    }
  }
    
  fileprivate func mark(reference: CKRecord.Reference, on field: RecordField) throws {
    guard let relatsionship = entity.relationshipsByName[field.attribute.name], let destination = relatsionship.destinationEntity else {
      throw SerializationError.noReferenceRelationship(field.attribute.name)
    }
        
    guard let referenced = managedObjectContext?.entity(named: destination.name ?? "-", recordName: reference.recordID.recordName) else {
      throw SerializationError.noDestinationEntity(destination.name, reference.recordID.recordName)
    }
        
    setValue(referenced, forKey: field.attribute.name)
  }
}

extension NSAttributeDescription {
  fileprivate var isString: Bool {
    if #available(iOS 15, macOS 12, tvOS 15, *) {
      return type == .string
    } else {
      return attributeType == .stringAttributeType
    }
  }
}

extension NSManagedObjectContext {
  fileprivate func entity(named: String, recordName: String) -> NSManagedObject? {
    let request = NSFetchRequest<NSManagedObject>(entityName: named)
    request.predicate = NSPredicate(format: "%K = %@", SystemField.recordName, recordName)
    return try? fetch(request).first
  }
}

extension CKRecord {
  internal var archived: Data {
    let coder = NSKeyedArchiver(requiringSecureCoding: true)
    encodeSystemFields(with: coder)
    return coder.encodedData
  }
}
