//
//  Post.swift
//  AMXSFamilyZone
//
//  Created by Andrew Stephens on 6/2/24.
//

import Foundation
import FirebaseFirestoreSwift

struct Post: Codable, Identifiable {
    @DocumentID var id: String?
    var text: String
    var link: String?
    var imageUrl: String?
    var user: User? // Change to optional type User?
    var creatorId: String?
    var time: Double


    // Update the initializer accordingly
    init(id: String? = nil, text: String = "", link: String? = nil, imageUrl: String? = nil, user: User? = nil, creatorId: String, time: Double) {
        self.id = id
        self.text = text
        self.link = link
        self.imageUrl = imageUrl
        self.user = user
        self.creatorId = creatorId
        self.time = time * 1000
    }

    var dictionary: [String: Any] {
        return [
            "id": id as Any,
            "text": text,
            "link": link as Any,
            "imageUrl": imageUrl as Any,
            "user": user?.dictionary as Any, // Ensure user is unwrapped
            "creatorId" : creatorId as Any,
            "time": time,
        ]
    }

    // Function to convert Unix timestamp to a readable date string
    func getTimeStamp() -> String {
       // print("Raw timestamp from Firebase: \(time)")
       // print("Text from Firebase:  \(text)")
        
        // Convert milliseconds to seconds
        let date = Date(timeIntervalSince1970: time / 1000)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy h:mm a"
        let dateString = dateFormatter.string(from: date)
        
       // print("Converted date string: \(dateString)")
        
        return dateString
    }
}
