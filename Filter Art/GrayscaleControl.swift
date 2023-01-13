//
//  GrayscaleControl.swift
//  SwiftUI Design
//
//  Created by Matt Roberts on 9/12/22.
//

import SwiftUI

struct GrayscaleControl: View {
	@Binding private var grayscale: Double
	init(grayscale: Binding<Double>) {
		self._grayscale = grayscale
	}
    var body: some View {
		HStack {
			Text("\(0)")
			Spacer()
			Slider(value: $grayscale, in: 0...1)
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
