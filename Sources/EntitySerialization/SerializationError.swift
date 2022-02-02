public enum SerializationError: Error, Equatable {
    case referenceWrongType(String)
    case couldNotCreateReference(String)
    case entitiesListNotList(String)
    
    case unhandledTransformation(ValueType, ValueType)
    case unhandledTransformation(ValueType)
    
    case couldNotGetReference(String)
    case noReferenceRelationship(String)
    case noDestinationEntity(String?, String)
    
    case didNotGetAsset(String)
    
    case unmappedRecordType(String)
}
