//
//  FilterStateHistory.swift
//  Filter Art
//
//  Created by Matt Roberts on 3/7/23.
//

import Foundation

class FilterStateHistory: ObservableObject {
	@Published var forUndo = [FilterModel]()
	@Published var forRedo = [FilterModel]()
	@Published var isModifying = false
	
	func undo() -> FilterModel? {
		isModifying = true
		if forUndo.count > 0 {
			let filterState = forUndo.popLast()
			if let filterState = filterState {
				forRedo.append(filterState)
			}
		}
		return forUndo.last
	}
	
	func redo() -> FilterModel? {
		isModifying = true
		let filterState = forRedo.popLast()
		if let filterState = filterState {
			forUndo.append(filterState)
		}
		return filterState
	}
	
	var canUndo: Bool {
		forUndo.count > 1
	}
	
	var canRedo: Bool {
		forRedo.count > 0
	}
}
