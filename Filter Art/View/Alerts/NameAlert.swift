//
//  NameAlert.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/23/23.
//

import SwiftUI

struct NameAlert: View {
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
	@Environment(\.managedObjectContext) var managedObjectContext
	@State var nameString: String = ""
    var body: some View {
		Group {
			TextField("Name Text Field", text: $nameString, prompt: Text("Filter Name"))
			Button {
				DispatchQueue.main.async {
					let savedFilter = Filter(context: managedObjectContext)
					savedFilter.blur = blur
					savedFilter.brightness = brightness
					savedFilter.colorMultiplyB = colorMultiplyColor.components.blue
					savedFilter.colorMultiplyG = colorMultiplyColor.components.green
					savedFilter.colorMultiplyO = colorMultiplyColor.components.opacity
					savedFilter.colorMultiplyR = colorMultiplyColor.components.red
					savedFilter.contrast = contrast
					savedFilter.favoriteDate = Date()
					savedFilter.grayscale = grayscale
					savedFilter.hueRotation = hueRotation
					savedFilter.id = UUID().uuidString
					savedFilter.invertColors = invertColors
					savedFilter.isFavorite = false
					savedFilter.isPreset = false
					savedFilter.name = nameString
					savedFilter.opacity = opacity
					savedFilter.saturation = saturation
					savedFilter.saveDate = Date()
					savedFilter.useBlur = useBlur
					savedFilter.useBrightness = useBrightness
					savedFilter.useColorMultiply = useColorMultiply
					savedFilter.useContrast = useContrast
					savedFilter.useGrayscale = useGrayscale
					savedFilter.useHueRotation = useHueRotation
					savedFilter.useOpacity = useOpacity
					savedFilter.useSaturation = useSaturation
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
