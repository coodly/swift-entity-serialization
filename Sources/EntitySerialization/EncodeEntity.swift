import CoreData
import Foundation

public class EncodeEntity {
  private(set) internal lazy var encoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    return encoder
  }()
    
  public init() {
        
  }
    
  public func encodeEntity(_ entity: NSManagedObject) throws -> Data? {
    guard let encoded = convert(entity: entity) else {
      return nil
    }
        
    return try encoder.encode(encoded)
  }
    
  public func encodeEntities(_ entities: [NSManagedObject]) throws -> Data? {
    let encoded = entities.compactMap(convert(entity:))
    return try encoder.encode(encoded)
  }
    
  private func convert(entity: NSManagedObject) -> EntityDescription? {
    guard let name = entity.entity.name else {
      return nil
    }
        
    var values = [FieldValue]()
    for (name, attribute) in entity.entity.attributesByName {
      switch attribute.attributeType {
      case .integer16AttributeType, .integer32AttributeType, .integer64AttributeType:
        if let number = entity.value(forKey: name) as? NSNumber {
          values.append(FieldValue(name: name, number: number))
        }
      default:
        fatalError(name)
      }
    }
        
    values.sort(by: { $0.name < $1.name })
    return EntityDescription(name: name, values: values)
  }
}
