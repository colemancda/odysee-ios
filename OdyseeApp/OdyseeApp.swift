//
//  OdyseeApp.swift
//  OdyseeApp
//
//  Created by Alsey Coleman Miller on 8/5/23.
//

import Foundation
import SwiftUI
import OdyseeKit

@main
struct OdyseeApp: App {
    
    static let store = Store()
    
    @StateObject
    var store: Store
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
    
    init() {
        let store = OdyseeApp.store
        _store = .init(wrappedValue: store)
        store.log("Launching Odysee v\(Bundle.InfoPlist.shortVersion) (\(Bundle.InfoPlist.version))")
    }
}
