//
//  ResourceItem.swift
//  AMXSFamilyZone
//
//  Created by Andrew Stephens on 6/3/24.
//

import Foundation

struct ResourceItem: Decodable, Identifiable {
    var id: Int
    var resourceName: String
    var resourceLink: String
    var resourceDescription: String

    enum CodingKeys: String, CodingKey {
        case id = "ResourceID"
        case resourceName = "ResourceName"
        case resourceLink = "ResourceLink"
        case resourceDescription = "ResourceDescription"
    }
}
