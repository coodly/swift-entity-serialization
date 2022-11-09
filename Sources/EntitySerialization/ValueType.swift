public enum ValueType: String, Codable {
    case double
    case doubleList
    case int64
    case int64List
    case string
    case stringList
    case date
    case dateList
    case reference
    case referenceList
    case assetId
    case unknownList
    
    case asset
    case entitiesList
    case entity
    case jsonData
    case singleValueUniqueEntity
}
