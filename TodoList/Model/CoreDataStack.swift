//
//  CoreDataStack.swift
//  Do.Day
//
//  Created by Sunlit.Amo on 24/06/16.
//  Copyright © 2016年 Sunlit.Amo. All rights reserved.
//

import CoreData

class CoreDataStack {
    
    let modelName = "TodoItemDataModel"
    
    public func getContext() -> NSManagedObjectContext {
        
        let psc = self.getPsc();
        let managedObjectContext = NSManagedObjectContext(
            concurrencyType: .mainQueueConcurrencyType)
        
        print("managedObjectContext is \(managedObjectContext)")
        
        managedObjectContext.persistentStoreCoordinator = psc;
        return managedObjectContext
    }
    
    private func getPsc() -> NSPersistentStoreCoordinator {
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.getManagedObjectModel())
        
        let url = self.applicationDocumentsDirectory.appendingPathComponent("TodoItemDataModel.sqlite")
        
        do {
            let options = [NSMigratePersistentStoresAutomaticallyOption : true]
            
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url,options: options)
        } catch  {
            // Report any error we got.
            var dict = [String: AnyObject]()
            let failureReason = "There was an error creating or loading the application's saved data."
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()

        }
        return coordinator
    }
    
    private func getManagedObjectModel() -> NSManagedObjectModel {
        
        let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }
    
    fileprivate lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    public func saveContext () {
        let mContext = self.getContext()
        if mContext.hasChanges {
            do {
                try mContext.save()
            } catch let error as NSError {
                print("Error: \(error.localizedDescription)")
                abort()
            }
        }
    }
}
