//
//  ToggleButton.swift
//  CourtFinder
//
//  Created by Rajat Khare on 8/22/24.
//

import SwiftUI

struct ToggleButton: View {
    @Binding var isMapView: Bool

    var body: some View {
        Button(action: {
            isMapView.toggle()
        }) {
            Image(systemName: isMapView ? "list.bullet" : "map.fill")
                .resizable()
                .aspectRatio(contentMode: .fit) // Ensure the image fills the frame while maintaining its aspect ratio
                .frame(width: 20, height: 20) // Adjust the frame size as needed
                .clipped() // Clip any excess image that overflows the frame
                .padding()
                .background(Color.white.opacity(0.8))
                .clipShape(Circle())
                .shadow(radius: 4)
        }
        .padding()
    }
}

