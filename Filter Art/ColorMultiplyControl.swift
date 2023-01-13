//
//  ColorMultiplyControl.swift
//  SwiftUI Design
//
//  Created by Matt Roberts on 9/11/22.
//

import SwiftUI

struct ColorMultiplyControl: View {
	@Binding var colorMultiplyColor: Color
	var body: some View {
		Group {
			ColorPicker(selection: $colorMultiplyColor) {
				Text("Choose color to multiply by:")
			}
		}
	}
}

/*
struct ColorMultiplyControl_Previews: PreviewProvider {
    static var previews: some View {
        ColorMultiplyControl()
    }
}
*/
