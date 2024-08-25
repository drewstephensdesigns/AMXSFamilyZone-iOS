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
    @StateObject private var viewModel = PostListenerViewModel()
    
    enum Tab {
        case home, addPost, quickLinks, profile
    }
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    .tag(Tab.home)
                
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
