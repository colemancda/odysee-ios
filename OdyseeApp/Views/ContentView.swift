//
//  ContentView.swift
//  OdyseeApp
//
//  Created by Alsey Coleman Miller on 8/5/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            TrendingContentView()
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
