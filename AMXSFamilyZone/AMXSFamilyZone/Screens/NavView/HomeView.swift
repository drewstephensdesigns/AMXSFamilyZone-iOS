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
        VStack {
            if homeFeed.posts.isEmpty {
                Text("No Results Found")
                    .font(.title)
                    .bold()
                    .padding()
            } else {
                GeometryReader { geometry in
                    List(homeFeed.posts) { post in
                        PostView(post: post)
                            .frame(maxWidth: geometry.size.width)
                            .listRowInsets(EdgeInsets())  // Adjusts insets to make use of space
                    }
                    .listStyle(PlainListStyle())  // More consistent with iPad style
                }
            }
        }
        .onAppear {
            homeFeed.fetchPosts()
        }
        .navigationTitle("Home")
        .padding()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .previewDevice("iPhone 14")
        HomeView()
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
