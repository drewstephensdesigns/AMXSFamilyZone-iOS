//
//  ProfileImageView.swift
//  AMXSFamilyZone
//
//  Created by Andrew Stephens on 8/30/24.
//

import SwiftUI

struct ProfileImageView: View {
    let imageUrl: String
    let size: CGFloat
    let strokeColor: Color
    let strokeWidth: CGFloat

    var body: some View {
        let url = URL(string: imageUrl.isEmpty ? Consts.DEFAULT_USER_IMAGE : imageUrl)
        
        AsyncImage(url: url) { image in
            image.resizable()
                .frame(width: size, height: size)
                .clipShape(Circle())
                .overlay(Circle().stroke(strokeColor, lineWidth: strokeWidth))
                .padding(.leading, 20)
        } placeholder: {
            Image(systemName: "person.circle")
                .resizable()
                .frame(width: size, height: size)
                .clipShape(Circle())
                .overlay(Circle().stroke(strokeColor, lineWidth: strokeWidth))
                .padding(.leading, 20)
        }
    }
}
