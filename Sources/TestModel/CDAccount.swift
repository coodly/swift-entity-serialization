import CoreData

internal class CDAccount: NSManagedObject {
  @NSManaged var recordName: String
  @NSManaged var recordData: Data?

  @NSManaged var name: String
  @NSManaged var transactions: Set<CDTransaction>?
}
