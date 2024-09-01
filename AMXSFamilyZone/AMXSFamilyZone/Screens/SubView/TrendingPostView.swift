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

struct TrendingPostView: View{
    var trendPost: Post
    
    var body: some View{
        ScrollView{
            VStack(alignment: .leading, spacing: 8){
                
                // Post Description
                PostTextView(text: trendPost.text, color: .secondary, textSize: 13)
                
                // post Author
                if let author = trendPost.user?.name{
                    ZStack(alignment: .leading){
                        PostTextView(text: "Posted By \(author)", color: .blue, textSize: 11)
                    }
                }
            }
        }
    }
}
