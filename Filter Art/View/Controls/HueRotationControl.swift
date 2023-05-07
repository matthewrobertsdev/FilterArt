//
//  HueRotationControl.swift
//  SwiftUI Design
//
//  Created by Matt Roberts on 9/12/22.
//

import SwiftUI

struct HueRotationControl: View {
	@Binding private var hueRotation: Double
	var saveForUndo: () -> Void
	let min = 0
	let max = 360
	init(hueRotation: Binding<Double>, saveForUndo: @escaping () -> Void) {
		self._hueRotation = hueRotation
		self.saveForUndo = saveForUndo
	}
    var body: some View {
		SliderFilterControl(value: $hueRotation, saveForUndo: saveForUndo, min: min, max: max)
    }
}

/*
struct HueRotationControl_Previews: PreviewProvider {
    static var previews: some View {
        HueRotationControl()
    }
}
*/
