//
//  ContrastControl.swift
//  SwiftUI Design
//
//  Created by Matt Roberts on 9/12/22.
//

import SwiftUI

struct ContrastControl: View {
	@Binding private var contrast: Double
	init(contrast: Binding<Double>) {
		self._contrast = contrast
	}
	var body: some View {
		HStack {
			Text("\(-2)")
			Spacer()
			Slider(value: $contrast, in: -2...2)
			Spacer()
			Text("\(2)")
		}
	}
}

/*
struct ContrastControl_Previews: PreviewProvider {
    static var previews: some View {
        ContrastControl()
    }
}
*/