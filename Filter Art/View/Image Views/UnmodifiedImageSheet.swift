//
//  UnmodifiedImageSheet.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/27/24.
//

import SwiftUI

struct UnmodifiedImageSheet: View {
	
	@AppStorage(AppStorageKeys.imageUseOriginalImage.rawValue) private var useOriginalImage: Bool = true
	
	@EnvironmentObject var modalStateViewModel: ModalStateViewModel
	@EnvironmentObject private var imageViewModel: ImageViewModel
	
    var body: some View {
		#if os(macOS)
		VStack(alignment: .leading, spacing: 0) {
			HStack {
				Text("Unmodified Image:").font(.title).bold()
				Spacer()
			}.padding(.bottom, 10)
			HStack {
				Spacer()
				imageViewModel.getImage().resizable().aspectRatio(contentMode: .fit).frame(height: 525)
				Spacer()
			}.frame(minHeight: 525, maxHeight: 525).overlay(Rectangle().stroke(Color("Border", bundle: nil), lineWidth: 2))
			HStack {
				Spacer()
				Button {
					modalStateViewModel.showingUnmodifiedImage = false
				} label: {
					Text("Done")
				}.keyboardShortcut(.defaultAction)
			}.padding(.top, 20)
		}.frame(width: 650, height: 600, alignment: .topLeading).padding()
		#else
		NavigationStack {
			HStack {
				Spacer()
				imageViewModel.getImage().resizable().aspectRatio(contentMode: .fit)
				Spacer()
			}.toolbar {
				ToolbarItem {
					// MARK: Done
					Button {
						//handle done
						modalStateViewModel.showingUnmodifiedImage = false
					} label: {
						Text("Done")
					}.keyboardShortcut(.defaultAction)
				}
			}.navigationTitle("Unmodified Image").navigationBarTitleDisplayMode(.inline)
		}
		#endif
    }

}

/*
#Preview {
    UnmodifiedImageSheet()
}
*/
