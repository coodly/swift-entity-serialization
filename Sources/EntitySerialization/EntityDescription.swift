import Foundation

public struct EntityDescription: Codable {
  let name: String
  let values: [FieldValue]
}

internal struct FieldValue: Codable {
  let name: String
  let type: ValueType
  let int64: Int64?
}

internal enum FieldType: String, Codable {
  case int
}


extension FieldValue {
  internal init(name: String, number: NSNumber) {
    self.name = name
    self.type = .int64
    self.int64 = number.int64Value
  }
}
