//
//  ContentView.swift
//  Fillter Art
//
//  Created by Matt Roberts on 1/13/23.
//

import SwiftUI

struct ContentView: View {
	@Environment(\.managedObjectContext) private var viewContext

    var body: some View {
		ImageView().navigationTitle(Text("Filter Art"))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
