public enum SerializationError: Error {
    case referenceWrongType(String)
    case couldNotCreateReference(String)
    case entitiesListNotList(String)
    
    case unhandledTransformation(ValueType, ValueType)
    case unhandledTransformation(ValueType)
}
