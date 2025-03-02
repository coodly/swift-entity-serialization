import CoreData

extension NSManagedObjectContext {
  internal func createTestTags() {
    ["one", "four"].forEach {
      let created = NSEntityDescription.insertNewObject(
        forEntityName: "CDTag", into: self
      ) as! CDTag
            
      created.tag = $0
    }
  }
    
  internal var numberOfTags: Int {
    let request = NSFetchRequest<NSManagedObject>(entityName: "CDTag")
    return (try? count(for: request)) ?? -1
  }
    
  internal func existingTransaction() throws -> CDTransaction? {
    let request = NSFetchRequest<NSManagedObject>(entityName: "CDTransaction")
    return try fetch(request).first as? CDTransaction
  }
    
  internal func createTestTransaction(recordName: String = "cake-bake-shake") throws -> CDTransaction {
    let transaction: CDTransaction = NSEntityDescription.insertNewObject(
      forEntityName: "CDTransaction", into: self
    ) as! CDTransaction
    transaction.account = createTestAccount()
    transaction.comment = "Test Transaction"
    let tags = ["cake", "bake", "shake", "take"]
    let entities = tags.map({
      let created = NSEntityDescription.insertNewObject(
        forEntityName: "CDTag", into: self
      ) as! CDTag
            
      created.tag = $0
      return created
    })
        
    transaction.tags = Set(entities)
    transaction.recordName = recordName
        
    return transaction
  }
    
  @discardableResult
  internal func createTestAccount() -> CDAccount {
    let account = NSEntityDescription.insertNewObject(
      forEntityName: "CDAccount", into: self
    ) as! CDAccount
        
    account.recordName = "account-123"
    account.name = "The Big Money"
        
    return account
  }
}
