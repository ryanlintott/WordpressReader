//
//  WordpressSettingsView.swift
//  WordpressReaderExample
//
//  Created by Ryan Lintott on 2020-07-23.
//

import SwiftUI
import WordpressReader

struct WordpressSettingsView: View {
    let settings: WordpressSettings?
    
    var body: some View {
        if let settings = settings {
            NavigationView {
                Form {
                    Section(header: Text("Name")) {
                        Text(settings.name)
                    }
                    
                    Section(header: Text("Description")) {
                        Text(settings.description)
                    }
                    
                    Section(header: Text("URL")) {
                        Text(settings.URL)
                    }
                    
                    Section(header: Text("Logo")) {
                        Text(settings.logo.url)
                        URLImageView(url: settings.logo.url)
                            .padding()
                    }
                    
                    Section(header: Text("Icon")) {
                        Text(settings.icon.img)
                        URLImageView(url: settings.icon.img)
                            .frame(width: 96)
                            .padding()
                    }
                }
                .navigationTitle("Settings")
            }
        }
    }
}

struct WordpressSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        WordpressSettingsView(settings: .example)
    }
}
