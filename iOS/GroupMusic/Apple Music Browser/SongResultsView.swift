//
//  SongResultsView.swift
//  GroupMusic
//
//  Created by Louis Mark on 2021-02-01.
//

import SwiftUI

struct SongResultsView: View {
    @Binding var songResults: [Track]
    @Binding var showPreview: Bool
    @Binding var previewTrack: Track?
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(songResults, id: \.self) { songResult in
                    ResultCardView(result: songResult)
                        .onTapGesture {
                            self.previewTrack = songResult
                            withAnimation {
                                self.showPreview = true
                            }
                        }
                }
            }
        }
    }
}

//struct SongResultsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SongResultsView()
//    }
//}
