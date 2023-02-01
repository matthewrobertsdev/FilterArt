//
//  Filter_ArtApp.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/13/23.
//

import SwiftUI

@main
struct FilterArtApp: App {
	@StateObject private var modalStateViewModel = ModalStateViewModel()
	@AppStorage("imageUseOriginalImage") private var useOriginalImage: Bool = true
	#if os(macOS)
	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	#endif
	let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
				.environment(\.managedObjectContext, persistenceController.container.viewContext).environmentObject(modalStateViewModel)
#if os(macOS)
				.frame(minWidth: 600, minHeight: 725)
				.onAppear {
					NSWindow.allowsAutomaticWindowTabbing = false
				}
#endif
        }.commands {
			CommandGroup(replacing: CommandGroupPlacement.newItem) {
				Button {
					modalStateViewModel.showingImagePicker = true
				} label: {
					Label("Choose Image", systemImage: "photo")
				}.keyboardShortcut(KeyboardShortcut("1", modifiers: .command)).disabled(modalStateViewModel.isModal())
				Divider()
				Button {
					modalStateViewModel.showingSavePanel = true
				} label: {
					Label("Export Image", systemImage: "square.and.arrow.down")
				}.keyboardShortcut(KeyboardShortcut("e", modifiers: .command)).disabled(modalStateViewModel.isModal())
			}
			CommandMenu("Image") {
				Button {
					modalStateViewModel.showingPreviewModal = true
				} label: {
					Text("Modified Image")
				}.keyboardShortcut(KeyboardShortcut("2", modifiers: .command)).disabled(modalStateViewModel.isModal())
				Button {
					modalStateViewModel.showingUnmodifiedImage = true
				} label: {
					Text("Unmodified Image")
				}.keyboardShortcut(KeyboardShortcut("3", modifiers: .command)).disabled(modalStateViewModel.isModal())
				Divider()
				Button {
					useOriginalImage = true
				} label: {
					Text("Default Image")
				}.keyboardShortcut(KeyboardShortcut("d", modifiers: .command))
				Button {
					modalStateViewModel.showingOpenPanel = true
				} label: {
					Label("Choose Image", systemImage: "photo")
				}.disabled(modalStateViewModel.isModal())
				Divider()
				Button {
					modalStateViewModel.showingSavePanel = true
				} label: {
					Label("Export Image", systemImage: "square.and.arrow.down")
				}.keyboardShortcut(KeyboardShortcut("e", modifiers: .command)).disabled(modalStateViewModel.isModal())
				
			}
			CommandMenu("Filters") {
				Button {
					modalStateViewModel.showingNameAlert = true
				} label: {
					Label("Add Saved Filter", systemImage: "plus")
				}.keyboardShortcut(KeyboardShortcut("4", modifiers: .command)).disabled(modalStateViewModel.isModal())
				Divider()
				Button {
					modalStateViewModel.showingFilters = true
				} label: {
					Label("Apply Filter...", systemImage: "camera.filters")
				}.keyboardShortcut(KeyboardShortcut("5", modifiers: .command)).disabled(modalStateViewModel.isModal())
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
