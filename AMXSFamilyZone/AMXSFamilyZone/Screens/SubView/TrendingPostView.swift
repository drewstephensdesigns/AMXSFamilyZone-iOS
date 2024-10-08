//
//  TrendingPostView.swift
//  AMXSFamilyZone
//
//  Created by Andrew Stephens on 8/31/24.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct TrendingPostView: View {
    var trendPost: Post
    let defaultImageUrl = Consts.DEFAULT_POST_IMAGE
    let genericDescription = "No description available."
    
        // Placeholder for your home view or detailed post view
    var homeView: some View {
        HomeView() // Replace with your actual home or post detail view
    }
    
    var body: some View {
        NavigationLink(destination: homeView) {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 16) {
                            // Show the generic image if the description is empty
                        if trendPost.text.isEmpty {
                            AsyncImage(url: URL(string: defaultImageUrl)) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(8)
                                } else if phase.error != nil {
                                    Image(systemName: "exclamationmark.triangle")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.red)
                                } else {
                                    ProgressView()
                                        .frame(width: 100, height: 100)
                                }
                            }
                        }
                        
                            // VStack for text content (description and author)
                        VStack(alignment: .leading, spacing: 8) {
                                // Post description or generic text
                            if trendPost.text.isEmpty {
                                PostTextView(text: genericDescription, color: .secondary, textSize: 13)
                            } else {
                                PostTextView(text: trendPost.text, color: .secondary, textSize: 13)
                            }
                            
                                // Post author
                            if let author = trendPost.user?.name {
                                PostTextView(text: "Posted By \(author)", color: .blue, textSize: 11)
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
}
