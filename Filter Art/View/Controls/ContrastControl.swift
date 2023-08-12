//
//  ContrastControl.swift
//  SwiftUI Design
//
//  Created by Matt Roberts on 9/12/22.
//

import SwiftUI

struct ContrastControl: View {
	@Binding private var contrast: Double
	var saveForUndo: () -> Void
	init(contrast: Binding<Double>, saveForUndo: @escaping () -> Void) {
		self._contrast = contrast
		self.saveForUndo = saveForUndo
	}
	let min = -2
	let max = 2
	var body: some View {
		SliderFilterControl(value: $contrast, saveForUndo: saveForUndo, min: min, max: max)
	}
}

/*
struct ContrastControl_Previews: PreviewProvider {
    static var previews: some View {
        ContrastControl()
    }
}
*/
