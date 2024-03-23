//
//  NameAlert.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/23/23.
//

import SwiftUI

struct NameAlert: View {
	
	@Environment(\.managedObjectContext) var managedObjectContext
	
	@EnvironmentObject var imageViewModel: ImageViewModel
	
	@State var nameString: String = ""
	
    var body: some View {
		Group {
			TextField("Name Text Field", text: $nameString, prompt: Text("Filter Name"))
			Button {
				DispatchQueue.main.async {
					let savedFilter = Filter(context: managedObjectContext)
					savedFilter.blur = imageViewModel.blur
					savedFilter.brightness = imageViewModel.brightness
					savedFilter.colorMultiplyB = imageViewModel.colorMultiplyColor.components.blue
					savedFilter.colorMultiplyG = imageViewModel.colorMultiplyColor.components.green
					savedFilter.colorMultiplyO = imageViewModel.colorMultiplyColor.components.opacity
					savedFilter.colorMultiplyR = imageViewModel.colorMultiplyColor.components.red
					savedFilter.contrast = imageViewModel.contrast
					savedFilter.favoriteDate = Date()
					savedFilter.grayscale = imageViewModel.grayscale
					savedFilter.hueRotation = imageViewModel.hueRotation
					savedFilter.id = UUID().uuidString
					savedFilter.invertColors = imageViewModel.invertColors
					savedFilter.isFavorite = false
					savedFilter.isPreset = false
					savedFilter.name = nameString
					savedFilter.opacity = imageViewModel.opacity
					savedFilter.saturation = imageViewModel.saturation
					savedFilter.saveDate = Date()
					savedFilter.useBlur = imageViewModel.useBlur
					savedFilter.useBrightness = imageViewModel.useBrightness
					savedFilter.useColorMultiply = imageViewModel.useColorMultiply
					savedFilter.useContrast = imageViewModel.useContrast
					savedFilter.useGrayscale = imageViewModel.useGrayscale
					savedFilter.useHueRotation = imageViewModel.useHueRotation
					savedFilter.useOpacity = imageViewModel.useOpacity
					savedFilter.useSaturation = imageViewModel.useSaturation
					nameString = ""
					do {
						try managedObjectContext.save()
					} catch {
						
					}
				}
			} label: {
				Text("Save")
			}.keyboardShortcut(.defaultAction)
			#if os(macOS)
			.disabled(nameString == "")
			#endif
			Button {
				nameString = ""
			} label: {
				Text("Cancel")
			}
		}
    }
}

/*
struct NameAlert_Previews: PreviewProvider {
    static var previews: some View {
        NameAlert()
    }
}
*/
