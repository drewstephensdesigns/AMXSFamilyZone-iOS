//
//  FeaturedItem.swift
//  AMXSFamilyZone
//
//  Created by Andrew Stephens on 6/20/24.
//

import Foundation
struct FeaturedItem: Decodable, Identifiable {
    var id: Int
    var pubTitle: String
    var pubNumber: String
    var pubOpr: String
    var pubUrl: String

    enum CodingKeys: String, CodingKey {
        case id = "PubID"
        case pubTitle = "Title"
        case pubNumber = "Number"
        case pubOpr = "OPR"
        case pubUrl = "DocumentUrl"
    }
}

