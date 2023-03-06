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
	@Environment(\.managedObjectContext) var managedObjectContext
	@Environment(\.displayScale) var displayScale
	@EnvironmentObject var modalStateViewModel: ModalStateViewModel
	@StateObject private var imageDataStore = ImageDataStore()
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
	@State private var invertColorsSnaphhot: Bool = false
	@State private var hueRotationSnaphhot: Double = 0
	@State private var useHueRotationSnapshot: Bool = false
	@State private var contrastSnapshot: Double = 1
	@State private var useContrastSnapshot: Bool = false
	@State private var useColorMultiplySnapshot: Bool = false
	@State private var colorMultiplyColorSnapshot: Color = Color.blue
	@State private var useSaturationSnapshot: Bool = false
	@State private var saturationSnapshot: Double = 1
	@State private var useGrayscaleSnapshot: Bool = false
	@State private var grayscaleSnapshot: Double = 0
	@State private var useOpacitySnapshot: Bool = false
	@State private var opacitySnapshot: Double = 1
	@State private var useBlurSnapshot: Bool = false
	@State private var blurSnapshot: Double = 0
	@State private var image: Data = Data()
	@AppStorage("imageUseOriginalImage") private var useOriginalImage: Bool = true
	@State var showingImageSaveFailureAlert = false
	@State var loading = false
	@State var waitingForDrop = false
	@State private var selectedItem: PhotosPickerItem? = nil
	@State private var editMode: ImageEditMode? = nil
	@State private var showingPhotoPicker: Bool = false
	#if os(macOS)
	@State private var window: NSWindow?
	#endif
	init() {
	}
	var body: some View {
			Group {
#if os(macOS)
				VStack(spacing: 10) {
					getDisplay()
					InfoSeperator()
					GeometryReader { proxy in
						getEditor(proxy: proxy).frame(maxWidth: .infinity)
					}.frame(height: 225)
				}.sheet(isPresented: $modalStateViewModel.showingUnmodifiedImage) {
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
								modalStateViewModel.showingUnmodifiedImage = false
							} label: {
								Text("Done")
							}.keyboardShortcut(.defaultAction)
						}.padding(.top, 20)
					}.frame(width: 650, height: 600, alignment: .topLeading).padding()
				}.sheet(isPresented: $modalStateViewModel.showingPreviewModal) {
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
					}.sheet(isPresented: $modalStateViewModel.showingFilters) {
						FiltersView(showing: $modalStateViewModel.showingFilters).environmentObject(imageDataStore)
				   }.onChange(of: imageDataStore.imageData) { imageData in
					ImageDataStore.save(imageData: imageDataStore.imageData) { result in
						
					}
				   }.alert("Name Your Filter", isPresented: $modalStateViewModel.showingNameAlert, actions: {
					   NameAlert().environment(\.managedObjectContext, managedObjectContext)
		  }, message: {
			  Text("Enter a name for your new filter:")
		  })
#else
				VStack(spacing: 5) {
					VStack(spacing: 10) {
						getDisplay()
						InfoSeperator()
					}
					GeometryReader { proxy in
						ScrollView {
							getEditor(proxy: proxy).frame(maxWidth: .infinity)
						}
					}.frame(height: 235)
				}
				.sheet(isPresented: $modalStateViewModel.showingShareSheet) {
					ShareSheet(imageData: getFilteredImage(forSharing: true))
				}.sheet(isPresented: $modalStateViewModel.showingPreviewModal) {
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
										modalStateViewModel.showingPreviewModal = false
									} label: {
										Text("Done")
									}.keyboardShortcut(.defaultAction)
								}
							}.navigationTitle("Modified Image").navigationBarTitleDisplayMode(.inline)
						}
					}.sheet(isPresented: $modalStateViewModel.showingUnmodifiedImage) {
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
										modalStateViewModel.showingUnmodifiedImage = false
									} label: {
										Text("Done")
									}.keyboardShortcut(.defaultAction)
								}
							}.navigationTitle("Unmodified Image").navigationBarTitleDisplayMode(.inline)
						}
					}.sheet(isPresented: $modalStateViewModel.showingFilters) {
						FiltersView(showing: $modalStateViewModel.showingFilters).environmentObject(imageDataStore)
					}.sheet(isPresented: $modalStateViewModel.showingImagePicker) {
						ImagePicker(imageData: $imageDataStore.imageData, useOriginalImage: $useOriginalImage, loading: $loading)
					}.alert("Success!", isPresented: $modalStateViewModel.showingImageSaveSuccesAlert, actions: {
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
					
				}.alert("Name Your Filter", isPresented: $modalStateViewModel.showingNameAlert, actions: {
					NameAlert().environment(\.managedObjectContext, managedObjectContext)
	   }, message: {
		   Text("Enter a name for your new filter:")
	   })
#endif
		}
#if os(macOS)

			.onReceive(NotificationCenter.default.publisher(for: .showOpenPanel))
		{ notification in
					 showOpenPanel()
				 }.onReceive(NotificationCenter.default.publisher(for: .showSavePanel))
		{ notification in
					 showSavePanel()
				 }
		#endif
		.onReceive(NotificationCenter.default.publisher(for: .endEditing))
{ notification in
			editMode = nil
		}
#if os(iOS)
		.navigationBarTitleDisplayMode(.inline)
#else
		.background(WindowAccessor(window: $window))
#endif
	}
	
	func getEditor(proxy: GeometryProxy) -> some View {
		//GroupBox {
			VStack(spacing: 10) {
				#if os(iOS)
				HStack(spacing: 50) {
					Menu(content: {
						Button("Modified Image") {
							modalStateViewModel.showingPreviewModal = true
						}
						Button("Unmodfied Image") {
							modalStateViewModel.showingUnmodifiedImage = true
						}
					}, label: {
						Text("View").controlSize(.large)
					})
					Menu {
						Button("Choose Photo") {
							showingPhotoPicker = true
						}
						Button("Default Photo") {
							useOriginalImage = true
							imageDataStore.imageData = Data()
						}
					} label: {
						Text("Photo").controlSize(.large)
					}.photosPicker(isPresented: $showingPhotoPicker, selection:  $selectedItem, matching: .images).onChange(of: selectedItem) { newItem in
						loading = true
						newItem?.loadTransferable(type: Data.self, completionHandler: { result in
							switch result  {
							case .success(let data):
								if let data = data {
									DispatchQueue.main.async {
										imageDataStore.imageData = data
										useOriginalImage = false
									}
								}
							case .failure( _):
								break
							}
							loading = false
						})
					}
				}
					

				#else
				HStack(spacing: 20) {
					Menu(content: {
						Button("Modified Image") {
							modalStateViewModel.showingPreviewModal = true
						}
						Button("Unmodfied Image") {
							modalStateViewModel.showingUnmodifiedImage = true
						}
					}, label: {
						Text("View")
					}).frame(width: 100)
					Menu(content: {
						Button("Choose Photo") {
							showOpenPanel()
						}

						Button("Default Photo") {
							useOriginalImage = true
							imageDataStore.imageData = Data()
						}
					}, label: {
						Text("Photo")
					}).frame(width: 100)
					Menu {
						Button {
							modalStateViewModel.showingNameAlert = true
						} label: {
							Text("Add Saved Filter")
						}
						Button {
							modalStateViewModel.showingFilters = true
						} label: {
							Text("All Filters")
						}
					} label: {
						Text("Filters...")
					}.frame(width: 100)
						getSavePanelButton()
				}.padding(.bottom)
#endif
				#if os(iOS)
				HStack(spacing: 50) {
					Menu {
						Button {
							let imageSaver = ImageSaver(showingSuccessAlert: $modalStateViewModel.showingImageSaveSuccesAlert, showingErrorAlert: $showingImageSaveFailureAlert)
							imageSaver.writeToPhotoAlbum(image: getFilteredImage())
						} label: {
							Text("Export to Photos")
						}
						Button {
							modalStateViewModel.showingShareSheet = true
						} label: {
							Text("Share Image")
						}
					} label: {
						Text("Share/Export").controlSize(.large)
					}
					Menu {
						Button {
							modalStateViewModel.showingNameAlert = true
						} label: {
							Text("Add Saved Filter")
						}
						Button {
							modalStateViewModel.showingFilters = true
						} label: {
							Text("All Filters")
						}
					} label: {
						Text("Filters...").controlSize(.large)
					}
				}
				#endif
				InfoSeperator()
				VStack {
					getFilterControls(proxy: proxy)
				}
			}
			#if os(macOS)
			.padding(.vertical)
			#endif
	}
	
	func getDisplay() -> some View {
		Group {
			if loading {
				VStack {
					Text("Loading Image...")
					ProgressView().controlSize(.large)
				}
			} else if waitingForDrop {
				VStack(spacing: 20) {
					Text("Drop image file here:").font(.largeTitle).padding()
					Image(systemName: "square.and.arrow.down").resizable().aspectRatio(contentMode: .fit).foregroundColor(Color.accentColor).padding()
					Button {
						waitingForDrop = false
					} label: {
						Text("Cancel Drag and Drop")
					}.buttonStyle(.borderedProminent).keyboardShortcut(.defaultAction).controlSize(.large).padding()

				}
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
		/*
		#if os(macOS)
		.dropDestination(for: NSImage.self) { items, location in
				if let image = items.first {
					DispatchQueue.global(qos: .userInitiated).async {
						self.image = image.tiffRepresentation ?? Data()
						useOriginalImage = false
						waitingForDrop = false
					}
					return true
				} else {
					return false
				}
		}
		#endif
		.onChange(of: image) { newValue in
			imageDataStore.imageData = image
		}
		 */
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

#if os(iOS)
	func getImageForSharing() -> UIImage {
		if useOriginalImage {
			return UIImage(named: "FallColors") ?? UIImage()
		} else {
			return UIImage(data: imageDataStore.imageData)  ?? UIImage()
		}
	}
#endif
	func getFilterControls(proxy: GeometryProxy) -> some View {
		Group {
				VStack {
					ScrollView([.horizontal]) {
						HStack(alignment: .top) {
							ForEach(imageEditModesData, id: \.mode.rawValue) { modeData in
								VStack(spacing: 10) {
									Text(modeData.mode.rawValue.capitalized).font(.system(.callout)).fixedSize().if(modeData.mode == editMode) { view in
										view.foregroundColor(Color.accentColor)
									}
									if modeData.mode == .invert {
										Toggle(isOn: $invertColors) {
											Text("")
										}.toggleStyle(.switch).tint(Color.accentColor)
									} else {
										Image(systemName: modeData.imageName).font(.system(.title)).if(modeData.mode == editMode) { view in
											view.foregroundColor(Color.accentColor)
										}
									}
								}.padding(.horizontal).contentShape(Rectangle()).onTapGesture {
									storeSnapshot()
									withAnimation {
										if modeData.mode != .invert {
											editMode = modeData.mode
										}
									}
								}
							}.padding(.vertical, 5)
						}
						#if os(iOS)
						.if(proxy.size.width > 1000) { view in
							view.frame(width: proxy.size.width)
						}
						#else
						.frame(width: proxy.size.width)
						#endif
					}
				}
				getFilterControl().frame(maxWidth: 600)
			InfoSeperator()
			HStack(spacing: 50) {
				Button {
					withAnimation {
						restoreSnapshot()
					}
				} label: {
					Text("Undo")
				}
				Button {
					withAnimation {
					}
				} label: {
					Text("Redo")
				}
			}
		}
		
	}
	
	func storeSnapshot() {
		invertColorsSnaphhot = invertColors
		hueRotationSnaphhot = hueRotation
		useHueRotationSnapshot = useHueRotation
		contrastSnapshot = contrast
		useContrastSnapshot = useContrast
		useColorMultiplySnapshot = useColorMultiply
		colorMultiplyColorSnapshot = colorMultiplyColor
		useSaturationSnapshot = useSaturation
		saturationSnapshot = saturation
		useGrayscaleSnapshot = useGrayscale
		grayscaleSnapshot = grayscale
		useOpacitySnapshot = useOpacity
		opacitySnapshot = opacity
		useBlurSnapshot = useBlur
		blurSnapshot = blur
	}
	
	func restoreSnapshot() {
		invertColors = invertColorsSnaphhot
		hueRotation = hueRotationSnaphhot
		useHueRotation = useHueRotationSnapshot
		contrast = contrastSnapshot
		useContrast = useContrastSnapshot
		useColorMultiply = useColorMultiplySnapshot
		colorMultiplyColor = colorMultiplyColorSnapshot
		useSaturation = useSaturationSnapshot
		saturation = saturationSnapshot
		useGrayscale = useGrayscaleSnapshot
		grayscale = grayscaleSnapshot
		useOpacity = useOpacitySnapshot
		opacity = opacitySnapshot
		useBlur = useBlurSnapshot
		blur = blurSnapshot
	}
	
	func getFilterControl() -> some View {
		Group{
			if editMode == nil {
				EmptyView()
			}
			else {
				switch editMode {
				case .hue:
					HueRotationControl(useHueRotation: $useHueRotation, hueRotation: $hueRotation)
				case .contrast:
					HStack {
						Toggle("", isOn: $useContrast.animation()).toggleStyle(.switch).tint(Color.accentColor).frame(width: 50)
						ContrastControl(contrast: $contrast).disabled(!useContrast)
					}
				case .invert:
					EmptyView()
				case .colorMultiply:
					HStack {
						Toggle("", isOn: $useColorMultiply.animation()).toggleStyle(.switch).tint(Color.accentColor).frame(width: 50)
						ColorMultiplyControl(colorMultiplyColor: $colorMultiplyColor).disabled(!useColorMultiply)
					}
				case .saturation:
					HStack {
						Toggle("", isOn: $useSaturation.animation()).toggleStyle(.switch).tint(Color.accentColor).frame(width: 50)
						SaturationControl(saturation: $saturation).disabled(!useSaturation)
					}
				case .grayscale:
					HStack {
						Toggle("", isOn: $useGrayscale.animation()).toggleStyle(.switch).tint(Color.accentColor).frame(width: 50)
						GrayscaleControl(grayscale: $grayscale).disabled(!useGrayscale)
					}
				case .opacity:
					HStack {
						Toggle("", isOn: $useOpacity.animation()).toggleStyle(.switch).tint(Color.accentColor).frame(width: 50)
						OpacityControl(opacity: $opacity).disabled(!useOpacity)
					}
				case .blur:
					HStack {
						Toggle("", isOn: $useBlur.animation()).toggleStyle(.switch).tint(Color.accentColor).frame(width: 50)
						BlurControl(blur: $blur).disabled(!useBlur)
					}
				case .none:
					EmptyView()
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
		
		Button {
			showSavePanel()
		} label: {
			//Label("Export Image", systemImage: "square.and.arrow.down")
			Text("Export Image")
		}
	}
	#endif
	
	#if os(iOS)
	@MainActor func getFilteredImage(forSharing: Bool = false) -> UIImage {
		var originalWidth = 1000.0
		var originalHeight = 1000.0
		var desiredWidth = 1000.0
		var desiredHeight = 1000.0
		if useOriginalImage {
			desiredWidth = 750.0
			desiredHeight = 1000.0
		} else {
			let uiImage = (UIImage(data: imageDataStore.imageData)  ?? UIImage())
			originalWidth = uiImage.size.width
			originalHeight = uiImage.size.height
			if originalWidth >= originalHeight && originalWidth >= 1000.0 {
				let scaleFactor = 1000.0/originalWidth
				desiredWidth =  originalWidth * scaleFactor
				desiredHeight = originalHeight * scaleFactor
			} else if originalHeight >= originalWidth && originalHeight >= 1000.0 {
				let scaleFactor = 1000.0/originalHeight
				desiredWidth =  originalWidth * scaleFactor
				desiredHeight = originalHeight * scaleFactor
			} else {
				desiredWidth = originalWidth
				desiredHeight = originalHeight
			}
		}
		let renderer = ImageRenderer(content: Image(uiImage: getImageForSharing()).resizable().aspectRatio(contentMode: .fit).if(forSharing, transform: { view in
			view.frame(width: desiredWidth, height: desiredHeight)
		})
			.if(invertColors, transform: { view in
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

			//renderer.scale = displayScale
			if let uiImage = renderer.uiImage {
				return uiImage
			}
		return UIImage(named: "FallColors") ?? UIImage()
		}
	#else
	@MainActor func getFilteredImage(forSharing: Bool = false) -> NSImage{
		var originalWidth = 1000.0
		var originalHeight = 1000.0
		var desiredWidth = 1000.0
		var desiredHeight = 1000.0
		if useOriginalImage {
			desiredWidth = 750.0
			desiredHeight = 1000.0
		} else {
			let nsImage = (NSImage(data: imageDataStore.imageData)  ?? NSImage())
			originalWidth = nsImage.size.width
			originalHeight = nsImage.size.height
			if originalWidth >= originalHeight && originalWidth >= 1000.0 {
				let scaleFactor = 1000.0/originalWidth
				desiredWidth =  originalWidth * scaleFactor
				desiredHeight = originalHeight * scaleFactor
			} else if originalHeight >= originalWidth && originalHeight >= 1000.0 {
				let scaleFactor = 1000.0/originalHeight
				desiredWidth =  originalWidth * scaleFactor
				desiredHeight = originalHeight * scaleFactor
			} else {
				desiredWidth = originalWidth
				desiredHeight = originalHeight
			}
		}
		let renderer = ImageRenderer(content: getImage().resizable().aspectRatio(contentMode: .fit).if(forSharing, transform: { view in
			view.frame(width: desiredWidth, height: desiredHeight)
		}).if(invertColors, transform: { view in
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

			//renderer.scale = displayScale
		if let nsImage = renderer.nsImage {
			return  nsImage
		}
		return NSImage(named: "FallColors") ?? NSImage()
		}
	#endif

	#if os(macOS)
	func showOpenPanel() {
		modalStateViewModel.showingOpenPanel = true
		let openPanel = NSOpenPanel()
					openPanel.prompt = "Choose Photo"
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
							let imageData = try Data(contentsOf: url)
							var originalWidth = 1000.0
							var originalHeight = 1000.0
							var desiredWidth = 1000.0
							var desiredHeight = 1000.0
							if let fullSizeImage = NSImage(data: imageData) {
								originalWidth = fullSizeImage.size.width
								originalHeight = fullSizeImage.size.height
								if originalWidth >= originalHeight && originalWidth >= 1000.0 {
									let scaleFactor = 1000.0/originalWidth
									desiredWidth =  originalWidth * scaleFactor
									desiredHeight = originalHeight * scaleFactor
								} else if originalHeight >= originalWidth && originalHeight >= 1000.0 {
									let scaleFactor = 1000.0/originalHeight
									desiredWidth =  originalWidth * scaleFactor
									desiredHeight = originalHeight * scaleFactor
								} else {
									desiredWidth = originalWidth
									desiredHeight = originalHeight
								}
								let destSize = NSMakeSize(desiredWidth, desiredHeight)
								let newImage = NSImage(size: destSize)
								newImage.lockFocus()
								fullSizeImage.draw(in: NSMakeRect(0, 0, destSize.width, destSize.height), from: NSMakeRect(0, 0, fullSizeImage.size.width, fullSizeImage.size.height), operation: NSCompositingOperation.sourceOver, fraction: CGFloat(1))
								newImage.unlockFocus()
								newImage.size = destSize
								if let newImageData = newImage.tiffRepresentation {
									imageDataStore.imageData = newImageData
									useOriginalImage = false
								}
							}
						} catch {
							print ("Error getting data from image file url.")
						}
					}
				}
				modalStateViewModel.showingOpenPanel = false
			}
		}
	}
	
	func showSavePanel() {
		modalStateViewModel.showingSavePanel = true
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
					
				} else {
					
				}
				modalStateViewModel.showingSavePanel = false
			}
		}
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
#if os(macOS)
extension NSImage: Transferable {
	public static var transferRepresentation: some TransferRepresentation {
		DataRepresentation(importedContentType: .image) { data in
			NSImage(data: data) ?? NSImage()
		}
	}
}
#endif

enum ImageEditMode: String, CaseIterable {
	case hue
	case contrast
	case invert
	case colorMultiply = "Color Multiply"
	case saturation
	case grayscale
	case opacity
	case blur
}

struct ImageEditModeData {
	var mode: ImageEditMode
	var imageName: String
}

let imageEditModesData = [ImageEditModeData(mode: .hue, imageName: "paintbrush"),
					  ImageEditModeData(mode: .contrast, imageName: "circle.lefthalf.filled"),
					  ImageEditModeData(mode: .invert, imageName: "lightswitch.off"),
					  ImageEditModeData(mode: .colorMultiply, imageName: "paintpalette"),
					  ImageEditModeData(mode: .saturation, imageName: "sun.max"),
					  ImageEditModeData(mode: .grayscale, imageName: "circle.dotted"),
					  ImageEditModeData(mode: .opacity, imageName: "circle"),
					  ImageEditModeData(mode: .blur, imageName: "camera.filters")]
