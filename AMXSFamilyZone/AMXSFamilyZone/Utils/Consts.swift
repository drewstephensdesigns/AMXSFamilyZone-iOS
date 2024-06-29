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

    // Static function for saving to clipboard
    // function not yet used
    static func saveToClipboard(text: String) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = text
    }
}
