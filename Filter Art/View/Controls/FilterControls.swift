//
//  FilterControls.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/27/24.
//

import SwiftUI

struct FilterControls: View {
	
	@State private var editMode: ImageEditMode? = nil
	
	@Binding var renderedImage: Image
	
	@EnvironmentObject var imageDataStore: ImageViewModel
	
	var proxy: GeometryProxy
	
	@AppStorage(AppStorageKeys.imageInvertColors.rawValue) private var invertColors: Bool = false
	
    var body: some View {
		Group {
			VStack {
				ScrollView([.horizontal]) {
					HStack(alignment: .top) {
						ForEach(imageEditModesData, id: \.mode.rawValue) { modeData in
							VStack(spacing: 5) {
								Text(modeData.mode.rawValue.capitalized).font(.system(.callout)).fixedSize().if(modeData.mode == editMode) { view in
									view.foregroundColor(Color.accentColor)
								}
								if modeData.mode == .invert {
									Toggle(isOn: $invertColors) {
										Text("")
									}.toggleStyle(.switch).tint(Color.accentColor).onChange(of: invertColors) { newValue in
										if !imageDataStore.isModifying {
											imageDataStore.storeSnapshot()
										}
									}.frame(width: 50)
								} else {
									Image(systemName: modeData.imageName).font(.system(.title)).if(modeData.mode == editMode) { view in
										view.foregroundColor(Color.accentColor)
									}
								}
							}.padding(.horizontal).padding(.vertical, 2.5).contentShape(Rectangle()).if(modeData.mode == editMode) { view in
#if os(macOS)
								view.background(Color.accentColor.opacity(colorScheme == .dark ? 0.10 : 0.20)).cornerRadius(10)
#else
								view.background(Color.accentColor.opacity(0.25)).cornerRadius(10)
#endif
							}.onTapGesture {
								if modeData.mode != .invert {
									
									editMode = modeData.mode
								}
							}.onChange(of: editMode) { newValue in
#if os(macOS)
								NSColorPanel.shared.close()
#endif
							}
						}.padding(.vertical, 5)
					}
#if os(iOS)
					.if(proxy.size.width > 1100) { view in
						view.frame(width: proxy.size.width)
					}
#else
					.frame(width: proxy.size.width)
#endif
				}
			}
			FilterControl(editMode: $editMode).environmentObject(imageDataStore).frame(maxWidth: 600)
			InfoSeperator()
			HStack(spacing: 30) {
				Button {
					imageDataStore.resetAll()
					if !imageDataStore.isModifying {
						imageDataStore.storeSnapshot()
					}
				} label: {
					Text("Reset All")
				}.disabled(imageDataStore.shouldDisableResetAll())
				Button {
					imageDataStore.handleUndo()
				} label: {
					Text("Undo")
				}.disabled(!imageDataStore.canUndo)
				Button {
					imageDataStore.handleRedo()
				} label: {
					Text("Redo")
				}.disabled(!imageDataStore.canRedo)
			}
#if os(macOS)
			.padding(.top)
#endif
		}
    }
	
}

/*
#Preview {
    FilterControls()
}
*/
