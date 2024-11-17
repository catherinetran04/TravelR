//
//  TravelerApp.swift
//  Traveler
//
//  Created by Catherine Tran on 11/15/24.
//

import SwiftUI
import Combine

@main
struct TravelerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
/*
ZStack {
    Color(red: 0.96, green: 0.96, blue: 0.86)
        .ignoresSafeArea()
    VStack {
        
        HStack {
            VStack{
                Text("Welcome")
                    .font(.headline)
                Text("to")
                    .font(.caption)
                Text("Map Mems")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            Text("Welcome to the start of your journeys!")
        }
        .background(Rectangle()
            .fill(Color.white)
            .cornerRadius(15)
            .shadow(radius: 10)
        )
        
       
        
        
        /*ScrollView {
            VStack(alignment: .leading, spacing: 0.0) {
                ForEach(0..<100) {
                    Text("Row \($0)")
                }
            }
        }*/
        
        
        Menu("Menu") {
            Text("Menu Item 1")
            Text("Menu Item 2")
            Text("Menu Item 3")
        }
        Image(systemName: "globe")
            .imageScale(.large)
            .foregroundStyle(.tint)
        Text("or stay home cuz we broke")
        
    }
    .padding()
}*/
