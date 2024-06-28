//
//  ResourcesView.swift
//  AMXSFamilyZone
//
//  Created by Andrew Stephens on 6/28/24.
//

import SwiftUI

struct ResourcesView: View {
    @State private var width = CGFloat.zero
    @State private var labelWidth = CGFloat.zero
    @ObservedObject var fetcher = Resource()
    @ObservedObject var featuredFetcher = Featured()
    
    // Define the SF Symbol names as strings
    let imageNames = [
        "exclamationmark.shield",
        "staroflife",
        "phone",
        "link",
        "mail.and.text.magnifyingglass",
        "iphone.homebutton",
        "figure.mind.and.body",
        "cross.circle.fill",
        "giftcard",
        "heart.text.square",
        "pencil.and.list.clipboard",
        "bandage",
        "figure.jumprope",
        "globe.americas",
        "graduationcap",
        "checkmark.bubble",
        "person.bust",
        "figure.mind.and.body",
        "pencil.and.ruler",
        "figure.and.child.holdinghands",
        "waveform.path.ecg.rectangle",
        "calendar",
        "link",
        "rectangle.inset.filled.and.person.filled",
        "network",
        "globe.desk"
        ]
    
    // Define an array of background colors for the cards
    let backgroundColors: [Color] = [
        .red, .green, .blue, .orange, .purple, .yellow, .pink, .teal
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                // Full width card view with dot indicators
                TabView {
                    ForEach(featuredFetcher.featured.indices, id: \.self) { index in
                        let featuredItem = featuredFetcher.featured[index]
                        let backgroundColor = backgroundColors[index % backgroundColors.count]
                        
                        VStack {
                            Text(featuredItem.pubTitle)
                                .font(.system(.footnote))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding()
                                .background(backgroundColor)
                                .cornerRadius(8)
                                .onTapGesture {
                                    openFeaturedLink(for: featuredItem, at: index)
                                }
                        }
                        .padding()
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .frame(height: 200) // Adjust the height for the card view
                
                // Vertical List
                Text("* Orange text denotes crisis response resources")
                    .font(.system(.caption).bold())
                    .foregroundColor(.orange)
               
                List(fetcher.resources.indices, id: \.self) { index in
                    let item = fetcher.resources[index]
                    let imageName = imageNames[index % imageNames.count]
                    
                    HStack {
                        if UIImage(systemName: imageName) != nil {
                            // Use SF Symbol
                            Image(systemName: imageName)
                                .resizable()
                                .frame(width: 24, height: 24)
                                .padding(.trailing, 10)
                        } else {
                            // Fallback for custom images
                            Image(imageName)
                                .resizable()
                                .frame(width: 24, height: 24)
                                .padding(.trailing, 10)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.resourceName)
                                .font(.system(.callout))
                                .foregroundColor(index < 3 ? .orange : .primary) // Conditional color
                            Text(item.resourceDescription)
                                .font(.system(.footnote))
                                .foregroundColor(.gray)
                                .lineLimit(2)
                                .truncationMode(.tail) // Add ellipses at the end if text overflows
                        }
                        .onTapGesture {
                            openLink(for: item, at: index)
                        }
                    }
                    .padding(.vertical, 5) // Adjust the padding between rows
                }
                .listStyle(.plain)
                .listRowSpacing(2)
            }
            .navigationTitle("Resources")
        }
    }
    
    private func openLink(for item: ResourceItem, at index: Int) {
        let urlString: String
        if index == 5 {
            // Special URL for the fifth item
            // Breaks on XCODE Simulator, but should work in prod
            urlString = "https://apps.apple.com/us/app/usaf-connect/id1403806821"
        } else {
            // Use the resource link for other items
            urlString = item.resourceLink
        }
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func openFeaturedLink(for item: FeaturedItem, at index: Int) {
        let urlString: String
        urlString = item.pubUrl
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

struct ResourcesView_Previews: PreviewProvider {
    static var previews: some View {
        ResourcesView()
            .preferredColorScheme(.light) // For light mode preview
        ResourcesView()
            .preferredColorScheme(.dark) // For dark mode preview
    }
}

