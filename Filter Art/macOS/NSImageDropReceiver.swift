//
//  NSImageDropReceiver.swift
//  Filter Art
//
//  Created by Matt Roberts on 4/9/23.
//

#if os(macOS)
import AppKit

class NSImageDropReceiver: NSView {
	var delegate: DestinationViewDelegate?
	
	var acceptableTypes: Set<NSPasteboard.PasteboardType> { return [.png, .tiff, .URL, .fileURL] }
	
	override func hitTest(_ aPoint: NSPoint) -> NSView? {
		return nil
	}
	
	let filteringOptions = [NSPasteboard.ReadingOptionKey.urlReadingContentsConformToTypes:NSImage.imageTypes]
	
	func shouldAllowDrag(_ draggingInfo: NSDraggingInfo) -> Bool {
		
		var canAccept = false
		
		
		let pasteBoard = draggingInfo.draggingPasteboard
		
		
		if pasteBoard.canReadObject(forClasses: [NSURL.self], options: filteringOptions) {
			canAccept = true
		}
		else if let types = pasteBoard.types, acceptableTypes.intersection(types).count > 0 {
			canAccept = true
		}
		return canAccept
		
	}
	
	var isReceivingDrag = false {
		didSet {
			needsDisplay = true
		}
	}
	
	override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
		let allow = shouldAllowDrag(sender)
		isReceivingDrag = allow
		return allow ? .copy : NSDragOperation()
	}
	
	override func draggingExited(_ sender: NSDraggingInfo?) {
		isReceivingDrag = false
	}
	
	override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
		let allow = shouldAllowDrag(sender)
		return allow
	}
	
	override func performDragOperation(_ draggingInfo: NSDraggingInfo) -> Bool {
		
		isReceivingDrag = false
		let pasteBoard = draggingInfo.draggingPasteboard
		
		if let urls = pasteBoard.readObjects(forClasses: [NSURL.self], options:filteringOptions) as? [URL], urls.count > 0 {
			delegate?.processImageURLs(urls)
			return true
		}
		else if let image = NSImage(pasteboard: pasteBoard) {
			delegate?.processImage(image)
			return true
		}
		return false
		
	}
}
#endif
