//
//  CoreDataStorage.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 14.06.2021.
//

import Foundation
import CoreData

protocol ICoreDataStorage {
    func get<T: ManagedObjectEncodable>(objectsOfType type: T.Type) -> [T]
    func save<T: ManagedObjectEncodable>(object: T)
    func remove<T: ManagedObjectEncodable>(objectOfType type: T.Type, id: Int)
}

// TODO: Убрать force unwrap
final class CoreDataStorage: ICoreDataStorage {
    
    func save<T: ManagedObjectEncodable>(object: T) {
        #if DEBUG
        if isPreview { return }
        #endif
        
        if var existingObject = getManagedObject(for: T.self, id: object.id) {
            existingObject.object = object as! T.ManagedObject.Object
        } else {
            var objectToSave = T.ManagedObject(context: managedObjectContext)
            objectToSave.object = object as! T.ManagedObject.Object
        }
        self.saveContext()
    }
    
    func get<T: ManagedObjectEncodable>(objectsOfType type: T.Type) -> [T] {
        #if DEBUG
        if isPreview { return [] }
        #endif
        
        var result: [T] = []
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "\(type.ManagedObject.self)")
        do {
            let results = try managedObjectContext.fetch(request)
            results.forEach {
                if let t = $0 as? T.ManagedObject {
                    let decodedObject = t.object
                    if let typedObject = decodedObject as? T {
                        result.append(typedObject)
                    }
                }
            }
        } catch {
            Logger.log(error: error)
        }
        return result
    }
    
    func remove<T: ManagedObjectEncodable>(objectOfType type: T.Type, id: Int) {
        #if DEBUG
        if isPreview { return }
        #endif
        
        if let object = getManagedObject(for: type, id: id) {
            managedObjectContext.delete(object)
        }
        self.saveContext()
    }
    
    fileprivate func getManagedObject<T: ManagedObjectEncodable>(for objectOfType: T.Type, id: Int) -> T.ManagedObject? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "\(T.ManagedObject.self)")
        do {
            let results = try managedObjectContext.fetch(request)
            for result in results {
                if let t = result as? T.ManagedObject {
                    if t.object.id == id {
                        return t
                    }
                }
            }
        } catch {
            Logger.log(error: error)
        }
        return nil
    }
    
    // MARK: - Core Data Setup
    
    lazy var applicationDocumentaryDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count - 1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "ShowsTrackerDataModel", withExtension: "momd")
        return NSManagedObjectModel(contentsOf: modelURL!)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentaryDirectory.appendingPathComponent("ShowsTrackerDataModel.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data"
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            var dict = [String: Any]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "ShowsTracker", code: 1000, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    func saveContext() {
        guard managedObjectContext.hasChanges else { return }
        do {
            try managedObjectContext.save()
        } catch {
            let nsError = error as NSError
            NSLog("Unresolved error \(nsError), \(nsError.userInfo)")
            abort()
        }
    }
}
