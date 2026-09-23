//
//  Photos.swift
//  Basic
//
//  Created by Teyit Ajimamatov on 15/9/26.
//

import SwiftUI

struct PhotosView: View {
    // 1. Change this to a Binding so the parent view can inject data
    @Binding var thumbnailUrl: String
    
    var body: some View {
        VStack {
            if let url = URL(string: thumbnailUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                        
                    case .failure(let error):
                        VStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text(error.localizedDescription)
                                .font(.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                        
                    case .empty:
                        // Use a ProgressView to show it is loading
                        ProgressView()
                        
                    @unknown default:
                        EmptyView()
                    }
                }
                // 2. Moved frame and clipped here so placeholders match the layout size perfectly
                .frame(width: 200, height: 200)
                .clipped()
            } else {
                // Fallback for completely invalid string formats
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    // Changing the domain completely fixes the TLS connection issue
    PhotosView(thumbnailUrl: .constant("https://placehold.co"))
}


