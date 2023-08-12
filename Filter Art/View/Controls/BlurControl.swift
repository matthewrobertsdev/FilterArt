//
//  BlurControl.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/16/23.
//

import SwiftUI

struct BlurControl: View {
	@Binding private var blur: Double
	var saveForUndo: () -> Void
	init(blur: Binding<Double>, saveForUndo: @escaping () -> Void) {
		self._blur = blur
		self.saveForUndo = saveForUndo
	}
	let min = 0
	let max = 10
	var body: some View {
		SliderFilterControl(value: $blur, saveForUndo: saveForUndo, min: min, max: max)
	}
}

/*
struct BlurControl_Previews: PreviewProvider {
    static var previews: some View {
        BlurControl()
    }
}
*/
