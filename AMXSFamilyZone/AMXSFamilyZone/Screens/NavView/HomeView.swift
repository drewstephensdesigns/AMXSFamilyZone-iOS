//
//  HomeView.swift
//  AMXSFamilyZone
//
//  Created by Andrew Stephens on 6/28/24.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var homeFeed = HomeFeed()
    
    var body: some View {
        NavigationView {
            VStack {
                if homeFeed.posts.isEmpty {
                    Text("No Results Found")
                        .font(.title)
                        .bold()
                        .padding()
                } else {
                    List(homeFeed.posts) { post in
                        PostView(post: post)
                    }
                }
            }
            .onAppear {
                homeFeed.fetchPosts()
            }
            .navigationTitle("Home")
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
