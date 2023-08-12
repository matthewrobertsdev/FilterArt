//
//  SaturationControl.swift
//  SwiftUI Design
//
//  Created by Matt Roberts on 9/12/22.
//

import SwiftUI

struct SaturationControl: View {
	@Binding private var saturation: Double
	var saveForUndo: () -> Void
	init(saturation: Binding<Double>, saveForUndo: @escaping () -> Void) {
		self._saturation = saturation
		self.saveForUndo = saveForUndo
	}
	let min = 1
	let max = 50
	var body: some View {
		SliderFilterControl(value: $saturation, saveForUndo: saveForUndo, min: min, max: max)
	}
}

/*
struct SaturationControl_Previews: PreviewProvider {
    static var previews: some View {
        SaturationControl()
    }
}
*/
