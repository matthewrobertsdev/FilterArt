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
import Photos
import PhotosUI


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
	@AppStorage("imageUseBlur") private var useBlur: Bool = false
	@AppStorage("imageBlur") private var blur: Double = 0
	@State private var image: Data = Data()
	@AppStorage("imageUseOriginalImage") private var useOriginalImage: Bool = true
	@State var showingUnmodifiedImage = false
	@State var showingPreviewModal = false
	@State var showingImagePicker = false
	@State var showingShareSheet = false
	@State var showingSharingPicker = false
	@State var showingImageSaveSuccesAlert = false
	@State var showingImageSaveFailureAlert = false
	@State var loading = false
	@State private var selectedItem: PhotosPickerItem? = nil
	@State var showingFilters = false
#if os(macOS)
	@State private var window: NSWindow?
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
			maxHeight = 500
		}
#endif
	}
	var body: some View {
			Group {
#if os(macOS)
				VStack(spacing: 10) {
					getDisplay()
					InfoSeperator()
					ScrollView {
						getEditor().frame(maxWidth: .infinity)
					}.frame(height: 400)
				}.sheet(isPresented: $showingUnmodifiedImage) {
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
								showingUnmodifiedImage = false
							} label: {
								Text("Done")
							}.keyboardShortcut(.defaultAction)
						}.padding(.top, 20)
					}.frame(width: 650, height: 600, alignment: .topLeading).padding()
				}.sheet(isPresented: $showingPreviewModal) {
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
									showingPreviewModal = false
								} label: {
									Text("Done")
								}.keyboardShortcut(.defaultAction)
							}.padding(.top, 20)
						}.frame(width: 650, height: 615, alignment: .topLeading).padding()
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
				}.sheet(isPresented: $showingFilters) {
					FiltersView(showing: $showingFilters).environmentObject(imageDataStore)
				   }.onChange(of: imageDataStore.imageData) { imageData in
					ImageDataStore.save(imageData: imageDataStore.imageData) { result in
						
					}
				}
#else
				VStack(spacing: 0) {
					VStack(spacing: 10) {
						getDisplay().frame(height: maxHeight)
						InfoSeperator()
					}
					ScrollView {
						getEditor().padding(.bottom).frame(maxWidth: .infinity)
					}
				}.sheet(isPresented: $showingShareSheet) {
						ShareSheet(image: getFilteredImage())
				}.sheet(isPresented: $showingPreviewModal) {
						NavigationStack {
							HStack {
								Spacer()
								getModalDisplay()
								Spacer()
							}.toolbar {
								ToolbarItem {
									// MARK: Done
									Button {
										//handle done
										showingPreviewModal = false
									} label: {
										Text("Done")
									}.keyboardShortcut(.defaultAction)
								}
							}.navigationTitle("Modified Image").navigationBarTitleDisplayMode(.inline)
						}
					}.sheet(isPresented: $showingUnmodifiedImage) {
						NavigationStack {
							HStack {
								Spacer()
								getImage().resizable().aspectRatio(contentMode: .fit)
								Spacer()
							}.toolbar {
								ToolbarItem {
									// MARK: Done
									Button {
										//handle done
										showingUnmodifiedImage = false
									} label: {
										Text("Done")
									}.keyboardShortcut(.defaultAction)
								}
							}.navigationTitle("Unmodified Image").navigationBarTitleDisplayMode(.inline)
						}
					}.sheet(isPresented: $showingFilters) {
						FiltersView(showing: $showingFilters).environmentObject(imageDataStore)
					}.sheet(isPresented: $showingImagePicker) {
						ImagePicker(imageData: $imageDataStore.imageData, useOriginalImage: $useOriginalImage, loading: $loading)
					}.alert("Success!", isPresented: $showingImageSaveSuccesAlert, actions: {
						// actions
					}, message: {
							Text("Image saved to photo library.")
					}).alert("Whoops!", isPresented: $showingImageSaveFailureAlert, actions: {
						// actions
					}, message: {
							Text("Could not save image.  Have you granted permisson in the Settings app under Privacy > Photos > Filter Art?")
					}).onAppear() {
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
#else
		.background(WindowAccessor(window: $window))
#endif
	}
	
	func getEditor() -> some View {
		Group {
			VStack(spacing: 10) {
				HStack(spacing: 20) {
					Button("Modified Image") {
						showingPreviewModal = true
					}
					Button("Unmodfied Image") {
						showingUnmodifiedImage = true
					}
				}
				HStack(spacing: 20) {
					//#if os(iOS)
					PhotosPicker(
								selection: $selectedItem,
								matching: .images,
								photoLibrary: .shared()) {
									Text("Choose Image")
								}
								.onChange(of: selectedItem) { newItem in
									loading = true
									Task {
										if let data = try? await newItem?.loadTransferable(type: Data.self) {
											imageDataStore.imageData = data
											useOriginalImage = false
											loading = false
										} else {
											loading = false
										}
									}
								}
					//#else
					/*
					Button("Choose Image") {
						//#if os(macOS)
						let openPanel = NSOpenPanel()
									openPanel.prompt = "Choose Image"
									openPanel.allowsMultipleSelection = false
										openPanel.canChooseDirectories = false
										openPanel.canCreateDirectories = false
										openPanel.canChooseFiles = true
									openPanel.allowedContentTypes = [.image]
						if let window = window {
							openPanel.beginSheetModal(for: window) { result in
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
						}
						//#else
						//showingImagePicker = true
					 
					}
					 */
//#endif

					Button("Default Image") {
						useOriginalImage = true
						imageDataStore.imageData = Data()
					}
				}
				#if os(iOS)
				/*
				HStack(spacing: 20){
					Button {
						let imageSaver = ImageSaver(showingSuccessAlert: $showingImageSaveSuccesAlert, showingErrorAlert: $showingImageSaveFailureAlert)
						imageSaver.writeToPhotoAlbum(image: getFilteredImage())
					} label: {
						Text("Save Image")
					}
					Button {
						showingShareSheet = true
					} label: {
						Text("Share Image")
					}
				}
				 */
				Button {
					let imageSaver = ImageSaver(showingSuccessAlert: $showingImageSaveSuccesAlert, showingErrorAlert: $showingImageSaveFailureAlert)
					imageSaver.writeToPhotoAlbum(image: getFilteredImage())
				} label: {
					Text("Save Image")
				}
				#else
				HStack(spacing: 20){
					getSavePanelButton()
				}
				#endif
				HStack {
					Button {
						showingFilters = true
					} label: {
						Text("Filters...")
					}

				}
			}
			getFilterControls()
		}.padding().frame(maxWidth: 600)
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
						   }).if(useBlur) { view in
					view.blur(radius: blur)
				}
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
					  }).if(useBlur) { view in
						view.blur(radius: blur)
				 }
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
					}).if(useBlur) { view in
					view.blur(radius: blur)
				}
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
			getColorControls()
			getStyleControls()
		}
	}
	
	func getColorControls() -> some View {
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
			}
		}
	}

	func getStyleControls() -> some View {
		Group {
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
				Group {
					Toggle("Use Blur", isOn: $useBlur.animation()).toggleStyle(.switch).tint(Color.accentColor)
					if useBlur {
						BlurControl(blur: $blur)
					}
				}
		}
	}
	
	
	#if os(macOS)
	func getSavePanelButton() -> some View {
		Button("Export Image") {
			let savePanel = NSSavePanel()
			savePanel.title = "Export Image"
			savePanel.prompt = "Export Image"
			savePanel.canCreateDirectories = false
			savePanel.allowedContentTypes = [.image]
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "M-d-y h.mm a"
			let dateString = dateFormatter.string(from: Date())
			savePanel.nameFieldStringValue = "Image \(dateString).png"
			if let window = window {
				savePanel.beginSheetModal(for: window) { result in
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
					}).if(useBlur) { view in
						view.blur(radius: blur)
				 })

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
					}).if(useBlur) { view in
						view.blur(radius: blur)
				 })

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
