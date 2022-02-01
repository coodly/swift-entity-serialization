public enum SerializationError: Error {
    case referenceWrongType(String)
    case couldNotCreateReference(String)
    case entitiesListNotList(String)
}
