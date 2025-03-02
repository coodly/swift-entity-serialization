import CloudKit

public struct FieldDefinition {
  public let name: String
  public let valueType: ValueType
  internal let zone: CKRecordZone?
}

extension FieldDefinition {
  public init(name: String, valueType: ValueType) {
    self.name = name
    self.valueType = valueType
    self.zone = nil
  }

  public init(reference: String, in zone: CKRecordZone) {
    self.name = reference
    self.valueType = .reference
    self.zone = zone
  }
}
