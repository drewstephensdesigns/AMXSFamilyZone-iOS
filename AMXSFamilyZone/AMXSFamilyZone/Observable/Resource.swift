//
//  Resource.swift
//  AMXSFamilyZone
//
//  Created by Andrew Stephens on 6/4/24.
//

import Foundation

class Resource: ObservableObject{
    @Published var resources = [ResourceItem]()
    
    init() {
        load()
    }
    
    func load() {
        let url = URL(string : Consts.FEATURED_URL + "resources.json")!
        
        URLSession.shared.dataTask(with: url) {(data,response,error) in
            do {
                if let d = data {
                    let decodedList = try JSONDecoder().decode([ResourceItem].self, from: d)
                    DispatchQueue.main.sync {
                        self.resources = decodedList
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
