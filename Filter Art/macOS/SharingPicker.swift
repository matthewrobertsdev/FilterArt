//
//  SharingPicker.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/13/23.
//

#if os(macOS)
import SwiftUI
import AppKit

struct SharingsPicker: NSViewRepresentable {
	@Binding var isPresented: Bool
	var sharingItems: [Any] = []

	func makeNSView(context: Context) -> NSView {
		let view = NSView()
		return view
	}

	func updateNSView(_ nsView: NSView, context: Context) {
		if isPresented {
			let picker = NSSharingServicePicker(items: sharingItems)
			picker.delegate = context.coordinator

			DispatchQueue.main.async {
				picker.show(relativeTo: .zero, of: nsView, preferredEdge: .minY)
			}
		}
	}

	func makeCoordinator() -> Coordinator {
		Coordinator(owner: self)
	}

	class Coordinator: NSObject, NSSharingServicePickerDelegate {
		let owner: SharingsPicker

		init(owner: SharingsPicker) {
			self.owner = owner
		}

		func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, didChoose service: NSSharingService?) {
			sharingServicePicker.delegate = nil
			self.owner.isPresented = false
		}
		
	}
}
#endif
