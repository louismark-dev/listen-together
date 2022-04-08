//
//  ResultCardView.swift
//  GroupMusic
//
//  Created by Louis on 2021-01-01.
//

import SwiftUI

struct ResultCardView: View {
    var result: Track
    var body: some View {
        VStack(alignment: .leading) {
            Text(result.attributes?.name ?? "No name available")
        }
        .padding()
        .background(Color.yellow)
    }
}
