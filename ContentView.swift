//
//  ContentView.swift
//  Traveler
//
//  Created by Catherine Tran on 11/15/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
        TabView {
            JournalView()
                .tabItem {
                    Label("Photos", systemImage: "document.circle")
                }
            
            HomeView()
                .tabItem {
                    Label("Map", systemImage: "mappin.circle.fill")
                }
            
            DiscoverView()
                .tabItem {
                    Label("Discover", systemImage: "location.magnifyingglass")
                }
            }
        
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
