import CoreData

internal class CDTransaction: NSManagedObject {
    @NSManaged var recordName: String?
    @NSManaged var recordData: Data?

    
    @NSManaged var comment: String?
    
    @NSManaged var tags: Set<CDTag>?
    @NSManaged var account: CDAccount
}
