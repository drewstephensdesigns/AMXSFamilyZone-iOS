//
//  Featured.swift
//  AMXSFamilyZone
//
//  Created by Andrew Stephens on 6/20/24.
//

import Foundation
class Featured: ObservableObject{
    @Published var featured = [FeaturedItem]()
    
    init() {
        load()
    }
    
    func load() {
        let url = URL(string : Consts.FEATURED_URL + "data.json")!
        
        URLSession.shared.dataTask(with: url) {(data,response,error) in
            do {
                if let d = data {
                    let decodedList = try JSONDecoder().decode([FeaturedItem].self, from: d)
                    DispatchQueue.main.sync {
                        self.featured = decodedList
                        //print(decodedList)
                    }
                } else {
                    print("No Data")
                }
            } catch{
                print("Error info: \(error)")
            }
        }.resume()
    }
}

