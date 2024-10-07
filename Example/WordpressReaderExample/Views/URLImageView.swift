//
//  URLImageView.swift
//  WordpressReaderExample
//
//  Created by Ryan Lintott on 2021-05-18.
//

import SwiftUI

struct URLImageView: View {
    let url: String
    
    @State private var image: Image? = nil
    
    var body: some View {
        ZStack {
            image?
                .resizable()
                .scaledToFit()
        }
        .onAppear {
            Task {
                await loadImage()
            }
        }
    }
    
    func loadImage() async {
        guard let url = URL(string: url) else {
            print("URLImageView: Bad url")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            #if os(macOS)
            if let nsImage = NSImage(data: data) {
                image = Image(nsImage: nsImage)
            }
            #else
            if let uiImage = UIImage(data: data) {
                image = Image(uiImage: uiImage)
            }
            #endif
        } catch {
            print(error)
        }
    }
}

struct URLImageView_Previews: PreviewProvider {
    static var previews: some View {
        URLImageView(url: "https://oldenglishwordhord.files.wordpress.com/2019/04/wordwyrm-05-no-text.png")
    }
}
