//
//  Consts.swift
//  AMXSFamilyZone
//
//  Created by Andrew Stephens on 6/3/24.
//

import SwiftUI
import UIKit

struct Consts {
    // Firebase Database
    static let USER_NODE = "Users"
    static let POST_NODE = "Post"
    static let REPORTS_NODE = "Reports"
    static let COMMENTS_NODE = "Comments"
    
    // Firebase Storage
    static let IMAGES_NODE = "Images"
    
    // URLS
    static let FEATURED_URL = "https://drewstephensdesigns.github.io/AMXSFamilyZone/data/"
    static let SOURCE_CODE = "https://github.com/drewstephensdesigns/AMXSFamilyZone-iOS"
    static let DEFAULT_USER_IMAGE = "https://firebasestorage.googleapis.com/v0/b/amxs-family-zone-a2d4e.appspot.com/o/Images%2Fdefault_user_image.jpg?alt=media&token=24692997-da61-4e3a-b4c1-6858236d29c6"
    
    static let DEFAULT_POST_IMAGE = "https://firebasestorage.googleapis.com/v0/b/amxs-family-zone-a2d4e.appspot.com/o/Images%2Fstatic_image_chains-50px.png?alt=media&token=fc3a1760-6863-465f-96e6-7b03b668eb4b"


    // Static function for saving to clipboard
    // function not yet used
    static func saveToClipboard(text: String) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = text
    }
}
