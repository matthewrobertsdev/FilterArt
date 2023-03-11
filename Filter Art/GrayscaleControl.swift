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
    var body: some View {
		HStack {
			Text("\(0)")
			Spacer()
			Slider(value: $grayscale, in: 0...1){ editing in
				if !editing {
					saveForUndo()
				}
			}
			Spacer()
			Text("\(1)")
		}
    }
}

/*
struct GrayscaleControl_Previews: PreviewProvider {
    static var previews: some View {
        GrayScaleControl()
    }
}
*/
