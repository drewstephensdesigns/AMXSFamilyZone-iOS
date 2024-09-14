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
    
    let backgroundColors: [Color] = [
        .red, .green, .blue, .orange, .purple, .yellow, .pink, .teal
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
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
                    .frame(height: 200)
                  
                    
                    // 317 AW Family Link
                    Text("Join the 317th Airlift Wing Families Group (Facebook)")
                        .font(.system(.caption).bold())
                        .padding(.horizontal)
                        .onTapGesture {
                            openFacebookLink("https://www.facebook.com/groups/317awfamilies/?ref=share&mibextid=NSMWBT", appId: "317awfamilies")
                        }
                       
                    
                    // Dyess Spouses Link
                    Text("Join the Dyess Spouses Group (Facebook)")
                        .font(.system(.caption).bold())
                        .padding(.horizontal)
                        .onTapGesture {
                            openFacebookLink("https://www.facebook.com/groups/259025040926614/?ref=share&mibextid=NSMWBT", appId: "259025040926614")
                        }
                       
                    
                    // Crisis Response Header
                    Text("* Orange text denotes crisis response resources")
                        .font(.system(.caption).bold())
                        .foregroundColor(.orange)
                        .padding(.top, 10)
                    
                    // Builds Text Headers for the Resources
                    ForEach(fetcher.resources.indices, id: \.self) { index in
                        let item = fetcher.resources[index]
                        let imageName = imageNames[index % imageNames.count]
                        
                        HStack(alignment: .top) {
                            Image(systemName: imageName)
                                .resizable()
                                .frame(width: 24, height: 24)
                                .padding(.trailing, 10)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.resourceName)
                                    .font(.system(.subheadline))
                                    .foregroundColor(index < 3 ? .orange : .primary)
                                Text(item.resourceDescription)
                                    .font(.system(.footnote))
                                    .foregroundColor(.gray)
                                    .lineLimit(2)
                                    .truncationMode(.tail)
                            }
                            .onTapGesture {
                                openLink(for: item, at: index)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Resources")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func openLink(for item: ResourceItem, at index: Int) {
        let urlString = index == 5 ? "https://apps.apple.com/us/app/usaf-connect/id1403806821" : item.resourceLink
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func openFacebookLink(_ link: String, appId: String) {
        let fbAppUrl = "fb://group/\(appId)"
        if let fbUrl = URL(string: fbAppUrl), UIApplication.shared.canOpenURL(fbUrl) {
            UIApplication.shared.open(fbUrl, options: [:], completionHandler: nil)
        } else if let webUrl = URL(string: link) {
            UIApplication.shared.open(webUrl, options: [:], completionHandler: nil)
        }
    }
    
    private func openFeaturedLink(for item: FeaturedItem, at index: Int) {
        if let url = URL(string: item.pubUrl) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}


#Preview {
    ResourcesView()
}

/*
 struct ResourcesView_Previews: PreviewProvider {
 static var previews: some View {
 ResourcesView()
 .preferredColorScheme(.light)
 ResourcesView()
 .preferredColorScheme(.dark)
 }
 }
 */
