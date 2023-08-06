//
//  Store.swift
//  
//
//  Created by Alsey Coleman Miller on 8/6/23.
//


import Foundation
import Combine
import SwiftUI
import Odysee

@MainActor
public final class Store: ObservableObject {
    
    internal lazy var urlSession = loadURLSession()
    
    internal lazy var preferences = loadPreferences()
    
    internal var preferencesObserver: AnyCancellable?
    
    deinit {
        preferencesObserver?.cancel()
    }
}
