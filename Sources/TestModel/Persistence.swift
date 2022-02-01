import CoreData

internal struct Persistence {
    private let container: NSPersistentContainer
    
    internal var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    internal init() {
        let modelURL = Bundle.module.url(forResource: "TestModel", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: modelURL)!
        container = NSPersistentContainer(name: "TestModel", managedObjectModel: model)
        container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        container.loadPersistentStores(completionHandler: {_, _ in })
    }
}
