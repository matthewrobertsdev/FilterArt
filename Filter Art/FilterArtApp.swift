//
//  Filter_ArtApp.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/13/23.
//

import SwiftUI

@main
struct FilterArtApp: App {
	private let baseUrl = "https://matthewrobertsdev.github.io/celeritasapps/#/"
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
				.frame(minWidth: 700, minHeight: 750)
				.onAppear {
					NSWindow.allowsAutomaticWindowTabbing = false
				}
#endif
        }.commands {
			CommandGroup(replacing: CommandGroupPlacement.newItem) {
#if os(macOS)
				Button {
					NotificationCenter.default.post(name: .showOpenPanel,
																	object: nil, userInfo: nil)
					modalStateViewModel.showingImagePicker = true
				} label: {
					Label("Choose Image", systemImage: "photo")
				}.keyboardShortcut(KeyboardShortcut("1", modifiers: .command)).disabled(modalStateViewModel.isModal())
				Divider()
				Button {
					modalStateViewModel.showingSavePanel = true
					NotificationCenter.default.post(name: .showSavePanel,
																	object: nil, userInfo: nil)
				} label: {
					Label("Export Image", systemImage: "square.and.arrow.down")
				}.keyboardShortcut(KeyboardShortcut("e", modifiers: .command)).disabled(modalStateViewModel.isModal())
#endif
			}
			CommandGroup(before: .sidebar) {
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
			}
			CommandMenu("Photo") {
				Button {
					useOriginalImage = true
				} label: {
					Text("Default Photo")
				}.keyboardShortcut(KeyboardShortcut("d", modifiers: .command))
#if os(macOS)
				Button {
NotificationCenter.default.post(name: .showOpenPanel,
												object: nil, userInfo: nil)
				} label: {
					Label("Choose Photo", systemImage: "photo")
				}.keyboardShortcut(KeyboardShortcut("1", modifiers: .command)).disabled(modalStateViewModel.isModal())
				Divider()
				Button {
NotificationCenter.default.post(name: .showSavePanel,
												object: nil, userInfo: nil)
				} label: {
					Label("Export Image", systemImage: "square.and.arrow.down")
				}.keyboardShortcut(KeyboardShortcut("e", modifiers: .command)).disabled(modalStateViewModel.isModal())
#endif
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
					Label("Filters...", systemImage: "camera.filters")
				}.keyboardShortcut(KeyboardShortcut("5", modifiers: .command)).disabled(modalStateViewModel.isModal())
			}
			CommandGroup(replacing: CommandGroupPlacement.help) {
				if let contactUrl = URL(string: "\(baseUrl)faq/filterart") {
					Link(destination: contactUrl) {
						Text("Frequently Asked Questions")
					}
				}
				if let homepageUrl = URL(string: "\(baseUrl)filterart") {
					Link(destination: homepageUrl) {
						Text("Homepage")
					}
				}
				if let contactUrl = URL(string: "\(baseUrl)contact") {
					Link(destination: contactUrl) {
						Text("Contact the Developer")
					}
				}
				if let contactUrl = URL(string: "\(baseUrl)privacy/filterart") {
					Link(destination: contactUrl) {
						Text("Privacy Policy")
					}
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

extension Notification.Name {
	static let showSavePanel = Notification.Name("showSavePanel")
	static let showOpenPanel = Notification.Name("showOpenPanel")
}
