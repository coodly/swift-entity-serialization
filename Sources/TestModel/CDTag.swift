import CoreData

internal class CDTag: NSManagedObject {
  @NSManaged var tag: String

  @NSManaged var transactions: Set<CDTransaction>?
}
