//
//  Filter_ArtApp.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/11/23.
//

import SwiftUI

@main
struct Filter_ArtApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
		}
    }
}
