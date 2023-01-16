//
//  BlurControl.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/16/23.
//

import SwiftUI

struct BlurControl: View {
	@Binding private var blur: Double
	init(blur: Binding<Double>) {
		self._blur = blur
	}
	var body: some View {
		HStack {
			Text("\(0)")
			Spacer()
			Slider(value: $blur, in: 0...10)
			Spacer()
			Text("\(10)")
		}
	}
}

/*
struct BlurControl_Previews: PreviewProvider {
    static var previews: some View {
        BlurControl()
    }
}
*/
