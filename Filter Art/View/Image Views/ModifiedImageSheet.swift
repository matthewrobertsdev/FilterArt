//
//  ModifiedImageSheet.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/27/24.
//

import SwiftUI

struct ModifiedImageSheet: View {
	@Binding var renderedImage: Image
	@EnvironmentObject var modalStateViewModel: ModalStateViewModel
    var body: some View {
		#if os(macOS)
		VStack(alignment: .leading, spacing: 0) {
			HStack {
				Text("Modified Image:").font(.title).bold()
				Spacer()
			}.padding(.bottom, 10)
			HStack {
				Spacer()
				getModalDisplay()
				Spacer()
			}.overlay(Rectangle().stroke(Color("Border", bundle: nil), lineWidth: 2))
			HStack {
				Spacer()
				Button {
					modalStateViewModel.showingPreviewModal = false
				} label: {
					Text("Done")
				}.keyboardShortcut(.defaultAction)
			}.padding(.top, 20)
		}.frame(width: 650, height: 600, alignment: .topLeading).padding()
		#else
		NavigationStack {
			HStack {
				Spacer()
				getModalDisplay()
				Spacer()
			}.toolbar {
				ToolbarItem {
					Button {
						modalStateViewModel.showingPreviewModal = false
					} label: {
						Text("Done")
					}.keyboardShortcut(.defaultAction)
				}
			}.navigationTitle("Modified Image").navigationBarTitleDisplayMode(.inline)
		}
		#endif
    }
	
	func getModalDisplay() -> some View {
#if os(iOS)
		GeometryReader { geometry in
			VStack {
				Spacer()
				
				HStack {
					Spacer()
					renderedImage.resizable().aspectRatio(contentMode: .fit)
					Spacer()
				}
				Spacer()
			}
		}
#else
		VStack(alignment: .center) {
			HStack(alignment: .center) {
				renderedImage.resizable().aspectRatio(contentMode: .fit).frame(height: 525).clipped()
			}
		}
#endif
	}
}

/*
#Preview {
    ModifiedImageSheet()
}
*/
