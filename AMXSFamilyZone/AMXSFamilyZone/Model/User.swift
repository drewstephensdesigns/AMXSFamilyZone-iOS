//
//  User.swift
//  AMXSFamilyZone
//
//  Created by Andrew Stephens on 6/2/24.
//

import Foundation

struct User: Codable, Identifiable {
    var id: String?
    var name: String?
    var email: String
    var following: [String]?
    var bio: String?
    var imageUrl: String?
    var link: String?
    var accountCreated: Double

    init(id: String = "", name: String, email: String, following: [String] = [], bio: String = "", imageUrl: String = "", link: String = "", accountCreated:Double) {
        self.id = id
        self.name = name
        self.email = email
        self.following = following
        self.bio = bio
        self.imageUrl = imageUrl
        self.link = link
        self.accountCreated = accountCreated * 1000
    }

    var dictionary: [String: Any?] {
        return [
            "id": id as Any,
            "name": name,
            "email": email,
            "following": following,
            "bio": bio,
            "imageUrl": imageUrl,
            "link": link,
            "accountCreated" : accountCreated
        ]
    }
    
        // Function to convert Unix timestamp to a readable date string
        func getTimeStamp() -> String {
           // print("Raw timestamp from Firebase: \(time)")
           // print("Text from Firebase:  \(text)")
            
            // Convert milliseconds to seconds
            let date = Date(timeIntervalSince1970: accountCreated / 1000)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM d, yyyy h:mm a"
            let dateString = dateFormatter.string(from: date)
            
           // print("Converted date string: \(dateString)")
            
            return dateString
        }
}
