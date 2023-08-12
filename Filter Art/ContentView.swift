//
//  ContentView.swift
//  Fillter Art
//
//  Created by Matt Roberts on 1/13/23.
//

import SwiftUI

struct ContentView: View {
	
	@AppStorage("imageUseOriginalImage") private var useOriginalImage: Bool = true
	@Environment(\.managedObjectContext) private var viewContext
	@EnvironmentObject var modalStateViewModel: ModalStateViewModel
	@EnvironmentObject var filterStateHistory: FilterStateHistory
	
    var body: some View {
		ImageView().navigationTitle(Text("Filter Art")).environmentObject(modalStateViewModel).environmentObject(filterStateHistory)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

