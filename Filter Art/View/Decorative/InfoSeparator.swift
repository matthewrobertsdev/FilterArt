//
//  InfoSeperator.swift
//  SwiftUI Design
//
//  Created by Matt Roberts on 8/23/22.
//

import SwiftUI

struct InfoSeperator: View {
	var body: some View {
		RoundedRectangle(cornerRadius: 1)
			.fill(Color.accentColor)
			.frame(width: nil, height: 1).padding(.horizontal)
	}
}

struct InfoSeperator_Previews: PreviewProvider {
	static var previews: some View {
		InfoSeperator()
	}
}
