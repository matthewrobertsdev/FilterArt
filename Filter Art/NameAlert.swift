//
//  NameAlert.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/23/23.
//

import SwiftUI

struct NameAlert: View {
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
	@Environment(\.managedObjectContext) var managedObjectContext
	@State var renameString: String = ""
    var body: some View {
		Group {
			TextField("Name Text Field", text: $renameString, prompt: Text("Filter Name"))
			Button {
				DispatchQueue.main.async {
					let savedFilter = Filter(context: managedObjectContext)
					savedFilter.blur = blur
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
					savedFilter.name = renameString
					savedFilter.opacity = opacity
					savedFilter.saturation = saturation
					savedFilter.saveDate = Date()
					savedFilter.useBlur = useBlur
					savedFilter.useColorMultiply = useColorMultiply
					savedFilter.useContrast = useContrast
					savedFilter.useGrayscale = useGrayscale
					savedFilter.useHueRotation = useHueRotation
					savedFilter.useOpacity = useOpacity
					savedFilter.useSaturation = useSaturation
					do {
						try managedObjectContext.save()
					} catch {
						
					}
				}
			} label: {
				Text("Save")
			}.keyboardShortcut(.defaultAction)
			#if os(macOS)
			.disabled(renameString == "")
			#endif
			Button {
				
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
