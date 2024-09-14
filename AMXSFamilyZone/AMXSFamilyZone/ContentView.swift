//
//  ContentView.swift
//  AMXSFamilyZone
//
//  Created by Andrew Stephens on 6/27/24.
//

import SwiftUI
import Firebase

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    @ObservedObject var postListener = PostListenerViewModel()
    
    enum Tab {
        case home, trending, addPost, quickLinks, profile
    }
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    .tag(Tab.home)
                
                TrendingView()
                    .tabItem {
                        Label("Trending", systemImage: "magnifyingglass")
                    }
                    .tag(Tab.trending)
                
                AddPostView()
                    .tabItem {
                        Label("Add Post", systemImage: "square.and.pencil")
                    }
                    .tag(Tab.addPost)
                
                ResourcesView()
                    .tabItem {
                        Label("Resources", systemImage: "globe")
                    }
                    .tag(Tab.quickLinks)
                
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.circle")
                    }
                    .tag(Tab.profile)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }

    }
    
    func getTitle(for tab: Tab) -> String {
        switch tab {
            case .home:
                return "Home"
            case .trending:
                return "Trending"
            case .addPost:
                return "Add Post"
            case .quickLinks:
                return "Resources"
            case .profile:
                return "Profile"
        }
    }
}

#Preview {
    ContentView()
}
