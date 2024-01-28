//
//  BrightnessControl.swift
//  Filter Art
//
//  Created by Matt Roberts on 3/11/23.
//

import Foundation
import SwiftUI

struct BrightnessControl: View {
	@Binding private var brightness: Double
	var saveForUndo: () -> Void
	init(brightness: Binding<Double>, saveForUndo: @escaping () -> Void) {
		self._brightness = brightness
		self.saveForUndo = saveForUndo
	}
	let min = -2
	let max = 2
	var body: some View {
		SliderFilterControl(value: $brightness, saveForUndo: saveForUndo, min: min, max: max)
	}
}


/*
struct BrightnessControl_Previews: PreviewProvider {
	static var previews: some View {
		BrightnessControl()
	}
}
*/

