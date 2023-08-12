//
//  Persistence.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/11/23.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
	
/*
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
 */

    let container: NSPersistentCloudKitContainer

    init() {
        container = NSPersistentCloudKitContainer(name: "FilterArt")
		let groupIdentifier="group.com.apps.celeritas.FilterArt"
		//file url for app group
		if let fileContainerURL=FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier) {
			//store url for sqlite database
			let storeURL=fileContainerURL.appendingPathComponent("FilterArt.sqlite")
			let storeDescription=NSPersistentStoreDescription(url: storeURL)
			//iCloud container identifier
			storeDescription.cloudKitContainerOptions=NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.apps.celeritas.FilterArt")
			//listen to remote changes
			let remoteChangeKey = NSPersistentStoreRemoteChangeNotificationPostOptionKey
			storeDescription.setOption(true as NSNumber,
											   forKey: remoteChangeKey)
			//track history
			storeDescription.setOption(true as NSObject, forKey: NSPersistentHistoryTrackingKey)
			//assign store description
			container.persistentStoreDescriptions=[storeDescription]
			//reflect changes
			container.viewContext.automaticallyMergesChangesFromParent=true
			//trump merge policy
			container.viewContext.mergePolicy=NSMergeByPropertyObjectTrumpMergePolicy
			try? container.viewContext.setQueryGenerationFrom(.current)
		}
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let _ = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                //fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
