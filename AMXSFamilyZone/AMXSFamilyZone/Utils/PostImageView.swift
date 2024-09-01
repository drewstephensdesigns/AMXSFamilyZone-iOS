//
//  PostImageView.swift
//  AMXSFamilyZone
//
//  Created by Andrew Stephens on 8/29/24.
//
import SwiftUI
import SDWebImageSwiftUI

struct PostImageView: View {
    let imageUrl: String?
    var body: some View {
        if let imageUrl = imageUrl, !imageUrl.isEmpty {
            WebImage(url: URL(string: imageUrl))
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: 250, alignment: .center)
                .cornerRadius(14)
                .padding(.top, 8)
                .padding(.horizontal, 8)
        }
    }
}
