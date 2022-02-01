import CoreData

internal class Expansion: NSManagedObject {
    @NSManaged var recordName: String?
    @NSManaged var recordData: Data?

    @NSManaged var name: String?
    @NSManaged var monsters: Set<Monster>?
}
