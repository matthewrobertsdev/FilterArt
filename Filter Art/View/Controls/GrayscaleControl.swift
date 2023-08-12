//
//  GrayscaleControl.swift
//  SwiftUI Design
//
//  Created by Matt Roberts on 9/12/22.
//

import SwiftUI

struct GrayscaleControl: View {
	@Binding private var grayscale: Double
	var saveForUndo: () -> Void
	init(grayscale: Binding<Double>, saveForUndo: @escaping () -> Void) {
		self._grayscale = grayscale
		self.saveForUndo = saveForUndo
	}
	let min = 0
	let max = 1
    var body: some View {
		SliderFilterControl(value: $grayscale, saveForUndo: saveForUndo, min: min, max: max)
    }
}

/*
struct GrayscaleControl_Previews: PreviewProvider {
    static var previews: some View {
        GrayScaleControl()
    }
}
*/
