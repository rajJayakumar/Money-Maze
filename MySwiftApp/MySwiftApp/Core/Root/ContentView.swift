//
//  ContentView.swift
//  MySwiftApp
//
//  Created by Rajaselvam Jayakumar on 10/8/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel : AuthViewModel
    
    var body: some View {
        Group {
//            if viewModel.userSession != nil {
//                //ProfileView()
//                NavBarView()
//                    .onAppear{
//                        print(viewModel.userSession ?? "No session")
//                    }
            if let session = viewModel.userSession, viewModel.currentUser != nil {
                    NavBarView()
                        .onAppear {
                            print("DEBUG: User session: \(session)")
                        }
                
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    ContentView()
}
