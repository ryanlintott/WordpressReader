//
//  ContentView.swift
//  WordpressReaderExample
//
//  Created by Ryan Lintott on 2021-05-18.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            VStack {
                Image("WordpressReader-logo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 400)
                    .padding()
                
                Text("A Swift Package with a collection of SwiftUI framing views and tools to help with layout.")
                
                Spacer()
            }
            .tabItem {
                Label("Title", systemImage: "newspaper")
            }
            
            WordpressSiteAsyncView()
                .tabItem {
                    Label("Async", systemImage: "sparkles")
                }
            
            WordpressSiteView()
                .tabItem {
                    Label("Closure", systemImage: "network")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
