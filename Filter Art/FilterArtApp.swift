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
	let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
				.environment(\.managedObjectContext, persistenceController.container.viewContext)
#if os(macOS)
				.frame(minWidth: 600, minHeight: 725)
				.onAppear {
					NSWindow.allowsAutomaticWindowTabbing = false
				}
#endif
        }.commands {
			CommandGroup(replacing: CommandGroupPlacement.newItem) {
				Button {
					//showingNameAlert = true
				} label: {
					Label("Choose Image", systemImage: "photo")
				}
				Divider()
				Button {
					//showingNameAlert = true
				} label: {
					Label("Export Image", systemImage: "square.and.arrow.down")
				}.keyboardShortcut(KeyboardShortcut("e", modifiers: .command))
			}
			CommandMenu("Image") {
				Button {
					//showingNameAlert = true
				} label: {
					Text("Modified Image")
				}
				Button {
					//showingNameAlert = true
				} label: {
					Text("Unmodified Image")
				}
				Divider()
				Button {
					//showingNameAlert = true
				} label: {
					Text("Default Image")
				}
				Button {
					//showingNameAlert = true
				} label: {
					Label("Choose Image", systemImage: "photo")
				}
				Divider()
				Button {
					//showingNameAlert = true
				} label: {
					Label("Export Image", systemImage: "square.and.arrow.down")
				}.keyboardShortcut(KeyboardShortcut("e", modifiers: .command))
				
			}
			CommandMenu("Filters") {
				Button {
					//showingNameAlert = true
				} label: {
					Label("Add Saved Filter", systemImage: "plus")
				}
				Divider()
				Button {
					//showingFilters = true
				} label: {
					Label("Apply Filter...", systemImage: "camera.filters")
				}
			}
			CommandGroup(replacing: CommandGroupPlacement.help) {
				Button {
					//showingNameAlert = true
				} label: {
					Text("Frequently Asked Questions")
				}
				Button {
					//showingNameAlert = true
				} label: {
					Text("Homepage")
				}
				Button {
					//showingNameAlert = true
				} label: {
					Text("Contact the Developer")
				}
				Button {
					//showingNameAlert = true
				} label: {
					Text("Privacy Policy")
				}
			}
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
