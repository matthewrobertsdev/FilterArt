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
	@Environment(\.colorScheme) private var colorScheme
	@Environment(\.managedObjectContext) var managedObjectContext
	@EnvironmentObject var filterStateHistory: FilterStateHistory
	@EnvironmentObject var modalStateViewModel: ModalStateViewModel
	@StateObject private var imageDataStore = ImageDataStore()
	@AppStorage("imageInvertColors") private var invertColors: Bool = false
	@AppStorage("imageHueRotation") private var hueRotation: Double = 0
	@AppStorage("imageUseHueRotation") private var useHueRotation: Bool = true
	@AppStorage("imageContrast") private var contrast: Double = 1
	@AppStorage("imageUseContrast") private var useContrast: Bool = true
	@AppStorage("imageUseColorMultiply") private var useColorMultiply: Bool = true
	@AppStorage("imageColorMultiplyColor") private var colorMultiplyColor: Color = Color.white
	@AppStorage("imageUseSaturation") private var useSaturation: Bool = true
	@AppStorage("imageSaturation") private var saturation: Double = 1
	@AppStorage("imageUseBrightness") private var useBrightness: Bool = true
	@AppStorage("imageBrightness") private var brightness: Double = 0
	@AppStorage("imageUseGrayscale") private var useGrayscale: Bool = true
	@AppStorage("imageGrayscale") private var grayscale: Double = 0
	@AppStorage("imageUseOpacity") private var useOpacity: Bool = true
	@AppStorage("imageOpacity") private var opacity: Double = 1
	@AppStorage("imageUseBlur") private var useBlur: Bool = true
	@AppStorage("imageBlur") private var blur: Double = 0
	@State private var image: Data = Data()
	@AppStorage("imageUseOriginalImage") private var useOriginalImage: Bool = true
	@State var showingImageSaveFailureAlert = false
	@State var loading = false
	@State private var selectedItem: PhotosPickerItem? = nil
	@State private var editMode: ImageEditMode? = nil
	@State private var showingPhotoPicker: Bool = false
	@State private var lastColorEditDate: Date = Date.now
#if os(macOS)
	@State private var window: NSWindow?
#endif
	init() {
	}
	var body: some View {
		Group {
#if os(macOS)
			ZStack {
				VStack(spacing: 10) {
					getDisplay()
					InfoSeperator()
					GeometryReader { proxy in
						getEditor(proxy: proxy).frame(maxWidth: .infinity)
					}.frame(height: 200/*165*/)
				}
				ImageDropReceiver().environmentObject(imageDataStore)
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
				storeSnapshot()
			}.sheet(isPresented: $modalStateViewModel.showingFilters) {
				FiltersView(showing: $modalStateViewModel.showingFilters).environmentObject(imageDataStore)
					.environmentObject(filterStateHistory)
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
					.environmentObject(filterStateHistory)
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
				storeSnapshot()
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
		.onReceive(NotificationCenter.default.publisher(for: .endEditing))
		{ notification in
			NSColorPanel.shared.close()
		}
#endif
		.onReceive(NotificationCenter.default.publisher(for: .undo))
		{ notification in
			print("abcd")
			handleUndo()
		}.onReceive(NotificationCenter.default.publisher(for: .redo))
		{ notification in
			handleRedo()
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
			HStack(spacing: 30) {
				PhotosPicker(selection:  $selectedItem, matching: .images)  {
					Label("Choose Image", systemImage: "photo").labelStyle(.titleOnly)
				}.onChange(of: selectedItem) { newItem in
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
				Button {
					modalStateViewModel.showingFilters = true
				} label: {
					Label("Filters…", systemImage: "camera.filters").labelStyle(.titleOnly)
				}.controlSize(.regular)
				/*
				 Menu {
				 Button("Choose Photo") {
				 showingPhotoPicker = true
				 }
				 Button("Use Default Photo") {
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
				 Text("Filters…").controlSize(.large)
				 }
				 */
			}
			
#else
			HStack(spacing: 15) {
				/*
				 Button {
				 /*NotificationCenter.default.post(name: .showOpenPanel,
				  object: nil, userInfo: nil)
				  */
				 imageDataStore.waitingForDrop.toggle()
				 } label: {
				 Label("Drop in Image", systemImage: "photo").labelStyle(.titleOnly)
				 }.buttonStyle(.bordered).controlSize(.regular).disabled(imageDataStore.waitingForDrop)
				 */
				Button {
					NotificationCenter.default.post(name: .showOpenPanel,
													object: nil, userInfo: nil)
				} label: {
					Label("Choose Image", systemImage: "photo").labelStyle(.titleOnly)
				}.buttonStyle(.bordered).controlSize(.regular)
				Button {
					modalStateViewModel.showingFilters = true
				} label: {
					Label("Filters…", systemImage: "camera.filters").labelStyle(.titleOnly)
				}.buttonStyle(.bordered).controlSize(.regular)
				Button {
					modalStateViewModel.showingNameAlert = true
				} label: {
					Label("Save Filter", systemImage: "plus").labelStyle(.titleOnly)
				}.buttonStyle(.bordered).controlSize(.regular)
				ShareLink(item: Image(nsImage: getFilteredImage(forSharing: true)), preview: SharePreview(Text("Filtered Image"), image: Image(nsImage: getFilteredImage(forSharing: true)), icon: Image(nsImage: getFilteredImage(forSharing: true)))).labelStyle(.iconOnly).buttonStyle(.bordered).controlSize(.regular)
				Menu {
					Button {
						NotificationCenter.default.post(name: .showSavePanel,
														object: nil, userInfo: nil)
					} label: {
						Text("Export Image…").labelStyle(.titleOnly)
					}
					Button {
						useOriginalImage = true
					} label: {
						Text("Use Default Image").labelStyle(.titleOnly)
					}
					Button {
						modalStateViewModel.showingUnmodifiedImage = true
					} label: {
						Text("View Original Image").labelStyle(.titleOnly)
					}
				} label: {
					Label("More…", systemImage: "ellipsis.circle").labelStyle(.titleOnly)
				}.frame(width: 80).controlSize(.regular)
				
			}
			/*
			 HStack(spacing: 20) {
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
			 Text("Filters…")
			 }.frame(width: 100)
			 getSavePanelButton()
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
			 }.padding(.bottom)
			 */
#endif
#if os(iOS)
			HStack(spacing: 30) {
				Button {
					modalStateViewModel.showingNameAlert = true
				} label: {
					Label("Save Filter", systemImage: "plus").labelStyle(.titleOnly)
				}.controlSize(.regular)
				Button {
					modalStateViewModel.showingShareSheet = true
				} label: {
					Label("Share Image", systemImage: "square.and.arrow.up")
				}.labelStyle(.iconOnly)
				/*
				 ShareLink(item: Image(uiImage: getFilteredImage(forSharing: true)), preview: SharePreview(Text("Filtered Image"), image: Image(uiImage: getFilteredImage(forSharing: true)), icon: Image(uiImage: getFilteredImage(forSharing: true)))).labelStyle(.iconOnly).controlSize(.regular)
				 */
				Menu {
					/*
					 Button {
					 let imageSaver = ImageSaver(showingSuccessAlert: $modalStateViewModel.showingImageSaveSuccesAlert, showingErrorAlert: $showingImageSaveFailureAlert)
					 imageSaver.writeToPhotoAlbum(image: getFilteredImage())
					 } label: {
					 Text("Export to Photos").labelStyle(.titleOnly)
					 }
					 */
					Button {
						useOriginalImage = true
					} label: {
						Text("Use Default Image").labelStyle(.titleOnly)
					}
					Button {
						modalStateViewModel.showingUnmodifiedImage = true
					} label: {
						Text("View Original Image").labelStyle(.titleOnly)
					}
				} label: {
					Label("More…", systemImage: "ellipsis.circle").labelStyle(.titleOnly)
				}.frame(width: 80).controlSize(.regular)
				/*
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
				 */
			}
			InfoSeperator()
#endif
			VStack {
				getFilterControls(proxy: proxy)
			}
		}
	}
	
	func getDisplay() -> some View {
		Group {
			if loading {
				VStack {
					Text("Loading Image…")
					ProgressView().controlSize(.large)
				}
			} else if imageDataStore.waitingForDrop {
				VStack(spacing: 20) {
					Text("Drop Image Here:").font(.largeTitle).padding()
					Image(systemName: "square.and.arrow.down").resizable().aspectRatio(contentMode: .fit).frame(maxWidth: 500, maxHeight: 500).foregroundColor(Color.accentColor).padding()
					Button {
						imageDataStore.waitingForDrop = false
					} label: {
						Text("Cancel Drag and Drop")
					}.buttonStyle(.borderedProminent).keyboardShortcut(.defaultAction).controlSize(.large).padding()
					
				}
			} else {
				Group {
					getImage().resizable().aspectRatio(contentMode: .fit).if(useHueRotation, transform: { view in
						view.hueRotation(.degrees(hueRotation))
					}).if(useContrast, transform: { view in
						view.contrast(contrast)
					}).if(invertColors, transform: { view in
						view.colorInvert()
					}).if(useColorMultiply, transform: { view in
						view.colorMultiply(colorMultiplyColor)
					}).if(useSaturation, transform: { view in
						view.saturation(saturation)
					}).if(useBrightness, transform: { view in
						view.brightness(brightness)
					}).if(useGrayscale, transform: { view in
						view.grayscale(grayscale)
					}).if(useOpacity, transform: { view in
						view.opacity(opacity)
					}).if(useBlur) { view in
						view.blur(radius: blur)
					}
				}
#if os(macOS)
				.onDrag {
					let dateFormatter = DateFormatter()
					dateFormatter.dateFormat = "M-d-y h.mm a"
					let dateString = dateFormatter.string(from: Date())
					let filename = "Image \(dateString).png"
					let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)
					guard let tiffRepresentation = getFilteredImage(forSharing: true).tiffRepresentation else {
						return NSItemProvider(item: url as NSSecureCoding?, typeIdentifier: UTType.fileURL.identifier)
					}
					let bitmapImage = NSBitmapImageRep(data: tiffRepresentation)
					guard let bitmapRepresentation = bitmapImage?.representation(using: .png, properties: [:]) else {
						return NSItemProvider(item: url as NSSecureCoding?, typeIdentifier: UTType.fileURL.identifier)
					}
					
					try? bitmapRepresentation.write(to: url)
					
					let provider = NSItemProvider(item: url as NSSecureCoding?, typeIdentifier: UTType.fileURL.identifier)
					provider.suggestedName = filename
					return provider
				}
#endif
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
					getImage().resizable().aspectRatio(contentMode: .fit).if(useHueRotation, transform: { view in
						view.hueRotation(.degrees(hueRotation))
					}).if(useContrast, transform: { view in
						view.contrast(contrast)
					}).if(invertColors, transform: { view in
						view.colorInvert()
					})
						.if(useColorMultiply, transform: { view in
							view.colorMultiply(colorMultiplyColor)
						}).if(useSaturation, transform: { view in
							view.saturation(saturation)
						}).if(useBrightness, transform: { view in
							view.brightness(brightness)
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
				getImage().resizable().aspectRatio(contentMode: .fit).frame(height: 525).clipped().if(useHueRotation, transform: { view in
					view.hueRotation(.degrees(hueRotation))
				}).if(useContrast, transform: { view in
					view.contrast(contrast)
				}).if(invertColors, transform: { view in
					view.colorInvert()
				}).if(useColorMultiply, transform: { view in
					view.colorMultiply(colorMultiplyColor)
				}).if(useSaturation, transform: { view in
					view.saturation(saturation)
				}).if(useBrightness, transform: { view in
					view.brightness(brightness)
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
							VStack(spacing: 5) {
								Text(modeData.mode.rawValue.capitalized).font(.system(.callout)).fixedSize().if(modeData.mode == editMode) { view in
									view.foregroundColor(Color.accentColor)
								}
								if modeData.mode == .invert {
									Toggle(isOn: $invertColors) {
										Text("")
									}.toggleStyle(.switch).tint(Color.accentColor).onChange(of: invertColors) { newValue in
										if !filterStateHistory.isModifying {
											storeSnapshot()
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
			getFilterControl().frame(maxWidth: 600)
			InfoSeperator()
			HStack(spacing: 30) {
				Button {
					resetAll()
					storeSnapshot()
				} label: {
					Text("Reset All")
				}.disabled(shouldDisableResetAll())
				Button {
					handleUndo()
				} label: {
					Text("Undo")
				}.disabled(!filterStateHistory.canUndo)
				Button {
					handleRedo()
				} label: {
					Text("Redo")
				}.disabled(!filterStateHistory.canRedo)
			}
#if os(macOS)
			.padding(.top)
#endif
		}
		
	}
	
	func shouldDisableResetAll() -> Bool {
		return blur == originalFilter.blur && brightness == originalFilter.brightness
		&& abs(colorMultiplyColor.components.red - originalFilter.colorMultiplyR) < 0.02
		&& abs(colorMultiplyColor.components.blue - originalFilter.colorMultiplyB) < 0.02
		&& abs(colorMultiplyColor.components.green - originalFilter.colorMultiplyG) < 0.02
		&& abs(colorMultiplyColor.components.opacity - originalFilter.colorMultiplyO) < 0.02
		&& contrast == originalFilter.contrast && grayscale == originalFilter.grayscale
		&& hueRotation == originalFilter.hueRotation && invertColors == originalFilter.invertColors
		&& opacity == originalFilter.opacity && saturation == originalFilter.saturation
		&& useBlur == originalFilter.useBlur && useBrightness == originalFilter.useBrightness
		&& useColorMultiply == originalFilter.useColorMultiply
		&& useContrast == originalFilter.useContrast
		&& useGrayscale == originalFilter.useGrayscale
		&& useHueRotation == originalFilter.useHueRotation
		&& useOpacity == originalFilter.useOpacity
		&& useSaturation == originalFilter.useSaturation
	}
	
	func storeSnapshot() {
		filterStateHistory.forUndo.append(FilterModel(blur: blur, brightness: brightness, colorMultiplyO: colorMultiplyColor.components.opacity, colorMultiplyB: colorMultiplyColor.components.blue, colorMultiplyG: colorMultiplyColor.components.green, colorMultiplyR: colorMultiplyColor.components.red, contrast: contrast, grayscale: grayscale, hueRotation: hueRotation, id: UUID().uuidString, invertColors: invertColors, opacity: opacity, name: "App State Filter", saturation: saturation, timestamp: Date(), useBlur: useBlur, useBrightness: useBrightness, useColorMultiply: useColorMultiply, useContrast: useContrast, useGrayscale: useGrayscale, useHueRotation: useHueRotation, useOpacity: useOpacity, useSaturation: useSaturation))
		filterStateHistory.forRedo = [FilterModel]()
	}
	
	func restoreSnapshot(stateToRestore: FilterModel?) {
		print("abcd restore")
		if let stateToRestore = stateToRestore {
			invertColors = stateToRestore.invertColors
			hueRotation = stateToRestore.hueRotation
			useHueRotation = stateToRestore.useHueRotation
			contrast = stateToRestore.contrast
			brightness = stateToRestore.brightness
			useBrightness = stateToRestore.useBrightness
			useContrast = stateToRestore.useContrast
			useColorMultiply = stateToRestore.useColorMultiply
			colorMultiplyColor = Color(red: stateToRestore.colorMultiplyR, green: stateToRestore.colorMultiplyG, blue: stateToRestore.colorMultiplyB, opacity: stateToRestore.colorMultiplyO)
			useSaturation = stateToRestore.useSaturation
			saturation = stateToRestore.saturation
			useGrayscale = stateToRestore.useGrayscale
			grayscale = stateToRestore.grayscale
			useOpacity = stateToRestore.useOpacity
			opacity = stateToRestore.opacity
			useBlur = stateToRestore.useOpacity
			blur = stateToRestore.blur
		}
	}
	
	func resetAll() {
			invertColors = originalFilter.invertColors
			hueRotation = originalFilter.hueRotation
			useHueRotation = originalFilter.useHueRotation
			contrast = originalFilter.contrast
			brightness = originalFilter.brightness
			useBrightness = originalFilter.useBrightness
			useContrast = originalFilter.useContrast
			useColorMultiply = originalFilter.useColorMultiply
			colorMultiplyColor = Color(red: originalFilter.colorMultiplyR, green: originalFilter.colorMultiplyG, blue: originalFilter.colorMultiplyB, opacity: originalFilter.colorMultiplyO)
			useSaturation = originalFilter.useSaturation
			saturation = originalFilter.saturation
			useGrayscale = originalFilter.useGrayscale
			grayscale = originalFilter.grayscale
			useOpacity = originalFilter.useOpacity
			opacity = originalFilter.opacity
			useBlur = originalFilter.useOpacity
			blur = originalFilter.blur
	}
	
	func getFilterControl() -> some View {
		Group{
			if editMode == nil {
				EmptyView()
			}
			else {
				switch editMode {
				case .hue:
					HStack {
						Toggle("", isOn: $useHueRotation).toggleStyle(.switch).tint(Color.accentColor).frame(width: 50).controlSize(.small).onChange(of: useHueRotation) { newValue in
							if !filterStateHistory.isModifying {
								storeSnapshot()
							}
						}
						HueRotationControl(hueRotation: $hueRotation, saveForUndo: {
							storeSnapshot()
						}).disabled(!useHueRotation)
					}
				case .contrast:
					HStack {
						Toggle("", isOn: $useContrast).toggleStyle(.switch).tint(Color.accentColor).frame(width: 50).controlSize(.small).onChange(of: useContrast) { newValue in
							if !filterStateHistory.isModifying {
								storeSnapshot()
							}
						}
						ContrastControl(contrast: $contrast, saveForUndo: {
							storeSnapshot()
						}).disabled(!useContrast)
					}
				case .invert:
					EmptyView()
				case .colorMultiply:
					HStack {
						Toggle("", isOn: $useColorMultiply).toggleStyle(.switch).tint(Color.accentColor).frame(width: 50).controlSize(.small).onChange(of: useColorMultiply) { newValue in
							if !filterStateHistory.isModifying {
								storeSnapshot()
							}
						}
						ColorMultiplyControl(colorMultiplyColor: $colorMultiplyColor).disabled(!useColorMultiply).onChange(of: colorMultiplyColor) { newValue in
							if !filterStateHistory.isModifying && lastColorEditDate < Date.now - 1 {
								lastColorEditDate = Date.now
								print("abcd store")
								storeSnapshot()
							} else {
								let lastIndex = filterStateHistory.forUndo.count - 1
								filterStateHistory.forUndo[lastIndex].colorMultiplyR = colorMultiplyColor.components.red
								filterStateHistory.forUndo[lastIndex].colorMultiplyG = colorMultiplyColor.components.green
								filterStateHistory.forUndo[lastIndex].colorMultiplyB = colorMultiplyColor.components.blue
								filterStateHistory.forUndo[lastIndex].colorMultiplyO = colorMultiplyColor.components.opacity
							}
						}.frame(width: 100)
					}
				case .saturation:
					HStack {
						Toggle("", isOn: $useSaturation).toggleStyle(.switch).tint(Color.accentColor).frame(width: 50).controlSize(.small).onChange(of: useSaturation) { newValue in
							if !filterStateHistory.isModifying {
								storeSnapshot()
							}
						}
						SaturationControl(saturation: $saturation, saveForUndo: {
							storeSnapshot()
						}).disabled(!useSaturation)
					}
				case .brightness:
					HStack {
						Toggle("", isOn: $useBrightness).toggleStyle(.switch).tint(Color.accentColor).frame(width: 50).controlSize(.small).onChange(of: useBrightness) { newValue in
							if !filterStateHistory.isModifying {
								storeSnapshot()
							}
						}
						BrightnessControl(brightness: $brightness, saveForUndo: {
							storeSnapshot()
						}).disabled(!useBrightness)
					}
				case .grayscale:
					HStack {
						Toggle("", isOn: $useGrayscale).toggleStyle(.switch).tint(Color.accentColor).frame(width: 50).controlSize(.small).onChange(of: useGrayscale) { newValue in
							if !filterStateHistory.isModifying {
								storeSnapshot()
							}
						}
						GrayscaleControl(grayscale: $grayscale, saveForUndo: {
							storeSnapshot()
						}).disabled(!useGrayscale)
					}
				case .opacity:
					HStack {
						Toggle("", isOn: $useOpacity).toggleStyle(.switch).tint(Color.accentColor).frame(width: 50).controlSize(.small).onChange(of: useOpacity) { newValue in
							if !filterStateHistory.isModifying {
								storeSnapshot()
							}
						}
						OpacityControl(opacity: $opacity, saveForUndo: {
							storeSnapshot()
						}).disabled(!useOpacity)
					}
				case .blur:
					HStack {
						Toggle("", isOn: $useBlur).toggleStyle(.switch).tint(Color.accentColor).frame(width: 50).controlSize(.small).onChange(of: useBlur) { newValue in
							if !filterStateHistory.isModifying {
								storeSnapshot()
							}
						}
						BlurControl(blur: $blur, saveForUndo: {
							storeSnapshot()
						}).disabled(!useBlur)
					}
				case .none:
					EmptyView()
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
			.if(useHueRotation, transform: { view in
				view.hueRotation(.degrees(hueRotation))
			}).if(useContrast, transform: { view in
				view.contrast(contrast)
			}).if(invertColors, transform: { view in
				view.colorInvert()
			}).if(useColorMultiply, transform: { view in
				view.colorMultiply(colorMultiplyColor)
			}).if(useSaturation, transform: { view in
				view.saturation(saturation)
			}).if(useBrightness, transform: { view in
				view.brightness(brightness)
			}).if(useGrayscale, transform: { view in
				view.grayscale(grayscale)
			}).if(useOpacity, transform: { view in
				view.opacity(opacity)
			}).if(useBlur) { view in
				view.blur(radius: blur)
			})
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
		}).if(useHueRotation, transform: { view in
			view.hueRotation(.degrees(hueRotation))
		}).if(useContrast, transform: { view in
			view.contrast(contrast)
		}).if(invertColors, transform: { view in
			view.colorInvert()
		}).if(useColorMultiply, transform: { view in
			view.colorMultiply(colorMultiplyColor)
		}).if(useSaturation, transform: { view in
			view.saturation(saturation)
		}).if(useBrightness, transform: { view in
			view.brightness(brightness)
		}).if(useGrayscale, transform: { view in
			view.grayscale(grayscale)
		}).if(useOpacity, transform: { view in
			view.opacity(opacity)
		}).if(useBlur) { view in
			view.blur(radius: blur)
		})
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
	
	func handleUndo() {
		restoreSnapshot(stateToRestore: filterStateHistory.undo())
		Task {
			try? await Task.sleep(nanoseconds: 1000_000_000)
			filterStateHistory.isModifying = false
		}
	}
	func handleRedo() {
		restoreSnapshot(stateToRestore: filterStateHistory.redo())
		Task {
			try? await Task.sleep(nanoseconds: 1000_000_000)
			filterStateHistory.isModifying = false
		}
	}
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
	case brightness
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
						  ImageEditModeData(mode: .brightness, imageName: "lightbulb"),
						  ImageEditModeData(mode: .grayscale, imageName: "circle.dotted"),
						  ImageEditModeData(mode: .opacity, imageName: "circle"),
						  ImageEditModeData(mode: .blur, imageName: "camera.filters")]
