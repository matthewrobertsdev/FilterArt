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
	var body: some View {
		HStack {
			Text("\(0)")
			Spacer()
			Slider(value: $blur, in: 0...10){ editing in
				if !editing {
					saveForUndo()
				}
			}
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
