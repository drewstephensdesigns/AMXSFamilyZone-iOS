//
//  PostTextView.swift
//  AMXSFamilyZone
//
//  Created by Andrew Stephens on 8/29/24.
//

import SwiftUI

struct PostTextView: View {
    let text: String
    let color: Color
    let textSize: CGFloat
    
    var body: some View {
        Text(text)
            //.font(.custom("Alata-Regular", size: textSize))
            .font(.system(size: textSize, design: .rounded))
            .fontWeight(.medium)
            .foregroundColor(color)
            .lineLimit(3)
            .truncationMode(.tail)
            .padding(.horizontal, 8)
    }
}

