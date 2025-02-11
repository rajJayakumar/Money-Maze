//
//  NavBarView.swift
//  MySwiftApp
//
//  Created by Rajaselvam Jayakumar on 11/27/24.
//

import SwiftUI

struct NavBarView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            
            NavigationStack {
                TransactionListView()
            }
            .tabItem {
                Image(systemName: "list.bullet.rectangle.portrait.fill")
                Text("Transactions")
            }
            
            GroupListView()
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("Budget")
                }
            
            NavigationStack {
                GoalListView()
            }
                .tabItem {
                    Image(systemName: "flag.fill")
                    Text("Goals")
                }
            
            
            ChatBotView()
                .navigationBarBackButtonHidden(true)
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("Chat")
                }
            
            // Statistics Tab
            NavigationStack {
                DashboardView()
                    .navigationBarBackButtonHidden(true)// Assuming you have a StatisticsView to display
            }
            .tabItem {
                Image(systemName: "chart.bar.xaxis")
                Text("Statistics")
            }
            .navigationBarBackButtonHidden(true)
            
            // Profile Tab
            NavigationStack {
                ProfileView()
                    .navigationBarBackButtonHidden(true)// Assuming you have a ProfileView to display
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
            .navigationBarBackButtonHidden(true)
        }
        .accentColor(Colors().darkGreen) // Change this to style the active tab
    }
}

#Preview {
    NavBarView()
}
