//
//  ImageView.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/11/23.
//
import SwiftUI
#if os(iOS)
import UIKit
#else
import AppKit
#endif

struct ImageView: View {
	@Environment(\.displayScale) var displayScale
	@StateObject private var imageDataStore = ImageDataStore()
	@AppStorage("imagWidth") private var width: Double = 300
	@AppStorage("imageHeight") private var height: Double = 160
	@AppStorage("imageInvertColors") private var invertColors: Bool = false
	@AppStorage("imageHueRotation") private var hueRotation: Double = 0
	@AppStorage("imageUseHueRotation") private var useHueRotation: Bool = false
	@AppStorage("imageContrast") private var contrast: Double = 1
	@AppStorage("imageUseContrast") private var useContrast: Bool = false
	@AppStorage("imageUseColorMultiply") private var useColorMultiply: Bool = false
	@AppStorage("imageColorMultiplyColor") private var colorMultiplyColor: Color = Color.blue
	@AppStorage("imageUseSaturation") private var useSaturation: Bool = false
	@AppStorage("imageSaturation") private var saturation: Double = 1
	@AppStorage("imageUseGrayscale") private var useGrayscale: Bool = false
	@AppStorage("imageGrayscale") private var grayscale: Double = 0
	@AppStorage("imageUseOpacity") private var useOpacity: Bool = false
	@AppStorage("imageOpacity") private var opacity: Double = 1
	@State private var image: Data = Data()
	@AppStorage("imageUseOrinalImage") private var useOriginalImage: Bool = true
	@State var showingSheet = false
	@State var sheetType = SheetType.modifiedImage
	@State var loading = false
#if os(macOS)
	let maxWidth = 300.0
	let maxHeight = 140.0
#else
	let maxWidth = 300.0
	var maxHeight = 250.0
#endif
	let minHeight = 50
	let minWidth = 50
	init() {
#if os(iOS)
		if UIDevice.current.userInterfaceIdiom == .pad {
			maxHeight = 280.0
		}
#endif
	}
	var body: some View {
			Group {
#if os(macOS)
				VStack(spacing: 10) {
					getDisplay().frame(height: 350)
					InfoSeperator()
					ScrollView {
						getEditor().padding(.bottom).frame(maxWidth: 600)
					}
				}.sheet(isPresented: $showingSheet) {
					if sheetType == .unmodifiedImage {
					VStack(alignment: .leading, spacing: 0) {
						HStack {
							Text("Unmodified Image:").font(.title).bold()
							Spacer()
						}.padding(.bottom, 10)
						HStack {
							Spacer()
							getImage().resizable().aspectRatio(contentMode: .fit).frame(height: 525)
							Spacer()
						}.frame(minHeight: 525, maxHeight: 525).overlay(Rectangle().stroke(Color("Border", bundle: nil), lineWidth: 2))
						HStack {
							Spacer()
							Button {
								showingSheet = false
							} label: {
								Text("Done")
							}.keyboardShortcut(.defaultAction)
						}.padding(.top, 20)
					}.frame(width: 650, height: 600, alignment: .topLeading).padding()
					} else if sheetType == .modifiedImage {
						VStack(alignment: .leading, spacing: 0) {
							HStack {
								Text("Larger Modified Image:").font(.title).bold()
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
									showingSheet = false
								} label: {
									Text("Done")
								}.keyboardShortcut(.defaultAction)
							}.padding(.top, 20)
						}.frame(width: 650, height: 615, alignment: .topLeading).padding()
					}
				}.onAppear() {
					if !useOriginalImage {
						ImageDataStore.load { result in
							switch result {
							case .failure(let error):
								print("failed: \(error)")
							case .success(let imageData):
								imageDataStore.imageData = imageData
							}
						}
					}
				}.onChange(of: imageDataStore.imageData) { imageData in
					ImageDataStore.save(imageData: imageDataStore.imageData) { result in
						
					}
				}
#else
				VStack(spacing: 0) {
					VStack(spacing: 10) {
						getDisplay().frame(height: 250)
						InfoSeperator()
					}
					ScrollView {
						getEditor().padding(.bottom).frame(maxWidth: 600)
					}
				}.sheet(isPresented: $showingSheet) {
					if sheetType == .shareSheet {
						ShareSheet(image: getFilteredImage())
					} else if sheetType == .modifiedImage {
						NavigationView {
							HStack {
								Spacer()
								getModalDisplay()
								Spacer()
							}.toolbar {
								ToolbarItem {
									// MARK: Done
									Button {
										//handle done
										showingSheet = false
									} label: {
										Text("Done")
									}.keyboardShortcut(.defaultAction)
								}
							}.navigationTitle("Larger Modified Image").navigationBarTitleDisplayMode(.inline)
						}
					} else if sheetType == .unmodifiedImage {
						NavigationView {
							HStack {
								Spacer()
								getImage().resizable().aspectRatio(contentMode: .fit)
								Spacer()
							}.toolbar {
								ToolbarItem {
									// MARK: Done
									Button {
										//handle done
										showingSheet = false
									} label: {
										Text("Done")
									}.keyboardShortcut(.defaultAction)
								}
							}.navigationTitle("Unmodified Image").navigationBarTitleDisplayMode(.inline)
						}
					} else {
						ImagePicker(imageData: $imageDataStore.imageData, useOriginalImage: $useOriginalImage, loading: $loading)
					}
				}.onAppear() {
					if !useOriginalImage {
						ImageDataStore.load { result in
							switch result {
							case .failure:
								print("failed")
							case .success(let imageData):
								imageDataStore.imageData = imageData
							}
						}
					}
				}.onChange(of: imageDataStore.imageData) { imageData in
					DispatchQueue.main.async {
						ImageDataStore.save(imageData: imageDataStore.imageData) { result in
							
						}
					}
					
				}
#endif
		}
#if os(iOS)
		.navigationBarTitleDisplayMode(.inline)
#endif
	}
	
	func getEditor() -> some View {
		Group {
			VStack(spacing: 10) {
				HStack(spacing: 20) {
					Button("Larger Image") {
						sheetType = .modifiedImage
						showingSheet = true
					}
					Button("Unmodfied Image") {
						sheetType = .unmodifiedImage
						showingSheet = true
					}
				}
				HStack(spacing: 20) {
					Button("Choose Image") {
						#if os(macOS)
						let openPanel = NSOpenPanel()
									openPanel.prompt = "Choose Image"
									openPanel.allowsMultipleSelection = false
										openPanel.canChooseDirectories = false
										openPanel.canCreateDirectories = false
										openPanel.canChooseFiles = true
									openPanel.allowedContentTypes = [.image]
										openPanel.begin { (result) -> Void in
											if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
												if let url = openPanel.url {
													do {
														imageDataStore.imageData = try Data(contentsOf: url)
														useOriginalImage = false
													} catch {
														print ("Error getting data from image file url.")
													}
												}

											}
										}
						#else
						sheetType = .imagePicker
						showingSheet = true
						#endif
					}
					Button("Default Image") {
						useOriginalImage = true
						imageDataStore.imageData = Data()
					}
				}
				#if os(iOS)
				HStack(spacing: 20){
					Button {
						UIImageWriteToSavedPhotosAlbum(getFilteredImage(), nil, nil, nil)
					} label: {
						Text("Save Image")
					}
					Button {
						sheetType = .shareSheet
						showingSheet = true
					} label: {
						Text("Share Image")
					}
				}
				#else
				getSavePanelButton()
				#endif
			}
			getFilterControls()
		}.padding()
	}
	
	func getDisplay() -> some View {
		Group {
			if loading {
				ProgressView().controlSize(.large)
			} else {
				getImage().resizable().aspectRatio(contentMode: .fit).if(invertColors, transform: { view in
				   view.colorInvert()
						}).if(useHueRotation, transform: { view in
							view.hueRotation(.degrees(hueRotation))
						}).if(useContrast, transform: { view in
							view.contrast(contrast)
						}).if(useColorMultiply, transform: { view in
							view.colorMultiply(colorMultiplyColor)
						}).if(useSaturation, transform: { view in
							view.saturation(saturation)
						   }).if(useGrayscale, transform: { view in
							view.grayscale(grayscale)
						   }).if(useOpacity, transform: { view in
							   view.opacity(opacity)
						})
			}
		}
	}
	
	func getModalDisplay() -> some View {
#if os(iOS)
		GeometryReader { geometry in
			VStack {
				Spacer()
				
				HStack {
					Spacer()
					getImage().resizable().aspectRatio(contentMode: .fit).if(invertColors, transform: { view in
						view.colorInvert()
					}).if(useHueRotation, transform: { view in
							view.hueRotation(.degrees(hueRotation))
						}).if(useContrast, transform: { view in
							view.contrast(contrast)
						})
							.if(useColorMultiply, transform: { view in
								view.colorMultiply(colorMultiplyColor)
							}).if(useSaturation, transform: { view in
								view.saturation(saturation)
						 }).if(useGrayscale, transform: { view in
								view.grayscale(grayscale)
							}).if(useOpacity, transform: { view in
								view.opacity(opacity)
					  })
							Spacer()
				}
				Spacer()
			}
		}
#else
		VStack(alignment: .center) {
			HStack(alignment: .center) {
				getImage().resizable().aspectRatio(contentMode: .fit).frame(height: 525).clipped().if(invertColors, transform: { view in
						view.colorInvert()
					}).if(useHueRotation, transform: { view in
						view.hueRotation(.degrees(hueRotation))
					}).if(useContrast, transform: { view in
						view.contrast(contrast)
					}).if(useColorMultiply, transform: { view in
						view.colorMultiply(colorMultiplyColor)
					}).if(useSaturation, transform: { view in
						view.saturation(saturation)
					   }).if(useGrayscale, transform: { view in
						view.grayscale(grayscale)
					   }).if(useOpacity, transform: { view in
						view.opacity(opacity)
					})
			}
		}
#endif
	}
	
	func getImage() -> Image {
		if useOriginalImage {
			return Image("FallColors")
		} else {
#if os(macOS)
			return Image(nsImage: (NSImage(data: imageDataStore.imageData) ?? NSImage()))
#else
			return Image(uiImage: (UIImage(data: imageDataStore.imageData)  ?? UIImage()))
#endif
		}
	}
	
	func getFilterControls() -> some View {
		Group {
			Group {
				Group {
					Toggle("Use Hue Rotation", isOn: $useHueRotation.animation()).toggleStyle(.switch).tint(Color.accentColor)
					if useHueRotation {
						HueRotationControl(hueRotation: $hueRotation)
					}
				}
				Group {
					Toggle("Use Contrast", isOn: $useContrast.animation()).toggleStyle(.switch).tint(Color.accentColor)
					if useContrast {
						ContrastControl(contrast: $contrast)
					}
				}
				Toggle("Invert Colors", isOn: $invertColors.animation()).toggleStyle(.switch).tint(Color.accentColor)
			}
			Group {
				Group {
					Toggle("Use Color Multiply", isOn: $useColorMultiply.animation()).toggleStyle(.switch).tint(Color.accentColor)
					if useColorMultiply {
						ColorMultiplyControl(colorMultiplyColor: $colorMultiplyColor)
					}
				}
				Group {
					Toggle("Use Saturation", isOn: $useSaturation.animation()).toggleStyle(.switch).tint(Color.accentColor)
					if useSaturation {
						SaturationControl(saturation: $saturation)
					}
				}
				Group {
					Toggle("Use Grayscale", isOn: $useGrayscale.animation()).toggleStyle(.switch).tint(Color.accentColor)
					if useGrayscale {
						GrayscaleControl(grayscale: $grayscale)
					}
				}
				Group {
					Toggle("Use Opacity", isOn: $useOpacity.animation()).toggleStyle(.switch).tint(Color.accentColor)
					if useOpacity {
						OpacityControl(opacity: $opacity)
					}
				}
			}
		}
	}
	
	#if os(macOS)
	func getSavePanelButton() -> some View {
		Button("Save Image") {
			let savePanel = NSSavePanel()
			savePanel.title = "Save Image"
			savePanel.prompt = "Save Image"
			savePanel.canCreateDirectories = false
			savePanel.allowedContentTypes = [.image]
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "d-M-y h.mm a"
			let dateString = dateFormatter.string(from: Date())
			savePanel.nameFieldStringValue = "Image \(dateString).png"
			savePanel.begin { (result) -> Void in
				if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
					if let url = savePanel.url {
						let imageRepresentation = NSBitmapImageRep(data: getFilteredImage().tiffRepresentation ?? Data())
						let pngData = imageRepresentation?.representation(using: .png, properties: [:]) ?? Data()
						do {
							try pngData.write(to: url)
						} catch {
							print(error)
						}
					}
					
				}
			}
		}
	}
	#endif
	
	#if os(iOS)
	@MainActor func getFilteredImage() -> UIImage {
		let renderer = ImageRenderer(content: getImage().resizable().aspectRatio(contentMode: .fit).if(invertColors, transform: { view in
			view.colorInvert()
			  }).if(useHueRotation, transform: { view in
				  view.hueRotation(.degrees(hueRotation))
			  }).if(useContrast, transform: { view in
				  view.contrast(contrast)
			  }).if(useColorMultiply, transform: { view in
				  view.colorMultiply(colorMultiplyColor)
			  }).if(useSaturation, transform: { view in
				  view.saturation(saturation)
				 }).if(useGrayscale, transform: { view in
				  view.grayscale(grayscale)
				 }).if(useOpacity, transform: { view in
					 view.opacity(opacity)
					}))

			renderer.scale = displayScale
			if let uiImage = renderer.uiImage {
				return  uiImage
			}
		return UIImage(named: "FallColors") ?? UIImage()
		}
	#else
	@MainActor func getFilteredImage() -> NSImage{
		let renderer = ImageRenderer(content: getImage().resizable().aspectRatio(contentMode: .fit).if(invertColors, transform: { view in
			view.colorInvert()
			  }).if(useHueRotation, transform: { view in
				  view.hueRotation(.degrees(hueRotation))
			  }).if(useContrast, transform: { view in
				  view.contrast(contrast)
			  }).if(useColorMultiply, transform: { view in
				  view.colorMultiply(colorMultiplyColor)
			  }).if(useSaturation, transform: { view in
				  view.saturation(saturation)
				 }).if(useGrayscale, transform: { view in
				  view.grayscale(grayscale)
				 }).if(useOpacity, transform: { view in
					 view.opacity(opacity)
					}))

			renderer.scale = displayScale
		if let nsImage = renderer.nsImage {
			return  nsImage
		}
		return NSImage(named: "FallColors") ?? NSImage()
		}
	#endif
}

struct ImageView_Previews: PreviewProvider {
	static var previews: some View {
		ImageView()
	}
}

enum ImageModal {
	case unmodified
	case preview
}

enum SheetType {
	case shareSheet
	case imagePicker
	case unmodifiedImage
	case modifiedImage
}
