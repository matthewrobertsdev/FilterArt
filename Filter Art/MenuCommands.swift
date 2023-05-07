//
//  MenuCommands.swift
//  Filter Art
//
//  Created by Matt Roberts on 5/6/23.
//

import SwiftUI

struct MenuCommands: Commands {
	@AppStorage("imageUseOriginalImage") private var useOriginalImage: Bool = true
	@ObservedObject var modalStateViewModel: ModalStateViewModel
	@ObservedObject  var filterStateHistory: FilterStateHistory
	private let baseUrl = "https://matthewrobertsdev.github.io/celeritasapps/#/"
    var body: some Commands {
		CommandGroup(replacing: .undoRedo) {
			Button {
				NotificationCenter.default.post(name: .undo, object: nil)
			} label: {
				Text("Undo")
			}.keyboardShortcut(KeyboardShortcut("Z", modifiers: .command)).disabled(!filterStateHistory.canUndo ||  modalStateViewModel.isModal())
			Button {
				NotificationCenter.default.post(name: .redo, object: nil)
			} label: {
				Text("Redo")
			}.keyboardShortcut(KeyboardShortcut("Z", modifiers: [.command, .shift])).disabled(!filterStateHistory.canRedo ||  modalStateViewModel.isModal())
		}
		CommandGroup(replacing: CommandGroupPlacement.newItem) {
#if os(macOS)
			Button {
				NotificationCenter.default.post(name: .showOpenPanel,
																object: nil, userInfo: nil)
				modalStateViewModel.showingOpenPanel = true
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
				modalStateViewModel.showingUnmodifiedImage = true
			} label: {
				Text("Unmodified Image")
			}.keyboardShortcut(KeyboardShortcut("2", modifiers: .command)).disabled(modalStateViewModel.isModal())
			Divider()
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
			}.keyboardShortcut(KeyboardShortcut("3", modifiers: .command)).disabled(modalStateViewModel.isModal())
			Divider()
			Button {
				modalStateViewModel.showingFilters = true
			} label: {
				Label("Filters…", systemImage: "camera.filters")
			}.keyboardShortcut(KeyboardShortcut("4", modifiers: .command)).disabled(modalStateViewModel.isModal())
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
