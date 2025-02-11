//
//  MySwiftAppApp.swift
//  MySwiftApp
//
//  Created by Rajaselvam Jayakumar on 10/8/24.
//

import SwiftUI
import Firebase

@main
struct MySwiftAppApp: App {
    @StateObject var viewModel = AuthViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}

