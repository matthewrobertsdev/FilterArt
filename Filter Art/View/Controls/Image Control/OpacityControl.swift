//
//  OpacityControl.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/13/23.
//

import SwiftUI

struct OpacityControl: View {
	@Binding private var opacity: Double
	var saveForUndo: () -> Void
	init(opacity: Binding<Double>, saveForUndo: @escaping () -> Void) {
		self._opacity = opacity
		self.saveForUndo = saveForUndo
	}
	let min = 0
	let max = 1
	var body: some View {
		SliderFilterControl(value: $opacity, saveForUndo: saveForUndo, min: min, max: max)
	}
}

/*
struct OpacityControl_Previews: PreviewProvider {
    static var previews: some View {
        OpacityControl()
    }
}
*/
