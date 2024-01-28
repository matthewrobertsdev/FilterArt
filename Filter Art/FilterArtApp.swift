//
//  Filter_ArtApp.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/13/23.
//

import SwiftUI

@main
struct FilterArtApp: App {
	
#if os(macOS)
@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
#endif
	
	@StateObject private var modalStateViewModel = ModalStateViewModel()
	
	@StateObject var imageViewModel = ImageViewModel()
	
	let persistenceController = PersistenceController.shared
	
    var body: some Scene {
        WindowGroup {
            ContentView()
				.environment(\.managedObjectContext, persistenceController.container.viewContext).environmentObject(modalStateViewModel).environmentObject(imageViewModel)
#if os(macOS)
				.frame(minWidth: 800, minHeight: 600)
				.onAppear {
					NSWindow.allowsAutomaticWindowTabbing = false
				}
#endif
        }.commands {
			MenuCommands(modalStateViewModel: modalStateViewModel, imageViewModel: imageViewModel)
		}
    }
}

#if os(macOS)
import Foundation
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}
}
#endif

extension Notification.Name {
	static let showSavePanel = Notification.Name("showSavePanel")
	static let showOpenPanel = Notification.Name("showOpenPanel")
	static let endEditing = Notification.Name("endEditing")
	static let undo = Notification.Name("undo")
	static let redo = Notification.Name("redo")
	static let changedFilter = Notification.Name("changedFilter")
}
