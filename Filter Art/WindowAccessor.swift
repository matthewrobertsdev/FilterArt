//
//  WindowAccessor.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/16/23.
//
import SwiftUI
import AppKit

struct WindowAccessor: NSViewRepresentable {
	@Binding var window: NSWindow?

	func makeNSView(context: Context) -> NSView {
		let view = NSView()
		DispatchQueue.main.async {
			self.window = view.window
		}
		return view
	}

	func updateNSView(_ nsView: NSView, context: Context) {}
}
