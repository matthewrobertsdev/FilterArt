//
//  ModalStateViewModel.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/30/23.
//

import SwiftUI

class ModalStateViewModel: ObservableObject {
	@Published var showingUnmodifiedImage = false
	@Published var showingPreviewModal = false
	@Published var showingImagePicker = false
	@Published var showingShareSheet = false
	@Published var showingSharingPicker = false
	@Published var showingImageSaveSuccesAlert = false
	@Published var showingImageSaveFailureAlert = false
	@Published var showingFilters = false
	@Published var showingNameAlert = false
	@Published var showingOpenPanel = false
	@Published var showingSavePanel = false
	
	func isModal() -> Bool {
		return showingUnmodifiedImage || showingPreviewModal ||
		showingImagePicker || showingShareSheet || showingSharingPicker
		|| showingImageSaveSuccesAlert || showingImageSaveFailureAlert
		|| showingFilters || showingNameAlert || showingOpenPanel || showingSavePanel
	}
}
