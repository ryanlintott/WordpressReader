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
                
                Text("A Swift package for asynchronously downloading and decoding public WordPress content.")
                
                Spacer()
            }
            .tabItem {
                Label("Title", systemImage: "newspaper")
            }
            
            WordpressSiteAsyncView()
                .tabItem {
                    Label("Content", systemImage: "network")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
