//
//  Consts.swift
//  AMXSFamilyZone
//
//  Created by Andrew Stephens on 6/3/24.
//

import SwiftUI
import UIKit

struct Consts {
    static let USER_NODE = "Users"
    static let POST_NODE = "Post"
    static let REPORTS_NODE = "Reports"
    static let COMMENTS_NODE = "Comments"
    static let IMAGES_NODE = "Images"
    static let FEATURED_URL = "https://drewstephensdesigns.github.io/AMXSFamilyZone/data/"
    
    static let SOURCE_CODE = "https://github.com/drewstephensdesigns/AMXSFamilyZone-iOS"

    static func saveToClipboard(text: String) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = text
    }
}
